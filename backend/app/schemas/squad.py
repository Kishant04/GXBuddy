from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from enum import Enum

class PrivacyModeEnum(str, Enum):
    anonymous = "ANONYMOUS"
    public    = "PUBLIC"
    private   = "PRIVATE"

class SquadCreate(BaseModel):
    name:         str
    goal_name:    str
    goal_amount:  float = Field(..., gt=0)
    deadline:     datetime
    privacy_mode: PrivacyModeEnum = PrivacyModeEnum.anonymous

class SquadJoin(BaseModel):
    invite_code: str

class MemberView(BaseModel):
    member_index:   int           # 1-based, anonymous label
    progress_score: float
    streak_days:    int
    goal_status:    str
    is_self:        bool

class SquadInsight(BaseModel):
    paragraph:       str
    nudge_targets:   List[str]    # ["Member 2", "Member 4"]
    collective_action: str

class SquadResponse(BaseModel):
    squad_id:    str
    name:        str
    goal_name:   str
    deadline:    datetime
    invite_code: str
    members:     List[MemberView]
    ai_insight:  Optional[SquadInsight]

class RallyRequest(BaseModel):
    target_member_index: int      # 1-based

class RallyResponse(BaseModel):
    sent: bool
    message: str
