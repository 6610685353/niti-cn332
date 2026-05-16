from pydantic import BaseModel, ConfigDict
from datetime import datetime
from typing import Optional
from models.user import UserRole, UserStatus

class UserBase(BaseModel):
    first_name: str
    last_name: str
    role: UserRole
    status: UserStatus = UserStatus.active
    
    image_url: Optional[str] = None
    room_no: Optional[str] = None
    building: Optional[str] = None

class UserCreate(UserBase):
    uid: str  # UID ที่ได้จาก Firebase Auth

class UserResponse(UserBase):
    uid: str
    created_at: datetime
    updated_at: datetime
    
    model_config = ConfigDict(from_attributes=True)

class ResidentBase(BaseModel):
    room_no: str
    building: str

class ResidentResponse(ResidentBase):
    uid: str
    model_config = ConfigDict(from_attributes=True)