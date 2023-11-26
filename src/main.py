from fastapi import FastAPI, Depends
from typing import Any, List, Union, Annotated

from .util import authenticate
from .models import *
from .routes.auth import router as auth_router
from .routes.accounts import router as account_router
from .routes.admin import router as admin_router


app = FastAPI()
app.include_router(auth_router, prefix="/auth")
app.include_router(account_router, prefix="/accounts")
app.include_router(admin_router, prefix="/admin")
@app.get('/')
async def index(user: Annotated[User, Depends(authenticate)]):
     return user