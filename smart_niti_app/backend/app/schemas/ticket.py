from pydantic import BaseModel, ConfigDict
from datetime import datetime, date, time
from typing import Optional, List
from models.ticket import TicketCategory, TicketStatus


# --- Ticket Images ---
class TicketImageBase(BaseModel):
    image_url: str
    image_type: Optional[str] = "resident"


class TicketImageResponse(TicketImageBase):
    id: int
    ticket_id: int
    created_at: datetime
    model_config = ConfigDict(from_attributes=True)


# --- Ratings ---
class RatingBase(BaseModel):
    score: int
    comment: Optional[str] = None


class RatingCreate(RatingBase):
    ticket_id: int


class RatingResponse(RatingBase):
    id: int
    ticket_id: int
    model_config = ConfigDict(from_attributes=True)


# --- Tickets ---
class TicketBase(BaseModel):
    category: TicketCategory
    title: str
    detail_desc: Optional[str] = None
    in_unit_location: str
    target_date: date
    start_time: time
    end_time: time


class TicketCreate(TicketBase):
    req_user_id: str  # UID ของ Resident ผู้แจ้ง


class TicketResponse(TicketBase):
    id: int
    status: TicketStatus
    req_user_id: str
    assigned_to_id: Optional[str] = None
    assigned_by_id: Optional[str] = None
    created_at: datetime
    updated_at: datetime
    closed_at: Optional[datetime] = None

    # ดึงข้อมูลรูปภาพและเรตติ้งที่เกี่ยวข้องมาด้วย (ถ้ามี Relationship ใน Model)
    images: List[TicketImageResponse] = []
    # rating: Optional[RatingResponse] = None

    model_config = ConfigDict(from_attributes=True)


class TicketAssign(BaseModel):
    technician_id: str
