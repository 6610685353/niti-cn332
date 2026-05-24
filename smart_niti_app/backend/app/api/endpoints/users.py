import models.user as models_user
from fastapi import APIRouter, Depends, HTTPException, Query, UploadFile, File, Form
from sqlalchemy.orm import Session
from database import get_db
from schemas import user as schemas_user
from firebase_admin import auth
from auth import get_current_user
from typing import Optional, List
from core.supabase_client import supabase

router = APIRouter(prefix="/users", tags=["Users"])


# ══════════════════════════════════════════════════════════════════════════════
# NOTE: Routes with /me/* MUST come before /{uid} to avoid FastAPI
#       treating "me" as a uid path parameter.
# ══════════════════════════════════════════════════════════════════════════════


@router.patch("/me")
async def update_self_profile(
    email: Optional[str] = Form(None),
    first_name: Optional[str] = Form(None),
    last_name: Optional[str] = Form(None),
    file: Optional[UploadFile] = File(None),
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    db_user = (
        db.query(models_user.UserModel)
        .filter(models_user.UserModel.uid == current_user.uid)
        .first()
    )
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")

    if email:
        try:
            auth.update_user(current_user.uid, email=email)
        except auth.EmailAlreadyExistsError:
            raise HTTPException(
                status_code=409,
                detail="This email is already in use by another account.",
            )
        except Exception as e:
            raise HTTPException(status_code=400, detail=str(e))

    if first_name is not None:
        db_user.first_name = first_name
    if last_name is not None:
        db_user.last_name = last_name

    if file:
        if db_user.image_url:
            try:
                supabase.storage.from_("profile_image").remove([db_user.image_url])
            except Exception:
                pass

        ext = file.filename.rsplit(".", 1)[-1] if "." in file.filename else "jpg"
        filename = f"profile_{current_user.uid}.{ext}"
        image_path = f"{current_user.uid}/{filename}"

        file_bytes = await file.read()
        supabase.storage.from_("profile_image").upload(
            path=image_path,
            file=file_bytes,
            file_options={"content-type": file.content_type, "upsert": "true"},
        )
        db_user.image_url = image_path

    db.commit()
    db.refresh(db_user)
    return db_user


@router.post("/me/avatar")
async def upload_self_avatar(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    """อัปโหลด/เปลี่ยนรูปโปรไฟล์ตัวเอง — Flutter UserService.uploadAvatar เรียก endpoint นี้"""
    db_user = (
        db.query(models_user.UserModel)
        .filter(models_user.UserModel.uid == current_user.uid)
        .first()
    )
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")

    # ลบรูปเก่าก่อน (ถ้ามี)
    if db_user.image_url:
        try:
            supabase.storage.from_("profile_image").remove([db_user.image_url])
        except Exception:
            pass

    ext = file.filename.rsplit(".", 1)[-1] if "." in file.filename else "jpg"
    filename = f"profile_{current_user.uid}.{ext}"
    image_path = f"{current_user.uid}/{filename}"

    file_bytes = await file.read()
    supabase.storage.from_("profile_image").upload(
        path=image_path,
        file=file_bytes,
        file_options={"content-type": file.content_type, "upsert": "true"},
    )
    db_user.image_url = image_path
    db.commit()
    db.refresh(db_user)

    # คืน signed URL ทันที
    signed_url = None
    try:
        res = supabase.storage.from_("profile_image").create_signed_url(
            path=image_path, expires_in=3600
        )
        signed_url = res["signedUrl"]
    except Exception:
        pass

    return {
        "uid": db_user.uid,
        "first_name": db_user.first_name,
        "last_name": db_user.last_name,
        "role": db_user.role,
        "status": db_user.status,
        "image_url": signed_url,
        "created_at": db_user.created_at,
        "updated_at": db_user.updated_at,
    }


@router.delete("/me/avatar")
def delete_self_avatar(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    """ลบรูปโปรไฟล์ของตัวเอง"""
    db_user = (
        db.query(models_user.UserModel)
        .filter(models_user.UserModel.uid == current_user.uid)
        .first()
    )
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")
    if not db_user.image_url:
        raise HTTPException(status_code=404, detail="No avatar to delete")

    try:
        supabase.storage.from_("profile_image").remove([db_user.image_url])
    except Exception:
        pass

    db_user.image_url = None
    db.commit()
    return {"message": "Avatar deleted successfully"}


# ── Check email (ต้องอยู่ก่อน /{uid} ด้วย) ────────────────────────────────────
@router.get("/check-email")
def check_email_exists(email: str):
    try:
        auth.get_user_by_email(email)
        return {"exists": True}
    except auth.UserNotFoundError:
        return {"exists": False}


# ── List users (GET /) ────────────────────────────────────────────────────────
@router.get("/", response_model=List[schemas_user.UserResponse])
def list_users(
    role: Optional[str] = Query(None),
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    if current_user.role != models_user.UserRole.juristic:
        raise HTTPException(
            status_code=403,
            detail="เฉพาะ Juristic เท่านั้นที่สามารถดูรายชื่อผู้ใช้งานได้",
        )

    query = (
        db.query(
            models_user.UserModel,
            models_user.ResidentModel.room_no,
            models_user.ResidentModel.building,
            models_user.TechnicianModel.rating,
        )
        .outerjoin(
            models_user.ResidentModel,
            models_user.UserModel.uid == models_user.ResidentModel.uid,
        )
        .outerjoin(
            models_user.TechnicianModel,
            models_user.UserModel.uid == models_user.TechnicianModel.uid,
        )
    )
    if role:
        query = query.filter(models_user.UserModel.role == role)

    results = query.all()
    formatted_users = []
    for user, room_no, building, rating in results:
        signed_image_url = None
        if user.image_url:
            try:
                res = supabase.storage.from_("profile_image").create_signed_url(
                    path=user.image_url, expires_in=3600
                )
                signed_image_url = res["signedUrl"]
            except Exception:
                pass

        formatted_users.append(
            {
                "uid": user.uid,
                "first_name": user.first_name,
                "last_name": user.last_name,
                "role": user.role,
                "status": user.status,
                "image_url": signed_image_url,
                "created_at": user.created_at,
                "updated_at": user.updated_at,
                "room_no": room_no,
                "building": building,
                "rating": rating,
            }
        )
    return formatted_users


# ── Create user (POST /) ──────────────────────────────────────────────────────
@router.post("/")
async def create_user(
    email: str = Form(...),
    password: str = Form(...),
    first_name: str = Form(...),
    last_name: str = Form(...),
    role: models_user.UserRole = Form(...),
    room_no: Optional[str] = Form(None),
    building: Optional[str] = Form(None),
    file: Optional[UploadFile] = File(None),
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    if current_user.role != models_user.UserRole.juristic:
        raise HTTPException(
            status_code=403, detail="เฉพาะ Juristic เท่านั้นที่สามารถสร้างผู้ใช้งานได้"
        )

    try:
        firebase_user = auth.create_user(email=email, password=password)
        image_path = None

        if file:
            ext = file.filename.rsplit(".", 1)[-1] if "." in file.filename else "jpg"
            filename = f"profile_{firebase_user.uid}.{ext}"
            image_path = f"{firebase_user.uid}/{filename}"
            file_bytes = await file.read()
            supabase.storage.from_("profile_image").upload(
                path=image_path,
                file=file_bytes,
                file_options={
                    "content-type": file.content_type,
                    "content-disposition": "inline",
                },
            )

        db_user = models_user.UserModel(
            uid=firebase_user.uid,
            first_name=first_name,
            last_name=last_name,
            role=role,
            image_url=image_path,
        )
        db.add(db_user)
        db.flush()

        if role == models_user.UserRole.resident:
            if not room_no or not building:
                raise HTTPException(
                    status_code=400,
                    detail="room_no and building are required for resident role",
                )
            db.add(
                models_user.ResidentModel(
                    uid=firebase_user.uid, room_no=room_no, building=building
                )
            )
        elif role == models_user.UserRole.technician:
            db.add(models_user.TechnicianModel(uid=firebase_user.uid, rating=0.0))

        db.commit()
        db.refresh(db_user)
        return db_user
    except auth.EmailAlreadyExistsError:
        raise HTTPException(status_code=409, detail="This Email is already exist")
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))


# ── /{uid} routes — ต้องอยู่หลังสุดเสมอ ──────────────────────────────────────


@router.get("/{uid}", response_model=schemas_user.UserResponse)
def get_user(uid: str, db: Session = Depends(get_db)):
    user = (
        db.query(models_user.UserModel).filter(models_user.UserModel.uid == uid).first()
    )
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if user.image_url:
        try:
            res = supabase.storage.from_("profile_image").create_signed_url(
                path=user.image_url, expires_in=3600
            )
            user.image_url = res["signedUrl"]
        except Exception:
            user.image_url = None

    if user.role == models_user.UserRole.resident:
        resident_info = (
            db.query(models_user.ResidentModel)
            .filter(models_user.ResidentModel.uid == uid)
            .first()
        )
        if resident_info:
            user.room_no = resident_info.room_no
            user.building = resident_info.building
    elif user.role == models_user.UserRole.technician:
        tech_info = (
            db.query(models_user.TechnicianModel)
            .filter(models_user.TechnicianModel.uid == uid)
            .first()
        )
        if tech_info:
            user.rating = tech_info.rating

    return user


@router.patch("/{uid}")
def update_user_by_admin(
    uid: str,
    admin_update: schemas_user.AdminUserUpdate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    if current_user.role != models_user.UserRole.juristic:
        raise HTTPException(status_code=403, detail="Not enough permissions")

    db_user = (
        db.query(models_user.UserModel).filter(models_user.UserModel.uid == uid).first()
    )
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")

    update_data = admin_update.model_dump(exclude_unset=True)
    new_room_no = update_data.pop("room_no", None)
    new_building = update_data.pop("building", None)

    for key, value in update_data.items():
        setattr(db_user, key, value)

    if db_user.role == models_user.UserRole.resident and db_user.resident_info:
        if new_room_no is not None:
            db_user.resident_info.room_no = new_room_no
        if new_building is not None:
            db_user.resident_info.building = new_building

    db.commit()
    db.refresh(db_user)
    return db_user


@router.delete("/{uid}")
def delete_user(
    uid: str, db: Session = Depends(get_db), current_user=Depends(get_current_user)
):
    if current_user.role != models_user.UserRole.juristic:
        raise HTTPException(
            status_code=403, detail="เฉพาะ Juristic เท่านั้นที่สามารถลบผู้ใช้งานได้"
        )

    db_user = (
        db.query(models_user.UserModel).filter(models_user.UserModel.uid == uid).first()
    )
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found.")

    image_to_delete = db_user.image_url
    try:
        db.delete(db_user)
        db.commit()
        try:
            auth.delete_user(uid)
        except auth.UserNotFoundError:
            pass
        if image_to_delete:
            try:
                supabase.storage.from_("profile_image").remove([image_to_delete])
            except Exception:
                pass
        return {"message": f"User {uid} deleted successfully."}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))
