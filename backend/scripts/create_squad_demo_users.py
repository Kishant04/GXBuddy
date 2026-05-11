#!/usr/bin/env python3
"""
Create a demo squad with 4 users (Main User, Mei, Kumar, Sarah).
Assign progress scores and streaks as requested.
"""
from __future__ import annotations

import argparse
import os
import sys
import uuid
from datetime import datetime, timedelta

from dotenv import load_dotenv
from supabase import create_client

# Load environment variables
load_dotenv()

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

def _uid() -> str:
    return str(uuid.uuid4())

def main():
    parser = argparse.ArgumentParser(description="Setup squad demo data.")
    parser.add_argument("--main-user-id", required=True, help="UUID of the main test user")
    parser.add_argument("--confirm", action="store_true", help="Confirm the operation")
    args = parser.parse_args()

    if not args.confirm:
        print("[ERROR] Please add --confirm to run the script.")
        sys.exit(1)

    if not SUPABASE_URL or not SUPABASE_KEY:
        print("[ERROR] SUPABASE_URL and SUPABASE_KEY must be set in .env")
        sys.exit(1)

    db = create_client(SUPABASE_URL, SUPABASE_KEY)
    main_user_id = args.main_user_id

    print(f"Setting up squad demo for main user: {main_user_id}")

    # 1. Ensure main user exists
    try:
        db.table("User").upsert({
            "id": main_user_id,
            "name": "Test User",
            "email": "test@gxbuddy.com",
            "monthlyincome": 1200.0,
            "salarythreshold": 800.0,
            "incometype": "SALARY"
        }).execute()
        print("  [OK] Main user verified")
    except Exception as e:
        print(f"  [ERROR] Main user setup failed: {e}")
        sys.exit(1)

    # 2. Create demo users (upsert by predictable UUIDs based on names for repeatability)
    # Using fixed UUIDs derived from namespace for Mei, Kumar, Sarah
    demo_users = [
        {"id": "673f4e1b-8f7a-4c2d-9081-37f2a1b9c8e1", "name": "Mei", "email": "mei.demo@gxbuddy.com"},
        {"id": "429d8a1c-7e6b-5d3e-8192-48a3b2c1d0f5", "name": "Kumar", "email": "kumar.demo@gxbuddy.com"},
        {"id": "b0a9c8d7-e6f5-4a3b-9281-70d6c5b4a321", "name": "Sarah", "email": "sarah.demo@gxbuddy.com"},
    ]

    for u in demo_users:
        db.table("User").upsert({
            **u,
            "monthlyincome": 1500.0,
            "salarythreshold": 750.0,
            "incometype": "SALARY"
        }).execute()
    print(f"  [OK] Created/Updated {len(demo_users)} demo users")

    # 3. Create/Upsert the Squad
    squad_id = "f0a9b8c7-d6e5-4f4a-8372-91a0b1c2d3e4"
    deadline = (datetime.utcnow() + timedelta(days=30)).isoformat()
    invite_code = "BNM2026"
    
    squad_payload = {
        "id": squad_id,
        "name": "Broke No More Squad",
        "goalname": "Save RM500 in 30 days",
        "goalamount": 500.0,
        "deadline": deadline,
        "createdby": main_user_id,
        "invitecode": invite_code,
        "privacymode": "ANONYMOUS",
        "isactive": True
    }

    # Delete existing squad members to start clean for this squad
    db.table("SquadMember").delete().eq("squadid", squad_id).execute()
    # Upsert squad
    db.table("Squad").upsert(squad_payload).execute()
    print(f"  [OK] Squad '{squad_payload['name']}' ready (Code: {invite_code})")

    # 4. Add all 4 users as members with their progress
    members = [
        {"userid": main_user_id, "progressscore": 72.0, "streakdays": 8, "goalstatus": "active"},
        {"userid": demo_users[0]["id"], "progressscore": 65.0, "streakdays": 6, "goalstatus": "active"},
        {"userid": demo_users[1]["id"], "progressscore": 51.0, "streakdays": 5, "goalstatus": "nudge"},
        {"userid": demo_users[2]["id"], "progressscore": 68.0, "streakdays": 7, "goalstatus": "active"},
    ]

    for m in members:
        db.table("SquadMember").insert({
            "id": _uid(),
            "squadid": squad_id,
            **m
        }).execute()
    print(f"  [OK] Added {len(members)} members to squad")

    # 5. Setup streaks for users (important for logic)
    for m in members:
        db.table("Streak").delete().eq("userid", m["userid"]).execute()
        db.table("Streak").insert({
            "userid": m["userid"],
            "currentstreak": m["streakdays"],
            "beststreak": m["streakdays"] + 2,
            "lastsavedate": (datetime.utcnow() - timedelta(days=1)).isoformat()
        }).execute()
    print("  [OK] Users' streaks populated")

    print("\n[DONE] Squad demo data created successfully!")
    print(f"Squad ID: {squad_id}")
    print(f"Invite Code: {invite_code}")

if __name__ == "__main__":
    main()
