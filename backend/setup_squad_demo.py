#!/usr/bin/env python3
"""
Create 3 other user accounts and add them to the same squad as the test user.
"""
from __future__ import annotations

import sys
import uuid
import os
from datetime import datetime, timedelta
from dotenv import load_dotenv
from supabase import create_client

load_dotenv()

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

DEFAULT_USER_ID = "464f572b-0abc-4317-a36c-4739a0a375ec"

def _uid() -> str:
    return str(uuid.uuid4())

def setup_squad(user_id: str):
    if not SUPABASE_URL or not SUPABASE_KEY:
        print("[ERROR] SUPABASE_URL and SUPABASE_KEY must be set in .env")
        return

    db = create_client(SUPABASE_URL, SUPABASE_KEY)
    
    # 1. Ensure primary user exists
    db.table("User").upsert({
        "id": user_id,
        "name": "You",
        "email": "you@gxbuddy.com",
        "monthlyincome": 1200.0,
        "salarythreshold": 600.0,
        "incometype": "SALARY"
    }).execute()

    # 2. Create 3 other users
    other_users = [
        {"id": _uid(), "name": "Ahmad", "email": "ahmad@gxbuddy.com", "monthlyincome": 1500.0, "salarythreshold": 750.0, "incometype": "SALARY"},
        {"id": _uid(), "name": "Sarah", "email": "sarah@gxbuddy.com", "monthlyincome": 2000.0, "salarythreshold": 1000.0, "incometype": "SALARY"},
        {"id": _uid(), "name": "Lim", "email": "lim@gxbuddy.com", "monthlyincome": 1800.0, "salarythreshold": 900.0, "incometype": "SALARY"},
    ]
    for u in other_users:
        db.table("User").upsert(u).execute()
    
    # 3. Create a squad
    squad_id = _uid()
    deadline = (datetime.utcnow() + timedelta(days=30)).isoformat()
    squad_payload = {
        "id": squad_id,
        "name": "Kaki Save 💰",
        "goalname": "Japan Trip 2026",
        "goalamount": 5000.0,
        "deadline": deadline,
        "createdby": user_id,
        "invitecode": "SAVE2026",
        "privacymode": "ANONYMOUS",
        "isactive": True
    }
    
    # Delete existing squad with same invite code if any
    db.table("Squad").delete().eq("invitecode", "SAVE2026").execute()
    db.table("Squad").insert(squad_payload).execute()
    
    # 4. Add members
    members = [
        {"squadid": squad_id, "userid": user_id, "progressscore": 45.0, "streakdays": 8},
        {"squadid": squad_id, "userid": other_users[0]["id"], "progressscore": 32.0, "streakdays": 5},
        {"squadid": squad_id, "userid": other_users[1]["id"], "progressscore": 78.0, "streakdays": 12},
        {"squadid": squad_id, "userid": other_users[2]["id"], "progressscore": 15.0, "streakdays": 2},
    ]
    
    for m in members:
        db.table("SquadMember").insert(m).execute()

    print(f"Squad setup complete! Squad ID: {squad_id}")
    print(f"Joined {len(members)} members to squad 'Kaki Save'")

if __name__ == "__main__":
    target_user = sys.argv[1] if len(sys.argv) > 1 else DEFAULT_USER_ID
    setup_squad(target_user)
