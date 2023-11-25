from pydantic import BaseModel, Field
from typing import List, Union, Any
import datetime


class User(BaseModel):
     id: Union[int, None] = Field(default=None, description='The ID of this user')
     name: Union[str, None] = Field(default=None, description='The name identifier')
     email: str
     password: Union[str, None] = Field(default=None, description='User password')

class Account(BaseModel):
     id: Union[int, None] = None
     name: Union[str, None] =  None
     account_no: Union[str, None] = None
     balance: float | None = None
     pin: int
     user_id: int

class Transaction(BaseModel):
     id: Union[int, None] = None
     hash: Union[str, None] = None
     amount: float
     sender_id: int
     recipient_id: int

class Savings(BaseModel):
     id: Union[int, None]  = None
     amount: float
     date: Union[datetime.datetime, None]
     account_id: int