from sqlalchemy import Column, String, Float, DateTime, ForeignKey, Enum
from database import Base
import datetime
import enum

class UserRole(str, enum.Enum):
    resident = "resident"
    technician = "technician"
    juristic = "juristic"

class UserStatus(str, enum.Enum):
    active = "active"
    inactive = "inactive"

class UserModel(Base):
    __tablename__ = "users"

    uid = Column(String, primary_key=True)
    first_name = Column(String)
    last_name = Column(String)
    role = Column(Enum(UserRole))
    status = Column(Enum(UserStatus), default=UserStatus.active)
    image_url = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow)

class ResidentModel(Base):
    __tablename__ = "residents"

    uid = Column(String, ForeignKey("users.uid"), primary_key=True)
    room_no = Column(String)
    building = Column(String)

class TechnicianModel(Base):
    __tablename__ = "technicians"

    uid = Column(String, ForeignKey("users.uid"), primary_key=True)
    rating = Column(Float, default=0.0)