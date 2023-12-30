from fastapi import APIRouter, Depends, status, HTTPException
from typing import List, Union, Annotated
from ..util import *
from ..models import *
from ..db import *


router  = APIRouter()

@router.delete("/user")
async def remove_user(db: Annotated[aiomysql.Connection, Depends(get_db)],
                       user: Annotated[User, Depends(authenticate)]):
     async with db as connection:
          try:
               await delete_user(user.id, connection=connection) # type: ignore
               return {"details": "User deleted successfully"}
          except Exception as e:
               print(e)	
               raise HTTPException(detail=f"Unable to delete user {user.name} at this moment", 
                                   status_code=status.HTTP_400_BAD_REQUEST)


@router.delete("/account")
async def remove_account(account: int, db: Annotated[aiomysql.Connection, Depends(get_db)],
                          user: Annotated[User, Depends(authenticate)]):
     async with db as connection:
          try:
               await delete_account(account, connection=connection)
               return {"detail": "Successfully removed Account"}
          except Exception as e:
               HTTPException(detail="Unable to remove account at this moment", 
                             status_code=status.HTTP_400_BAD_REQUEST)


@router.put("/password")
async def modify_password(password: str, db: Annotated[aiomysql.Connection, Depends(get_db)],
                           user: Annotated[User, Depends(authenticate)]):
     async with db as connection:
          try:
               await change_password(user.id, new_password=hash_password(password), connection=connection) # type: ignore
               return {"detail": "Password changed successfully"}
          except Exception as e:
               raise HTTPException(detail = "Unable to change password at this moment",
                                    status_code=status.HTTP_400_BAD_REQUEST)

@router.put("/pin")
async def modify_pin(account: int, pin: int,
                      db: Annotated[aiomysql.Connection, Depends(get_db)], 
                     user: Annotated[User, Depends(authenticate)]):
     async with db as connection:
          try:
               await change_pin(account, new_pin=pin, connection=connection)
               return {"detail": "Pin Changed successfully"}
          except Exception as e:
               raise HTTPException(detail="Unable to change pin at this moment", 
                                   status_code=status.HTTP_400_BAD_REQUEST)
          
