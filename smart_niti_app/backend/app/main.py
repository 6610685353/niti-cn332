import os
import firebase_admin
from fastapi.staticfiles import StaticFiles
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from api.endpoints import tickets, users
from models import ticket, user
from database import engine, Base
from firebase_admin import credentials
import os
import json

firebase_cred_json = os.getenv("FIREBASE_CREDENTIALS_JSON")
if firebase_cred_json:
    cred = credentials.Certificate(json.loads(firebase_cred_json))
else:
    cred = credentials.Certificate("firebase-credentials.json")  # local fallback

firebase_admin.initialize_app(cred)

app = FastAPI(
    docs_url=None,
    redoc_url=None,
    openapi_url=None,
)

origins = [
    "http://localhost",
    "http://localhost:8000",
    "*",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

Base.metadata.create_all(bind=engine)

# ── Static files (รูปภาพที่ upload) ──────────────────────────────────────────
# สร้าง directory ก่อนถ้ายังไม่มี
os.makedirs("static/ticket_images", exist_ok=True)
os.makedirs("static/avatars", exist_ok=True)
 
# Mount /static → เข้าถึงได้ที่ http://localhost:8000/static/...
app.mount("/static", StaticFiles(directory="static"), name="static")

app.include_router(tickets.router)
app.include_router(users.router)

@app.get("/health")
def health_check():
    return {"status": "online"}