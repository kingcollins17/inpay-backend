from fastapi import APIRouter, Depends, HTTPException, status
from typing import Any, List, Annotated
from ..db import *
from ..models import *
from ..util import *

router = APIRouter()

@router.post("/login")
async def login_user(user: User, db: Annotated[aiomysql.Connection, Depends(get_db)]):
     """Login a user"""
     async with db as conn:
          try:
               found_user = await find_user(user.email, connection=conn)
               if found_user and verify_hash(user.password, found_user.password): # type: ignore
                    return {'token': tokenify(data={'id': found_user.id, 'name': found_user.name, 'email': found_user.email}, duration=60)}
               else:
                    return {"detail": "Invalid Login details"}
          except Exception as e:
               print(e)
               raise HTTPException(detail='unable to login user',
                               status_code=status.HTTP_400_BAD_REQUEST)


@router.post("/register")
async def register_user(user: User, db: Annotated[aiomysql.Connection, Depends(get_db)]):
     """Register a new user account"""
     async with db as connection:
          try:
               await create_user(User(name=user.name, email=user.email,
                                       password=hash_password(user.password)), connection=connection) # type: ignore
               return {'details': 'registration successful'}
          except Exception as e:
               print(e)
               raise HTTPException(detail='Unable to register user', 
                                   status_code=status.HTTP_400_BAD_REQUEST)