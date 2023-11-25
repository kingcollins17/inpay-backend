import pymysql
import aiomysql
from typing import Any, Dict, Union, List
import asyncio
import random
# from models import Account, Loan, Savings, Transaction, User
from .models import Account, Loan, Savings, Transaction, User


db_credentials  = {'user': 'root', 'host': 'localhost', 'port': 3306, 
                'password': 'mysqlking@02', 'db': 'inpay'}


def get_db():
     db: Any | None = None
     try:
          db  = aiomysql.connect(**db_credentials)
          yield db
     finally:
          if db:
               db.close()

def generate_account_no():
     no = "310"
     for i in range(7):
          no += str(random.choice([1,5,3,6,7,8,9,2,0]))

     return no

def create_connection(credentials: Dict[str, Any]):
     return aiomysql.connect(**credentials)

async def create_user(user: User, *, connection: aiomysql.Connection):
     query = "INSERT INTO users (name, email, password) VALUES (%s,%s,%s)"
     async with connection.cursor() as cursor:
          await cursor.execute(query=query, args=(user.name, user.email, user.password))
     
     await connection.commit()
     
     
async def create_account(account: Account, *,connection: aiomysql.Connection):
     query = "INSERT INTO accounts (name, account_no, pin, user_id) VALUES (%s, %s, %s, %s)"
     async with connection.cursor() as cursor:
          await cursor.execute(query=query, args=(account.name, generate_account_no(), account.pin, account.user_id))
     
     await connection.commit()


async def delete_user(id: int, *, connection: aiomysql.Connection):
     async with connection.cursor() as cursor:
          await cursor.execute(query=f"DELETE FROM users WHERE id = {id}")

     await connection.commit()

async def delete_account(id: int, *, connection: aiomysql.Connection):
     async with connection.cursor() as cursor:
          await cursor.execute(query = f"DELETE FROM accounts WHERE id = {id}")
     
     await connection.commit()

async def change_password(user_id: int, * ,new_password: str, connection: aiomysql.Connection):
     async with connection.cursor() as cursor:
          await cursor.execute(query="UPDATE users SET password = %s WHERE id = %s",
                                args=(new_password, user_id))
     await connection.commit()




async def change_pin(account_id: int, *, new_pin: int, connection: aiomysql.Connection):
     if len(str(new_pin)) != 4:
          raise Exception('Pin cannot be greater than  or less than 4 digits')
     async with connection.cursor() as cursor:
          await cursor.execute(query="UPDATE accounts SET pin = %s WHERE id = %s", args = (new_pin, account_id))

     await connection.commit()



async def deposit(account_id: int,*, amount: float, connection: aiomysql.Connection):
     if (amount < 100.0): raise Exception('Amount cannot be less than $100')
     async with connection.cursor() as cursor:
          await cursor.execute(query="UPDATE accounts SET balance = balance + %s WHERE id = %s", args =(amount, account_id))
     await connection.commit()

async def transfer_funds(transaction: Transaction, *, connection: aiomysql.Connection) -> bool:
     """Returns true if funds were successfully transferred else, falls"""
     if transaction.amount < 100: raise Exception('Amount cannot be less than $100') 
     try:
          async with connection.cursor() as cursor:
               await cursor.execute(query="INSERT INTO transactions (hash, sender_id, recipient_id, amount) VALUES (%s,%s,%s,%s)",
                                args = (_hash_session(32), transaction.sender_id, transaction.recipient_id, transaction.amount))
          await connection.commit()
          return True
     except pymysql.err.OperationalError as e:
          return False

async def withdraw_funds(account_id: int, *, amount: float, connection: aiomysql.Connection):
     if (amount < 100): raise Exception('Amount cannot be less than $100')
     try:
          async with connection.cursor() as cursor:
               await cursor.execute(query="UPDATE accounts SET balance = balance - %s WHERE id = %s", args=(amount, account_id))
          await connection.commit()
          return True
     except pymysql.err.OperationalError as e:
          return False
     

async def unlock_savings(id: int,*, connection: aiomysql.Connection):
     async with connection.cursor() as cursor:
          await cursor.execute(query=f"DELETE FROM savings WHERE id = {id}")
     
     await connection.commit()




async def find_user(email: str, *, connection: aiomysql.Connection):
     async with connection.cursor(aiomysql.DictCursor) as cursor:
          await cursor.execute(query="SELECT * FROM users WHERE email = %s", args=(email,))
          res = await cursor.fetchone()
          if res:
               return User(**res)


async def fetch_account(user_id: int, *, connection: aiomysql.Connection):
     async with connection.cursor(aiomysql.DictCursor) as cursor:
          await cursor.execute(query="SELECT * FROM accounts WHERE user_id = %s", args=(user_id,))
          res = await cursor.fetchall()

          return [Account(**value) for value in res]


async def find_account(account_no: str, *, connection: aiomysql.Connection):
     async with connection.cursor(aiomysql.DictCursor) as cursor:
          await cursor.execute(query=f"SELECT * FROM accounts WHERE account_no = {account_no}")
          res = await cursor.fetchone()
          if res:
               return Account(**res)


async def fetch_savings(account_id: int, *, connection: aiomysql.Connection):
     async with connection.cursor(aiomysql.DictCursor) as cursor:
          await cursor.execute(query=f"SELECT * FROM savings WHERE account_id = {account_id}")
          res= await cursor.fetchall()
          
          return [Savings(**value) for value in res]



async def fetch_outgoing_history(account_id: int, *, connection: aiomysql.Connection):
     async with connection.cursor(aiomysql.DictCursor) as cursor:
           await cursor.execute(query="SELECT transactions.hash as session_id, transactions.amount, transactions.recipient_id, accounts.name as recipient FROM transactions LEFT JOIN accounts ON transactions.recipient_id = accounts.id WHERE transactions.sender_id = %s", args=(account_id,))

     return await cursor.fetchall()


async def fetch_incoming_history(account_id: int, *, connection: aiomysql.Connection):
     async with connection.cursor(aiomysql.DictCursor) as cursor:
          await cursor.execute(query="SELECT transactions.hash as session_id, transactions.amount, transactions.sender_id, accounts.name as sender FROM transactions LEFT JOIN accounts ON transactions.sender_id = accounts.id WHERE transactions.recipient_id = %s", args=(account_id))

     return await cursor.fetchall()


async def add_savings(account_id: int, *, amount: float, connection: aiomysql.Connection):
     async with connection.cursor() as cursor:
          await cursor.execute(query="INSERT INTO savings (amount, account_id) VALUES (%s,%s)",args = (amount, account_id))
     await connection.commit()


async def take_loan(account_id: int, *, amount: float, connection: aiomysql.Connection):
     async with connection.cursor() as cursor:
          await cursor.execute(query="INSERT INTO loans(amount, account_id) VALUES (%s,%s)",
                                args=(amount, account_id))
     
     await connection.commit()

async def repay_loan(loan_id: int, *, connection: aiomysql.Connection):
     async with connection.cursor() as cursor:
          await cursor.execute(query=f"DELETE FROM loans WHERE id = {loan_id}")
     
     await connection.commit()



async def fetch_loans(account_id: int, *, connection: aiomysql.Connection):
     async with connection.cursor(aiomysql.DictCursor) as cursor:
          await cursor.execute(query=f"SELECT * FROM loans WHERE account_id = {account_id}")
          res= await cursor.fetchall()
          return [Loan(**value) for value in res]
     

def _hash_session(count: int):
     digits = 'abcdef1234567890ABCDEF'
     res = ''
     for i in range(count):
          res += random.choice(digits)
     
     return res

# async def main():
     # async with create_connection(db_credentials) as conn:
          # await create_user(User(name='Melanie Hickson', email='hickson@yahoo.com', password='gene'), connection= conn)
          # await create_account(account = Account(name='Test Account', pin=3456, user_id=1) , connection=conn)
          # await delete_account(8, connection=conn)
          # await delete_user(8, connection= conn)
          # await change_password(7, new_password='strongerpwd', connection=conn)
          # await change_pin(7, new_pin=2001, connection=conn)
          # await deposit(2, amount=1000, connection=conn)
          # print(generate_hash(32))
          # res = await transfer_funds(Transaction(sender_id=3, recipient_id=1, amount=1150), connection=conn)
          # print(res)
          # print(await withdraw_funds(2, amount=100, connection=conn))
          # print(await fetch_account(user_id = 1, connection=conn))
          # print(await find_user(email='mikerob@gmail.com', connection=conn))
          # print(await fetch_outgoing_history(1, connection=conn))
          # print(await fetch_incoming_history(2, connection=conn))
          # print(generate_account_no())
          # await add_savings(2, amount = 400, connection=conn)
          # await unlock_savings(2, connection=conn)
          # print(await fetch_savings(2, connection=conn))
          # await take_loan(4, amount=200000, connection=conn)
          # print(await fetch_loans(4, connection=conn))
          # await repay_loan(3, connection=conn)
          # pass
# asyncio.run(main())

