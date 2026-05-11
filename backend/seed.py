import os
import uuid
import calendar
from datetime import datetime, timedelta
from supabase import create_client

def _uid() -> str:
    return str(uuid.uuid4())

def seed(user_id: str) -> dict:
    url = os.getenv("SUPABASE_URL")
    key = os.getenv("SUPABASE_SERVICE_ROLE_KEY") or os.getenv("SUPABASE_KEY")

    if not url or not key:
        raise RuntimeError("SUPABASE_URL and SUPABASE_KEY must be set in .env")

    db = create_client(url, key)
    now = datetime.utcnow()
    
    # Rolling week for dashboard compatibility
    start_of_week = now - timedelta(days=7)
    # End in the future so the budget remains active
    end_of_week = now + timedelta(days=7)

    print(f"Seeding data for user: {user_id}")

    # 1. Ensure User record exists
    # Clear other demo users first to prevent email unique constraint issues
    try:
        db.table("User").delete().ilike("email", "%@demo.com").execute()
        db.table("User").delete().ilike("email", "demo@gxbuddy.com").execute()
    except Exception as e:
        print(f"  [WARN] Failed to clear demo users: {e}")

    user_payload = {
        "id": user_id,
        "name": "Demo User",
        "email": "demo@gxbuddy.com",
        "monthlyincome": 1200.0,
        "salarythreshold": 800.0,
        "incometype": "SALARY",
    }
    
    try:
        db.table("User").upsert(user_payload).execute()
        print("  [OK] User profile upserted")
    except Exception as e:
        print(f"  [ERROR] User profile failed: {e}")
        raise

    # 2. Clear existing demo data
    tables_to_clear = ["Pocket", "Budget", "Transaction", "Streak", "BillReminder", "Alert", "SquadMember"]
    for table in tables_to_clear:
        try:
            db.table(table).delete().eq("userid", user_id).execute()
        except Exception as e:
            print(f"  [WARN] Failed to clear {table}: {e}")

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
        {"merchant": "Touch n Go", "amount": 15.00, "category": "TRANSPORT", "timestamp": (now - timedelta(hours=5)).isoformat()},
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
            "amount": str(t["amount"]),
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
    squad_name = "Broke No More Squad"
    invite_code = "GXDEMO25"
    
    # Check if squad exists
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
        # Full clear of members for this squad to reset indices
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

    # Add members in specific order to guarantee indices (1: User, 2: Mei, 3: Kumar, 4: Sarah)
    # 1. Main User
    db.table("SquadMember").insert({
        "id": _uid(), "squadid": squad_id, "userid": user_id,
        "progressscore": 72.0, "streakdays": 8, "goalstatus": "active"
    }).execute()

    # 2. Demo Users
    demo_members = [
        {"id": "8de804da-71d0-4527-85a3-7b5199009ac6", "name": "Mei", "progress": 65.0, "streak": 6, "email": "mei@demo.com"},
        {"id": "7c9e66d4-1a2b-4c3d-8e5f-6a7b8c9d0e1f", "name": "Kumar", "progress": 51.0, "streak": 5, "email": "kumar@demo.com"},
        {"id": "5b4d3c2a-1f0e-9d8c-7b6a-543210fedcba", "name": "Sarah", "progress": 68.0, "streak": 7, "email": "sarah@demo.com"},
    ]
    
    for m in demo_members:
        member_user_id = m["id"]
        # Create/Update demo user profile
        db.table("User").upsert({
            "id": member_user_id, "name": m["name"], "email": m["email"],
            "monthlyincome": 1000.0, "salarythreshold": 500.0, "incometype": "SALARY"
        }).execute()
        # Add to squad
        db.table("SquadMember").insert({
            "id": _uid(), "squadid": squad_id, "userid": member_user_id,
            "progressscore": m["progress"], "streakdays": m["streak"], "goalstatus": "active"
        }).execute()

    print(f"  [OK] Squad seeded")

    return {
        "budgets_seeded": len(budgets),
        "transactions_seeded": len(transactions),
        "pockets_seeded": len(pockets),
        "alerts_seeded": len(alerts),
        "squad_members_seeded": len(demo_members) + 1
    }

if __name__ == "__main__":
    import sys
    from dotenv import load_dotenv
    load_dotenv()
    target = sys.argv[1] if len(sys.argv) > 1 else "464f572b-0abc-4317-a36c-4739a0a375ec"
    seed(target)
