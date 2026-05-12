from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from api.endpoints import tickets, users
from models import ticket, user
from database import engine, Base

app = FastAPI()

origins = [
    "http://localhost",
    "http://localhost:8000",
    "*"
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

Base.metadata.create_all(bind=engine)

app.include_router(tickets.router)
app.include_router(users.router)

@app.get("/")
def health_check():
    return {"status": "online"}