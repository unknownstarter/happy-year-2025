from pydantic import BaseModel
from datetime import datetime

class FortuneRequest(BaseModel):
    name: str
    gender: str
    birthDateTime: datetime

class FortuneResponse(BaseModel):
    fortune: dict[str, str] 