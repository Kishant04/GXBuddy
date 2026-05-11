#!/usr/bin/env python3
import argparse
import sys
import os
import asyncio
from decimal import Decimal
from dotenv import load_dotenv

# Change working directory to backend so Settings() can find .env
os.chdir(os.path.join(os.getcwd(), "GXBuddy", "backend"))
sys.path.append(os.getcwd())

from app.services.transaction_service import TransactionService
from app.services.dashboard_service import DashboardService
from app.schemas.transaction import TransactionCreateRequest
from app.schemas.common import TransactionCategory, TransactionSource, TransactionStatus

load_dotenv("GXBuddy/backend/.env")

async def test_flow(user_id: str):
    tx_service = TransactionService()
    dash_service = DashboardService()

    print(f"--- Verifying Transaction Flow for User: {user_id} ---")

    # 1. Get baseline
    try:
        dash_before = dash_service.get_dashboard(user_id)
        before_total = float(dash_before.weekly_spend_total)
        print(f"Baseline Weekly Total: RM{before_total:.2f}")
    except Exception as e:
        print(f"Error fetching baseline dashboard: {e}")
        return

    # 2. Create Transaction
    print("Creating RM50.00 GrabFood transaction...")
    try:
        req = TransactionCreateRequest(
            user_id=user_id,
            amount=50.00,
            merchant="GrabFood",
            category=TransactionCategory.FOOD,
            source=TransactionSource.BANK,
            status=TransactionStatus.POSTED
        )
        res = await tx_service.process_transaction(req)
        print(f"Transaction Created: ID={res.transaction.id}, Category={res.transaction.category}")
    except Exception as e:
        print(f"Error creating transaction: {e}")
        return

    # 3. Get updated dashboard
    try:
        dash_after = dash_service.get_dashboard(user_id)
        after_total = float(dash_after.weekly_spend_total)
        print(f"Updated Weekly Total: RM{after_total:.2f}")
        
        diff = after_total - before_total
        print(f"Difference: RM{diff:.2f}")

        if abs(diff - 50.00) < 0.01:
            print("SUCCESS: Weekly total increased by exactly RM50.00")
        else:
            print(f"FAILURE: Expected RM50.00 increase, got RM{diff:.2f}")
            
    except Exception as e:
        print(f"Error fetching updated dashboard: {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--user-id", required=True)
    args = parser.parse_args()

    asyncio.run(test_flow(args.user_id))
