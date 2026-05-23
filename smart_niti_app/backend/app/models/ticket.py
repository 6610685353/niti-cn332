from sqlalchemy import Column, Integer, String, Text, Date, Time, DateTime, ForeignKey, Enum
from sqlalchemy.orm import relationship
from database import Base
import datetime
import enum

class TicketCategory(str, enum.Enum):
    plumbing = "plumbing"
    electric = "electric"
    hvac = "hvac"
    other = "other"

class TicketStatus(str, enum.Enum):
    submitted = "submitted"
    assigned = "assigned"
    in_progress = "in_progress"
    done = "done"
    cancelled = "cancelled"

class TicketModel(Base):
    __tablename__ = "tickets"

    id = Column(Integer, primary_key=True, index=True)
    req_user_id = Column(String, ForeignKey("users.uid"))
    assigned_to_id = Column(String, ForeignKey("technicians.uid"), nullable=True)
    assigned_by_id = Column(String, ForeignKey("users.uid"), nullable=True)
    
    category = Column(Enum(TicketCategory))
    title = Column(String)
    detail_desc = Column(Text, nullable=True)
    in_unit_location = Column(String)
    
    target_date = Column(Date)
    start_time = Column(Time)
    end_time = Column(Time)
    
    status = Column(Enum(TicketStatus), default=TicketStatus.submitted)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow)
    closed_at = Column(DateTime, nullable=True)
    images = relationship("TicketImageModel", backref="ticket", lazy="joined")

class TicketImageModel(Base):
    __tablename__ = "ticket_images"

    id = Column(Integer, primary_key=True)
    ticket_id = Column(Integer, ForeignKey("tickets.id"))
    image_url = Column(String)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

class RatingModel(Base):
    __tablename__ = "ratings"

    id = Column(Integer, primary_key=True, index=True)
    ticket_id = Column(Integer, ForeignKey("tickets.id"), unique=True)
    score = Column(Integer)
    comment = Column(Text, nullable=True)