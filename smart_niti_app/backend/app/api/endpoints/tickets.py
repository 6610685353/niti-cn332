from fastapi import APIRouter
from schemas.ticket import TicketCreate, TicketResponse

router = APIRouter()

@router.get("/")
def list_tickets():
    pass

@router.post("/")
def create_ticket(ticket: TicketCreate):
    pass