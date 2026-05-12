from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from models import user as models_user
from schemas import user as schemas_user

router = APIRouter(
    prefix="/users",
    tags=["Users"]
)

@router.post("/", response_model=schemas_user.UserResponse)
def create_user(user: schemas_user.UserCreate, db: Session = Depends(get_db)):
    db_user = models_user.UserModel(**user.model_dump())
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

@router.get("/{uid}", response_model=schemas_user.UserResponse)
def get_user(uid: str, db: Session = Depends(get_db)):
    user = db.query(models_user.UserModel).filter(models_user.UserModel.uid == uid).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user