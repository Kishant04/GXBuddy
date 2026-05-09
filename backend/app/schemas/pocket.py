from pydantic import BaseModel, Field
from typing import Literal, Optional

class SplitRule(BaseModel):
    type:  Literal["percent", "fixed"]
    value: float = Field(..., gt=0)

class PocketCreate(BaseModel):
    name:       str
    target:     float = Field(..., gt=0)
    split_rule: SplitRule

class PocketResponse(BaseModel):
    id:         str
    name:       str
    balance:    float
    target:     float
    split_rule: SplitRule
    percent_complete: float   # balance/target * 100

    class Config:
        from_attributes = True