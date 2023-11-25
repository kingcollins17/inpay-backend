from typing import Annotated, Any, Dict
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from passlib.context import CryptContext
from jose import jwt, JWTError
from jose.exceptions import ExpiredSignatureError
from datetime import datetime, timedelta

from .models import User

context = CryptContext(schemes=['bcrypt'])
secret = '809d926621bc12f2f17df5b181cb5a4de1174af86bd12fa13496123af0c471b9'
algorithm = 'HS256'

def hash_password(plain: str) -> str:
     return context.hash(secret=plain)
     
def verify_hash(plain, hashed: str) -> bool:
     return context.verify(plain, hashed, scheme='bcrypt')

def tokenify(data: Dict, duration: int = 60) -> str:
     d = data.copy()
     d.update({'exp': datetime.utcnow() + timedelta(minutes=duration)})
     return jwt.encode(d,algorithm=algorithm,key=secret)

def decode_token(token: str) -> Dict[Any, Any]:
     """Raises jose.exceptions.ExpiredSignatureError: if token has expired"""
     return jwt.decode(token=token,key=secret, algorithms=algorithm)



oauth = OAuth2PasswordBearer(tokenUrl="/auth/login")

def authenticate(token: Annotated[str, Depends(oauth)]):
     try:
          user = decode_token(token=token).copy()
          user.pop('exp')
          return User(**user)
     except ExpiredSignatureError as e:
          raise HTTPException(detail="Token has expired!",
                               status_code=status.HTTP_403_FORBIDDEN)
     
