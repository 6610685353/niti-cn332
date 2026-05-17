import os
import uuid
import shutil
from fastapi import APIRouter, Depends, HTTPException, Query, UploadFile, File
from sqlalchemy.orm import Session
from typing import Optional, List
from database import get_db
from models import ticket as models_ticket
from schemas import ticket as schemas_ticket
from auth import get_current_user
from models import user as models_user

router = APIRouter(prefix="/tickets", tags=["Tickets"]
)

IMAGE_DIR = "static/ticket_images"
os.makedirs(IMAGE_DIR, exist_ok=True)

# ── Ticket CRUD ───────────────────────────────────────────────────────────────

@router.post("/", response_model=schemas_ticket.TicketResponse)
def create_ticket(ticket: schemas_ticket.TicketCreate, db: Session = Depends(get_db)):
    db_ticket = models_ticket.TicketModel(**ticket.model_dump())
    db.add(db_ticket)
    db.commit()
    db.refresh(db_ticket)
    return db_ticket

@router.get("/", response_model=List[schemas_ticket.TicketResponse])
def list_tickets(
    req_user_id: Optional[str] = Query(None, description="Filter by resident UID"),
    assigned_to_id: Optional[str] = Query(None, description="Filter by technician UID"), # เพิ่มบรรทัดนี้
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    query = db.query(models_ticket.TicketModel)
    
    # 1. ถ้าเป็น resident ให้เห็นแค่ของตัวเองเท่านั้น (บังคับ)
    if current_user.role == models_user.UserRole.resident:
        query = query.filter(models_ticket.TicketModel.req_user_id == current_user.uid)
        
    # 2. ถ้าเป็น technician หรือ juristic สามารถใช้ฟิลเตอร์กรองได้
    else:
        if req_user_id:
            query = query.filter(models_ticket.TicketModel.req_user_id == req_user_id)
        if assigned_to_id:
            query = query.filter(models_ticket.TicketModel.assigned_to_id == assigned_to_id) # เพิ่มเงื่อนไขกรองช่าง
            
    return query.order_by(models_ticket.TicketModel.created_at.desc()).all()

@router.get("/{ticket_id}", response_model=schemas_ticket.TicketResponse)
def get_ticket_by_id(ticket_id: int, db: Session = Depends(get_db)):
    ticket = db.query(models_ticket.TicketModel).filter(
        models_ticket.TicketModel.id == ticket_id
    ).first()
    if not ticket:
        raise HTTPException(status_code=404, detail="Ticket not found")
    return ticket

@router.patch("/{ticket_id}/status", response_model=schemas_ticket.TicketResponse)
def update_ticket_status(
    ticket_id: int,
    status: models_ticket.TicketStatus,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    if current_user.role != models_user.UserRole.technician:
        raise HTTPException(status_code=403, detail="เฉพาะ Technician เท่านั้นที่เปลี่ยนสถานะได้")

    ticket = db.query(models_ticket.TicketModel).filter(
        models_ticket.TicketModel.id == ticket_id
    ).first()
    
    if not ticket:
        raise HTTPException(status_code=404, detail="Ticket not found")

    if ticket.status == models_ticket.TicketStatus.submitted:
        raise HTTPException(
            status_code=400, 
            detail="ไม่สามารถเปลี่ยนสถานะได้ เนื่องจาก Ticket ยังเป็น 'submitted' (ต้องผ่านการ Assign ก่อน)"
        )

    ticket.status = status
    db.commit()
    db.refresh(ticket)
    return ticket

@router.patch("/{ticket_id}/cancel", response_model=schemas_ticket.TicketResponse)
def cancel_ticket(
    ticket_id: int, 
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user) # ดึงข้อมูลผู้ใช้งานปัจจุบัน
):
    if current_user.role != models_user.UserRole.resident:
        raise HTTPException(status_code=403, detail="เฉพาะ Resident เท่านั้นที่สามารถยกเลิก Ticket ได้")

    ticket = db.query(models_ticket.TicketModel).filter(
        models_ticket.TicketModel.id == ticket_id
    ).first()
    
    if not ticket:
        raise HTTPException(status_code=404, detail="Ticket not found")

    if ticket.req_user_id != current_user.uid:
        raise HTTPException(status_code=403, detail="ไม่สามารถยกเลิกใบแจ้งซ่อมของผู้อื่นได้")

    allowed_statuses = [
        models_ticket.TicketStatus.submitted, 
        models_ticket.TicketStatus.assigned
    ]
    if ticket.status not in allowed_statuses:
        raise HTTPException(
            status_code=400,
            detail=f"ไม่สามารถยกเลิกได้ เนื่องจาก Ticket อยู่ในสถานะ '{ticket.status}'"
        )

    # 5. อัปเดตข้อมูล
    ticket.status = models_ticket.TicketStatus.cancelled
    db.commit()
    db.refresh(ticket)
    return ticket

# ── Ticket Images ──────────────────────────────────────────────────────────────

@router.get("/{ticket_id}/images", response_model=List[schemas_ticket.TicketImageResponse])
def get_ticket_images(ticket_id: int, db: Session = Depends(get_db)):
    """ดึงรูปภาพทั้งหมดของ Ticket"""
    ticket = db.query(models_ticket.TicketModel).filter(
        models_ticket.TicketModel.id == ticket_id
    ).first()
    if not ticket:
        raise HTTPException(status_code=404, detail="Ticket not found")

    return db.query(models_ticket.TicketImageModel).filter(
        models_ticket.TicketImageModel.ticket_id == ticket_id
    ).all()

@router.post("/{ticket_id}/images", response_model=schemas_ticket.TicketImageResponse)
async def upload_ticket_image(
    ticket_id: int,
    file: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    """อัปโหลดรูปภาพสำหรับ Ticket"""
    ticket = db.query(models_ticket.TicketModel).filter(
        models_ticket.TicketModel.id == ticket_id
    ).first()
    if not ticket:
        raise HTTPException(status_code=404, detail="Ticket not found")

    allowed_types = {"image/jpeg", "image/jpg", "image/png", "image/webp"}
    if file.content_type not in allowed_types:
        raise HTTPException(status_code=400, detail="รองรับเฉพาะไฟล์รูปภาพ")

    ext = file.filename.rsplit(".", 1)[-1] if "." in file.filename else "jpg"
    filename = f"ticket_{ticket_id}_{uuid.uuid4().hex[:8]}.{ext}"
    file_path = os.path.join(IMAGE_DIR, filename)

    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    image_url = f"/static/ticket_images/{filename}"
    db_image = models_ticket.TicketImageModel(
        ticket_id=ticket_id,
        image_url=image_url,
    )
    db.add(db_image)
    db.commit()
    db.refresh(db_image)
    return db_image

@router.delete("/{ticket_id}/images/{image_id}", status_code=204)
def delete_ticket_image(ticket_id: int, image_id: int, db: Session = Depends(get_db)):
    """ลบรูปภาพของ Ticket"""
    image = db.query(models_ticket.TicketImageModel).filter(
        models_ticket.TicketImageModel.id == image_id,
        models_ticket.TicketImageModel.ticket_id == ticket_id,
    ).first()
    if not image:
        raise HTTPException(status_code=404, detail="Image not found")

    if image.image_url and "/static/ticket_images/" in image.image_url:
        file_path = image.image_url.lstrip("/")
        if os.path.exists(file_path):
            os.remove(file_path)

    db.delete(image)
    db.commit()

@router.get("/{ticket_id}/rating", response_model=schemas_ticket.RatingResponse)
def get_ticket_rating(ticket_id: int, db: Session = Depends(get_db)):
    rating = db.query(models_ticket.RatingModel).filter(
        models_ticket.RatingModel.ticket_id == ticket_id
    ).first()
    if not rating:
        raise HTTPException(status_code=404, detail="ยังไม่มีการให้คะแนน")
    return rating

@router.post("/{ticket_id}/rating", response_model=schemas_ticket.RatingResponse)
def submit_ticket_rating(
    ticket_id: int,
    rating: schemas_ticket.RatingBase,
    db: Session = Depends(get_db),
):
    ticket = db.query(models_ticket.TicketModel).filter(
        models_ticket.TicketModel.id == ticket_id
    ).first()
    if not ticket:
        raise HTTPException(status_code=404, detail="Ticket not found")

    if ticket.status != models_ticket.TicketStatus.done:
        raise HTTPException(
            status_code=400,
            detail="สามารถให้คะแนนได้เฉพาะ Ticket ที่เสร็จแล้ว",
        )

    if not (0 <= rating.score <= 5):
        raise HTTPException(
            status_code=400,
            detail="คะแนนต้องอยู่ระหว่าง 0 ถึง 5",
        )

    existing = db.query(models_ticket.RatingModel).filter(
        models_ticket.RatingModel.ticket_id == ticket_id
    ).first()
    if existing:
        raise HTTPException(status_code=400, detail="ให้คะแนน Ticket นี้ไปแล้ว")

    db_rating = models_ticket.RatingModel(
        ticket_id=ticket_id,
        score=rating.score,
        comment=rating.comment,
    )
    db.add(db_rating)
    db.commit()
    db.refresh(db_rating)
    return db_rating

@router.patch("/{ticket_id}/assign", response_model=schemas_ticket.TicketResponse)
def assign_ticket(
    ticket_id: int,
    assign_data: schemas_ticket.TicketAssign,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    if current_user.role != models_user.UserRole.juristic:
        raise HTTPException(status_code=403, detail="เฉพาะ Juristic เท่านั้นที่สามารถมอบหมายงานได้")

    ticket = db.query(models_ticket.TicketModel).filter(
        models_ticket.TicketModel.id == ticket_id
    ).first()
    if not ticket:
        raise HTTPException(status_code=404, detail="Ticket not found")

    technician = db.query(models_user.UserModel).filter(
        models_user.UserModel.uid == assign_data.technician_id,
        models_user.UserModel.role == models_user.UserRole.technician
    ).first()
    if not technician:
        raise HTTPException(status_code=404, detail="Technician not found or invalid role")

    ticket.assigned_to_id = assign_data.technician_id
    db.commit()
    db.refresh(ticket)
    return ticket