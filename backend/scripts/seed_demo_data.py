#!/usr/bin/env python3
import argparse
import sys
import uuid
from datetime import datetime, timedelta
from decimal import Decimal
import os
from dotenv import load_dotenv
from supabase import create_client, Client

# Load environment variables from backend/.env
# Assuming script is run from project root or backend/
load_dotenv(".env")

def _uid() -> str:
    return str(uuid.uuid4())

def seed_demo_data(user_id: str, confirm: bool):
    if not confirm:
        print("Error: Please provide the --confirm flag to proceed.")
        sys.exit(1)

    url = os.getenv("SUPABASE_URL")
    key = os.getenv("SUPABASE_SERVICE_ROLE_KEY") or os.getenv("SUPABASE_KEY")

    if not url or not key:
        print("Error: SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set in .env")
        sys.exit(1)

    # Do not print the full key for security
    print(f"Connecting to Supabase at: {url}")
    db: Client = create_client(url, key)

    now = datetime.utcnow()
    # Week bounds for budgets and transactions
    start_of_week = now - timedelta(days=now.weekday())
    start_of_week = start_of_week.replace(hour=0, minute=0, second=0, microsecond=0)
    end_of_week = start_of_week + timedelta(days=7)

    print(f"Seeding demo data for user: {user_id}")

    # 1. Upsert User Profile
    user_payload = {
        "id": user_id,
        "name": "Aiman Hakim",
        "email": "aiman@gxbuddy.com",
        "monthlyincome": 1200.0,
        "salarythreshold": 800.0,
        "incometype": "SALARY",
        # "push_enabled": True,
        # "whatsapp_enabled": False,
        # "telegram_enabled": False,
        # "anonymous_squad": False,
        # "hide_balances": True,
        # "card_frozen": False,
        # "weekly_spending_limit": 400.0,
    }

    db.table("User").upsert(user_payload).execute()
    print("  [OK] User profile upserted")

    # 2. Clear existing data for this user to ensure idempotency
    tables_to_clear = ["Pocket", "Budget", "Transaction", "Streak", "BillReminder", "Alert", "SquadMember"]
    for table in tables_to_clear:
        try:
            # Note: "userid" is the column name in initial_schema.sql
            db.table(table).delete().eq("userid", user_id).execute()
        except Exception as e:
            print(f"  [WARN] Failed to clear {table}: {e}")
    print(f"  [OK] Cleared existing data for tables: {', '.join(tables_to_clear)}")

    # 3. Seed Budgets
    budgets = [
        {
            "id": _uid(), "userid": user_id, "scope": "overall", "category": None,
            "weeklylimit": 400.0, "periodstart": start_of_week.isoformat(), "periodend": end_of_week.isoformat()
        },
        {
            "id": _uid(), "userid": user_id, "scope": "category", "category": "FOOD",
            "weeklylimit": 150.0, "periodstart": start_of_week.isoformat(), "periodend": end_of_week.isoformat()
        },
        {
            "id": _uid(), "userid": user_id, "scope": "category", "category": "TRANSPORT",
            "weeklylimit": 100.0, "periodstart": start_of_week.isoformat(), "periodend": end_of_week.isoformat()
        },
        {
            "id": _uid(), "userid": user_id, "scope": "category", "category": "SHOPPING",
            "weeklylimit": 150.0, "periodstart": start_of_week.isoformat(), "periodend": end_of_week.isoformat()
        },
    ]
    db.table("Budget").insert(budgets).execute()
    print("  [OK] Budgets seeded")

    # 4. Seed Transactions
    transactions = [
        {"merchant": "GrabFood", "amount": 32.00, "category": "FOOD", "timestamp": (now - timedelta(hours=2)).isoformat()},
        {"merchant": "Touch 'n Go", "amount": 15.00, "category": "TRANSPORT", "timestamp": (now - timedelta(hours=5)).isoformat()},
        {"merchant": "Shopee", "amount": 89.00, "category": "SHOPPING", "timestamp": (now - timedelta(days=1)).isoformat()},
        {"merchant": "Spotify", "amount": 14.90, "category": "LIFESTYLE", "timestamp": (now - timedelta(days=2)).isoformat()},
        {"merchant": "GrabFood", "amount": 28.50, "category": "FOOD", "timestamp": (now - timedelta(days=3)).isoformat()},
    ]
    txn_payload = []
    for t in transactions:
        txn_payload.append({
            "id": _uid(),
            "userid": user_id,
            "merchant": t["merchant"],
            "amount": t["amount"],
            "category": t["category"],
            "source": "BANK",
            "status": "POSTED",
            "timestamp": t["timestamp"]
        })
    db.table("Transaction").insert(txn_payload).execute()
    print("  [OK] Transactions seeded")

    # 5. Seed Pockets
    pockets = [
        {"name": "Emergency Fund", "balance": 240.0, "target": 580.0, "rule_type": "percent", "rule_value": 20.0},
        {"name": "PTPTN", "balance": 120.0, "target": 500.0, "rule_type": "percent", "rule_value": 10.0},
        {"name": "Travel", "balance": 90.0, "target": 300.0, "rule_type": "percent", "rule_value": 5.0},
    ]
    pocket_payload = []
    for p in pockets:
        pocket_payload.append({
            "id": _uid(),
            "userid": user_id,
            "name": p["name"],
            "balance": p["balance"],
            "target": p["target"],
            "splitrule": {"type": p["rule_type"], "value": p["rule_value"]}
        })
    db.table("Pocket").insert(pocket_payload).execute()
    print("  [OK] Pockets seeded")

    # 6. Seed Bill Reminder
    bill = {
        "id": _uid(),
        "userid": user_id,
        "name": "Phone bill",
        "amount": 68.0,
        "duedate": (now + timedelta(days=2)).isoformat(),
        "ispaid": False
    }
    db.table("BillReminder").insert(bill).execute()
    print("  [OK] Bill reminder seeded")

    # 7. Seed Alerts
    alerts = [
        {
            "id": _uid(), "userid": user_id, "severity": "alert", "actiontaken": False,
            "message": "Third GrabFood order this week. Want to round up RM2 into Emergency Fund?",
            "createdat": now.isoformat()
        },
        {
            "id": _uid(), "userid": user_id, "severity": "alert", "actiontaken": False,
            "message": "Phone bill RM68 due in 2 days.",
            "createdat": (now - timedelta(minutes=5)).isoformat()
        },
    ]
    db.table("Alert").insert(alerts).execute()
    print("  [OK] Alerts seeded")

    # 8. Seed Streak
    streak = {
        "id": _uid(),
        "userid": user_id,
        "currentstreak": 8,
        "beststreak": 8,
        "lastsavedate": now.isoformat()
    }
    db.table("Streak").insert(streak).execute()
    print("  [OK] Streak seeded")

    # 9. Seed Squad
    # Check if squad exists or create new
    squad_name = "Broke No More Squad"
    invite_code = "GXDEMO25"
    
    # Try to find existing squad with this name or code to avoid duplicates
    existing_squad = db.table("Squad").select("id").eq("invitecode", invite_code).execute()
    
    if existing_squad.data:
        squad_id = existing_squad.data[0]["id"]
        db.table("Squad").update({
            "name": squad_name,
            "goalname": "Save RM500 in 30 days",
            "goalamount": 500.0,
            "deadline": (now + timedelta(days=30)).isoformat(),
            "privacymode": "ANONYMOUS",
            "isactive": True
        }).eq("id", squad_id).execute()
        # Clean up existing members if we want a fresh demo
        db.table("SquadMember").delete().eq("squadid", squad_id).execute()
    else:
        squad_id = _uid()
        db.table("Squad").insert({
            "id": squad_id,
            "name": squad_name,
            "goalname": "Save RM500 in 30 days",
            "goalamount": 500.0,
            "deadline": (now + timedelta(days=30)).isoformat(),
            "createdby": user_id,
            "invitecode": invite_code,
            "privacymode": "ANONYMOUS",
            "isactive": True
        }).execute()
    
    print(f"  [OK] Squad '{squad_name}' (ID: {squad_id}) ready")

    # Add members to squad
    # Main user
    db.table("SquadMember").insert({
        "id": _uid(),
        "squadid": squad_id,
        "userid": user_id,
        "progressscore": 72.0,
        "streakdays": 8,
        "goalstatus": "active"
    }).execute()

    # Demo members
    demo_members = [
        {"id": "d1000000-0000-0000-0000-000000000001", "name": "Mei Tan", "progress": 65.0, "streak": 6, "email": "mei@demo.com"},
        {"id": "d2000000-0000-0000-0000-000000000002", "name": "Kumar Raj", "progress": 51.0, "streak": 5, "email": "kumar@demo.com"},
        {"id": "d3000000-0000-0000-0000-000000000003", "name": "Sarah Lee", "progress": 68.0, "streak": 7, "email": "sarah@demo.com"},
    ]
    for m in demo_members:
        # Try to find existing user by email
        user_res = db.table("User").select("id").eq("email", m["email"]).execute()
        if user_res.data:
            member_user_id = user_res.data[0]["id"]
            db.table("User").update({
                "name": m["name"],
                "monthlyincome": 1000.0,
                "salarythreshold": 500.0,
                "incometype": "SALARY"
            }).eq("id", member_user_id).execute()
        else:
            member_user_id = m["id"]
            db.table("User").insert({
                "id": member_user_id,
                "name": m["name"],
                "email": m["email"],
                "monthlyincome": 1000.0,
                "salarythreshold": 500.0,
                "incometype": "SALARY"
            }).execute()

        # Then add to SquadMember
        db.table("SquadMember").insert({
            "id": _uid(),
            "squadid": squad_id,
            "userid": member_user_id,
            "progressscore": m["progress"],
            "streakdays": m["streak"],
            "goalstatus": "active"
        }).execute()
    
    print(f"  [OK] Added {len(demo_members) + 1} members to squad")

    print(f"\nSeed complete for user {user_id}!")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Seed Supabase with demo data.")
    parser.add_argument("--user-id", required=True, help="The UUID of the user to seed data for.")
    parser.add_argument("--confirm", action="store_true", help="Confirm that you want to proceed with seeding.")
    
    args = parser.parse_args()
    seed_demo_data(args.user_id, args.confirm)
