from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from firebase_admin import auth
from sqlalchemy.orm import Session
from database import get_db
import models.user as models_user

# ตัวรับ Token จาก Header
security = HTTPBearer()

def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security), db: Session = Depends(get_db)):
    token = credentials.credentials
    try:
        # 1. ยืนยัน Token กับ Firebase และดึง UID
        decoded_token = auth.verify_id_token(token)
        uid = decoded_token.get("uid")
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
        )

    # 2. นำ UID มาค้นหา User ใน PostgreSQL เพื่อเอา Role ไปใช้งานต่อ
    user = db.query(models_user.UserModel).filter(models_user.UserModel.uid == uid).first()
    
    if not user:
        raise HTTPException(status_code=404, detail="User not found in database")
        
    return user