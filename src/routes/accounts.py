from fastapi import APIRouter, Depends, status, HTTPException
from fastapi.security import OAuth2PasswordBearer
from typing import Union, Annotated, Any, List
from ..models import *
from ..db import *
from ..util import *
import jose
router = APIRouter()



@router.get("/")
async def get_accounts(db: Annotated[aiomysql.Connection, Depends(get_db)], 
                       user: Annotated[User, Depends(authenticate)]) -> List[Account]:
     """Fetch accounts"""
     async with db as connection:
          try:
               return await fetch_account(user.id, connection=connection) # type: ignore
          except Exception as e:
               raise HTTPException(detail="Unable to fetch accounts for this user", 
                                   status_code=status.HTTP_400_BAD_REQUEST)


@router.get("/find")
async def search_account(account: str,
                         db: Annotated[aiomysql.Connection, Depends(get_db)]) -> Account:
     """Find an account"""
     async with db as connection:
          try:
               res = await find_account(account, connection=connection)
               if res:
                    return res
               raise Exception()
          except Exception as e:
               print(e)
               raise HTTPException(detail=f"Unable to find account with acount no = {account}", 
                                   status_code=status.HTTP_404_NOT_FOUND)

@router.post("/create")
async def add_account(account: Account,db: Annotated[aiomysql.Connection, Depends(get_db)],
                       user: Annotated[User, Depends(authenticate)]) -> Dict[str, str]:
     """Create a new user wallet account associated with the calling user. Requires authentication"""
     async with db as connection:
          try:
               await create_account(account=account, connection=connection)
               return {"details": "Account created successfully"}
          except Exception as e:
               print(e)
               raise HTTPException(detail="Unable to create account for user",
                                    status_code=status.HTTP_400_BAD_REQUEST)
          

@router.get("/deposit")
async def deposit_funds(id: int, amount: float,
                         db: Annotated[aiomysql.Connection, Depends(get_db)], user: Annotated[User, Depends(get_db)]):
     """Endpoint for depositing funds into an account"""     
     async with db as connection:
          try:
               await deposit(id, amount=amount, connection=connection)
               return {"detail": f"${amount} has been added to your account"}
          except Exception as e:
               print(e)
               raise HTTPException(detail=f"Unable to deposit {amount} into your account", 
                                   status_code=status.HTTP_400_BAD_REQUEST)


@router.get("/withdraw")
async def withdraw(id:int, amount: float, db: Annotated[aiomysql.Connection, Depends(get_db)], 
                         user: Annotated[User, Depends(authenticate)]):
     
     """Withdraw funds from users account"""
     async with db as connection:
          try:
               withdrawn = await withdraw_funds(id, amount=amount, connection=connection)
               if withdrawn:
                    return {'detail': f'Funds ${amount} successfully withdrawn'}
               raise Exception()
          except Exception as e:
               raise HTTPException(detail=f"Unable to withdraw ${amount} as this moment", 
                                   status_code=status.HTTP_400_BAD_REQUEST)

@router.post("/transfer")
async def transfer(transaction: Transaction, 
                   db: Annotated[aiomysql.Connection, Depends(get_db)],
                    user: Annotated[User, Depends(authenticate)]):
     """Transfer funds to another user in using Inpay"""
     async with db as connection:
          try:
               transfered = await transfer_funds(transaction=transaction, connection=connection)
               if transfered:
                    return {"details": f"Funds transfer of ${transaction.amount} successful"}
               raise Exception()
          except Exception as e:
               raise HTTPException(detail="Insufficient funds or amount is less than $100",
                                    status_code=status.HTTP_406_NOT_ACCEPTABLE)
          

@router.get("/history")
async def get_history(id: int, out: bool, db: Annotated[aiomysql.Connection, Depends(get_db)], 
                      user: Annotated[User, Depends(authenticate)]):
     """Fetches all transaction history"""
     async with db as connection:
          try:
               if out == True:
                    return await fetch_outgoing_history(account_id=id, connection=connection)
               return await fetch_incoming_history(account_id=id, connection=connection)
          except Exception as e:
               print(e)
               raise HTTPException(detail="Unable to fetch history",
                                    status_code=status.HTTP_404_NOT_FOUND)
          

@router.get("/save")
async def save_funds(id: int, amount: float, db: Annotated[aiomysql.Connection, Depends(get_db)], 
                     user: Annotated[User, Depends(authenticate)]):
     """Save amount of funds in your savings"""
     async with db as connection:
          try:
               await add_savings(id, amount=amount, connection=connection)
               return {"details": f"Saved ${amount} successful"}
          except Exception as e:
               print(e)
               raise HTTPException(detail=f"Unable to save {amount} at this time",
                                    status_code=status.HTTP_400_BAD_REQUEST)
          
@router.get("/save/all")
async def fetch_saved_funds(account: int, db: Annotated[aiomysql.Connection, Depends(get_db)],
                             user: Annotated[User, Depends(authenticate)]) -> List[Savings]:
     """Fetches all user savings"""
     async with db as connection:
          try:
               return await fetch_savings(account, connection=connection)
          except Exception as e:
               raise HTTPException(detail="Unable to fetch your savings at this time",
                                    status_code=status.HTTP_400_BAD_REQUEST)

@router.get("/unlock")
async def unlock_saved_funds(id: int, db: Annotated[aiomysql.Connection, Depends(get_db)],
                              user: Annotated[User, Depends(authenticate)]):
     """Unlock some savings"""
     async with db as connection:
          try:
               await unlock_savings(id,connection=connection)
               return {"detail": "Savings unlocked"}
          except Exception as e:
               raise HTTPException(detail="Unable to unlock savings",
                                    status_code=status.HTTP_400_BAD_REQUEST)


@router.get("/loan")
async def get_loans(account: int, db: Annotated[aiomysql.Connection, Depends(get_db)],
                     user: Annotated[User, Depends(authenticate)]) -> List[Loan]:
     """Fetches users loans"""
     async with db as connection:
          try:
               return await fetch_loans(account,connection=connection)
          except Exception as e:
               raise HTTPException(detail="Unable to fetch your loans at this time!",
                                    status_code=status.HTTP_400_BAD_REQUEST)


@router.post("/loan")
async def add_loan(account: int, amount: float, db: Annotated[aiomysql.Connection, Depends(get_db)],
                    user: Annotated[User, Depends(authenticate)]):
     """Takes out a loan on behalf of the user"""
     async with db as connection:
          try:
               if amount < 100:
                    raise Exception()
               await take_loan(account, amount=amount, connection=connection)
               return {"details": "Loan request successful"}
          except Exception as e:
               # print(e)
               raise HTTPException(detail="Unable to process your loan application at this moment",
                                    status_code=status.HTTP_400_BAD_REQUEST)


@router.get("/loan/repay")
async def repay(loan: int, db: Annotated[aiomysql.Connection, Depends(get_db)], 
                user: Annotated[User, Depends(authenticate)]):
     """Repay borrowed loans. This will fail if user does not have sufficient balance in their account"""
     async with db as connection:
          try:
               await repay_loan(loan, connection=connection)
               return {"detail": "Loan payback successful"}
          except Exception as e:
               print(e)
               raise HTTPException(detail="Unable to repay loan",
                                    status_code=status.HTTP_400_BAD_REQUEST)
