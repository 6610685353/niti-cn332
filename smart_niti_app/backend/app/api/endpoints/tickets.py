from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from models import ticket as models_ticket
from schemas import ticket as schemas_ticket

router = APIRouter(
    prefix="/tickets",
    tags=["Tickets"]
)

@router.post("/", response_model=schemas_ticket.TicketResponse)
def create_ticket(ticket: schemas_ticket.TicketCreate, db: Session = Depends(get_db)):
    db_ticket = models_ticket.TicketModel(**ticket.model_dump())
    db.add(db_ticket)
    db.commit()
    db.refresh(db_ticket)
    return db_ticket

@router.get("/{ticket_id}", response_model=schemas_ticket.TicketResponse)
def get_ticket(ticket_id: int, db: Session = Depends(get_db)):
    ticket = db.query(models_ticket.TicketModel).filter(models_ticket.TicketModel.id == ticket_id).first()
    if not ticket:
        raise HTTPException(status_code=404, detail="Ticket not found")
    return ticket