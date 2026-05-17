from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from models import user as models_user
from schemas import user as schemas_user
from firebase_admin import auth
from auth import get_current_user
from typing import Optional, List
from fastapi import Query

router = APIRouter(prefix="/users", tags=["Users"])


@router.post("/")
def create_user(
    email: str,
    password: str,
    user_info: schemas_user.UserBase,
    email: str,
    password: str,
    user_info: schemas_user.UserBase,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
    current_user=Depends(get_current_user),
):
    if current_user.role != models_user.UserRole.juristic:
        raise HTTPException(
            status_code=403, detail="เฉพาะ Juristic เท่านั้นที่สามารถสร้างผู้ใช้งานได้"
        )
        raise HTTPException(
            status_code=403, detail="เฉพาะ Juristic เท่านั้นที่สามารถสร้างผู้ใช้งานได้"
        )

    try:
        firebase_user = auth.create_user(email=email, password=password)
        firebase_user = auth.create_user(email=email, password=password)

        db_user = models_user.UserModel(
            uid=firebase_user.uid,
            first_name=user_info.first_name,
            last_name=user_info.last_name,
            role=user_info.role,
            role=user_info.role,
        )
        db.add(db_user)
        db.flush()

        if user_info.role == models_user.UserRole.resident:
            if not user_info.room_no or not user_info.building:
                raise HTTPException(
                    status_code=400,
                    detail="room_no and building are required for resident role",
                    status_code=400,
                    detail="room_no and building are required for resident role",
                )


            db_resident = models_user.ResidentModel(
                uid=firebase_user.uid,
                room_no=user_info.room_no,
                building=user_info.building,
                building=user_info.building,
            )
            db.add(db_resident)


        elif user_info.role == models_user.UserRole.technician:
            db_tech = models_user.TechnicianModel(uid=firebase_user.uid, rating=0.0)
            db_tech = models_user.TechnicianModel(uid=firebase_user.uid, rating=0.0)
            db.add(db_tech)

        db.commit()
        db.refresh(db_user)

        return db_user
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))




@router.delete("/{uid}")
def delete_user(
    uid: str,
    uid: str,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),  # 1. รับค่า current_user
    current_user=Depends(get_current_user),  # 1. รับค่า current_user
):
    if current_user.role != models_user.UserRole.juristic:
        raise HTTPException(
            status_code=403, detail="เฉพาะ Juristic เท่านั้นที่สามารถลบผู้ใช้งานได้"
        )
        raise HTTPException(
            status_code=403, detail="เฉพาะ Juristic เท่านั้นที่สามารถลบผู้ใช้งานได้"
        )

    db_user = (
        db.query(models_user.UserModel).filter(models_user.UserModel.uid == uid).first()
    )
    db_user = (
        db.query(models_user.UserModel).filter(models_user.UserModel.uid == uid).first()
    )

    if not db_user:
        raise HTTPException(status_code=404, detail="User not found.")


    try:
        db.delete(db_user)
        db.commit()

        try:
            auth.delete_user(uid)
        except auth.UserNotFoundError:
            pass

        return {"message": f"User {uid} deleted successfully."}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/check-email")
def check_email_exists(email: str):
    """เช็คว่า email นี้มีในระบบ Firebase Auth แล้วหรือยัง"""
    try:
        auth.get_user_by_email(email)
        return {"exists": True}
    except auth.UserNotFoundError:
        return {"exists": False}


@router.patch("/me")
def update_my_profile_patch(
    user_update: schemas_user.UserUpdate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    """อัปเดตโปรไฟล์ตัวเอง รองรับการเปลี่ยน email ผ่าน Firebase Admin SDK"""
    db_user = (
        db.query(models_user.UserModel)
        .filter(models_user.UserModel.uid == current_user.uid)
        .first()
    )
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")

    update_data = user_update.model_dump(exclude_unset=True)

    # อัปเดต email ใน Firebase Auth (email ไม่ได้เก็บใน DB)
    new_email = update_data.pop("email", None)
    if new_email:
        try:
            auth.update_user(current_user.uid, email=new_email)
        except auth.EmailAlreadyExistsError:
            raise HTTPException(
                status_code=409,
                detail="This email is already in use by another account.",
            )
        except Exception as e:
            raise HTTPException(status_code=400, detail=str(e))

    # อัปเดต field อื่น ๆ ใน DB
    for key, value in update_data.items():
        setattr(db_user, key, value)

    db.commit()
    db.refresh(db_user)
    return db_user

@router.get("/", response_model=List[schemas_user.UserResponse])
def list_users(
    role: Optional[str] = Query(None, description="filter by role e.g. technician"),
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    if current_user.role != models_user.UserRole.juristic:
        raise HTTPException(status_code=403, detail="เฉพาะ Juristic เท่านั้นที่สามารถดูรายชื่อผู้ใช้งานได้")

    query = db.query(models_user.UserModel)
    
    if role:
        query = query.filter(models_user.UserModel.role == role)
        
    return query.all()

@router.get("/{uid}", response_model=schemas_user.UserResponse)
def get_user(uid: str, db: Session = Depends(get_db)):
    user = (
        db.query(models_user.UserModel).filter(models_user.UserModel.uid == uid).first()
    )
    user = (
        db.query(models_user.UserModel).filter(models_user.UserModel.uid == uid).first()
    )
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user



@router.put("/me")
def update_my_profile(
    user_update: schemas_user.UserUpdate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    db_user = (
        db.query(models_user.UserModel)
        .filter(models_user.UserModel.uid == current_user.uid)
        .first()
    )
def update_my_profile(
    user_update: schemas_user.UserUpdate,
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

    update_data = user_update.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_user, key, value)

    db.commit()
    db.refresh(db_user)
    return db_user



@router.put("/{uid}")
def update_user_by_admin(
    uid: str,
    admin_update: schemas_user.AdminUserUpdate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
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

