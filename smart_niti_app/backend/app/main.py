from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from api.endpoints import tickets

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

app.include_router(tickets.router, prefix="/tickets", tags=["Tickets"])

@app.get("/")
def health_check():
    return {"status": "online"}