#!/usr/bin/env python3
"""
Seed the Supabase database with demo data for the test user.

Run from the backend/ directory:
    python seed.py

Or pass a different user ID:
    python seed.py <user_uuid>
"""
from __future__ import annotations

import calendar
import sys
import uuid
from datetime import datetime, timedelta

from dotenv import load_dotenv

load_dotenv()

import os
from supabase import create_client

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

DEFAULT_USER_ID = "464f572b-0abc-4317-a36c-4739a0a375ec"


def _uid() -> str:
    return str(uuid.uuid4())


def seed(user_id: str) -> None:
    if not SUPABASE_URL or not SUPABASE_KEY:
        print("[ERROR] SUPABASE_URL and SUPABASE_KEY must be set in .env")
        sys.exit(1)

    db = create_client(SUPABASE_URL, SUPABASE_KEY)
    now = datetime.utcnow()

    print(f"Seeding data for user: {user_id}")

    # ── Ensure User record exists first (FK required by Pocket, etc.) ─────────
    # Real User table columns: id, name, email, monthlyincome, salarythreshold, incometype, createdat
    user_payload = {
        "id": user_id,
        "name": "Test User",
        "email": "test@gxbuddy.com",
        "monthlyincome": 1200.0,
        "salarythreshold": 800.0,
        "incometype": "SALARY",
    }
    try:
        existing = db.table("User").select("id").eq("id", user_id).limit(1).execute()
        if existing.data:
            db.table("User").update({k: v for k, v in user_payload.items() if k != "id"}).eq("id", user_id).execute()
            print("  [OK] Updated user profile")
        else:
            db.table("User").insert(user_payload).execute()
            print("  [OK] Created user profile")
    except Exception as e:
        print(f"  [ERROR] User profile failed: {e}")
        print("  Cannot proceed without User record (FK constraint).")
        return

    # ── Clear existing demo data ──────────────────────────────────────────────
    for table in ["Pocket", "Budget", "Transaction", "Streak", "BillReminder", "Alert"]:
        try:
            db.table(table).delete().eq("userid", user_id).execute()
            print(f"  [OK] Cleared {table}")
        except Exception as e:
            print(f"  [WARN] Could not clear {table}: {e}")

    # ── Pockets ───────────────────────────────────────────────────────────────
    pockets = [
        {
            "id": _uid(), "userid": user_id,
            "name": "Emergency Fund", "balance": 240.00, "target": 580.00,
            "splitrule": {"type": "percent", "value": 20.0},
        },
        {
            "id": _uid(), "userid": user_id,
            "name": "PTPTN", "balance": 120.00, "target": 500.00,
            "splitrule": {"type": "percent", "value": 10.0},
        },
        {
            "id": _uid(), "userid": user_id,
            "name": "Travel Fund", "balance": 90.00, "target": 300.00,
            "splitrule": {"type": "percent", "value": 5.0},
        },
    ]
    try:
        db.table("Pocket").insert(pockets).execute()
        print(f"  [OK] Inserted {len(pockets)} pockets")
    except Exception as e:
        print(f"  [WARN] Pocket insert failed: {e}")

    # ── Budget ────────────────────────────────────────────────────────────────
    # Monthly budget for the current month (scope enum requires "MONTHLY")
    month_start = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
    last_day = calendar.monthrange(now.year, now.month)[1]
    month_end = now.replace(day=last_day, hour=23, minute=59, second=59, microsecond=0)

    try:
        db.table("Budget").insert({
            "id": _uid(), "userid": user_id,
            "scope": "MONTHLY", "category": None,
            "weeklylimit": "400.00",
            "periodstart": month_start.isoformat(),
            "periodend": month_end.isoformat(),
            "alert60": False, "alert80": False, "alert100": False,
        }).execute()
        print("  [OK] Inserted budget")
    except Exception as e:
        print(f"  [WARN] Budget insert failed: {e}")

    # ── Transactions ──────────────────────────────────────────────────────────
    transactions = [
        {
            "id": _uid(), "userid": user_id,
            "merchant": "GrabFood", "amount": "32.00", "category": "FOOD",
            "source": "BANK", "status": "POSTED", "isbnpl": False,
            "timestamp": (now - timedelta(hours=3)).isoformat(),
            "riskscore": 42.0,
        },
        {
            "id": _uid(), "userid": user_id,
            "merchant": "Touch n Go", "amount": "15.00", "category": "TRANSPORT",
            "source": "BANK", "status": "POSTED", "isbnpl": False,
            "timestamp": (now - timedelta(days=1, hours=2)).isoformat(),
            "riskscore": 12.0,
        },
        {
            "id": _uid(), "userid": user_id,
            "merchant": "Shopee", "amount": "89.00", "category": "SHOPPING",
            "source": "BANK", "status": "POSTED", "isbnpl": False,
            "timestamp": (now - timedelta(days=2, hours=1)).isoformat(),
            "riskscore": 68.0,
        },
        {
            "id": _uid(), "userid": user_id,
            "merchant": "Spotify", "amount": "14.90", "category": "ENTERTAINMENT",
            "source": "BANK", "status": "POSTED", "isbnpl": False,
            "timestamp": (now - timedelta(days=3, hours=6)).isoformat(),
            "riskscore": 8.0,
        },
        {
            "id": _uid(), "userid": user_id,
            "merchant": "Salary Credit", "amount": "1200.00", "category": "OTHER",
            "source": "BANK", "status": "POSTED", "isbnpl": False,
            "timestamp": (now - timedelta(days=5)).isoformat(),
            "riskscore": 0.0,
        },
        {
            "id": _uid(), "userid": user_id,
            "merchant": "GrabFood", "amount": "28.50", "category": "FOOD",
            "source": "BANK", "status": "POSTED", "isbnpl": False,
            "timestamp": (now - timedelta(days=1, hours=8)).isoformat(),
            "riskscore": 38.0,
        },
    ]
    try:
        db.table("Transaction").insert(transactions).execute()
        print(f"  [OK] Inserted {len(transactions)} transactions")
    except Exception as e:
        print(f"  [WARN] Transaction insert failed: {e}")

    # ── Streak ────────────────────────────────────────────────────────────────
    try:
        db.table("Streak").insert({
            "id": _uid(), "userid": user_id,
            "currentstreak": 8, "beststreak": 12,
            "lastsavedate": (now - timedelta(days=1)).isoformat(),
        }).execute()
        print("  [OK] Inserted streak")
    except Exception as e:
        print(f"  [WARN] Streak insert failed: {e}")

    # ── Bill Reminders ────────────────────────────────────────────────────────
    bills = [
        {
            "id": _uid(), "userid": user_id,
            "name": "Phone bill", "amount": "68.00",
            "duedate": (now + timedelta(days=5)).isoformat(),
            "ispaid": False,
        },
        {
            "id": _uid(), "userid": user_id,
            "name": "Netflix", "amount": "17.00",
            "duedate": (now + timedelta(days=10)).isoformat(),
            "ispaid": False,
        },
    ]
    try:
        db.table("BillReminder").insert(bills).execute()
        print(f"  [OK] Inserted {len(bills)} bill reminders")
    except Exception as e:
        print(f"  [WARN] BillReminder insert failed: {e}")

    print(f"\n[DONE] Seed complete for {user_id}")


if __name__ == "__main__":
    target_user = sys.argv[1] if len(sys.argv) > 1 else DEFAULT_USER_ID
    seed(target_user)
