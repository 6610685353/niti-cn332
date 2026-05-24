FROM python:3.11-slim

# ตั้งค่า working directory หลัก
WORKDIR /backend

# คัดลอกและติดตั้งไลบรารี
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# คัดลอกโค้ดทั้งหมดในโฟลเดอร์ app
COPY app/ ./app

# ย้ายตำแหน่งทำงานไปที่โฟลเดอร์ app เพื่อให้ uvicorn หาไฟล์ main.py เจอ
WORKDIR /backend/app

# เปิดพอร์ต 8000
EXPOSE 8000

# คำสั่งสำหรับรัน FastAPI
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]