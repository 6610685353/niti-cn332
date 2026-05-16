from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from models import user as models_user
from schemas import user as schemas_user
from firebase_admin import auth

router = APIRouter(
    prefix="/users",
    tags=["Users"]
)

@router.post("/")
def create_user(email: str, password: str, user_info: schemas_user.UserBase, db: Session = Depends(get_db)):
    try:
        firebase_user = auth.create_user(
            email=email,
            password=password
        )

        db_user = models_user.UserModel(
            uid=firebase_user.uid,
            first_name=user_info.first_name,
            last_name=user_info.last_name,
            role=user_info.role
        )
        db.add(db_user)
        db.flush()

        if user_info.role == models_user.UserRole.resident:
            if not user_info.room_no or not user_info.building:
                raise HTTPException(
                    status_code=400, 
                    detail="room_no and building are required for resident role"
                )
        
            db_resident = models_user.ResidentModel(
                uid=firebase_user.uid,
                room_no=user_info.room_no,
                building=user_info.building
            )
            db.add(db_resident)
            
        elif user_info.role == models_user.UserRole.technician:
            db_tech = models_user.TechnicianModel(
                uid=firebase_user.uid,
                rating=0.0
            )
            db.add(db_tech)

        db.commit()
        db.refresh(db_user)

        return db_user
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    
@router.delete("/{uid}")
def delete_user(uid: str, db: Session  =Depends(get_db)):
    db_user = db.query(models_user.UserModel).filter(models_user.UserModel.uid == uid).first()

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

@router.get("/{uid}", response_model=schemas_user.UserResponse)
def get_user(uid: str, db: Session = Depends(get_db)):
    user = db.query(models_user.UserModel).filter(models_user.UserModel.uid == uid).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user