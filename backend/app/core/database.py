from __future__ import annotations

import os

from dotenv import load_dotenv
from supabase import Client, create_client

load_dotenv()

_SUPABASE: Client | None = None

TABLES = {
    "transactions": "Transaction",
    "budgets": "Budget",
    "alerts": "Alert",
    "bill_reminders": "BillReminder",
    "pockets": "Pocket",
    "streaks": "Streak",
    "squads": "Squad",
    "squad_members": "SquadMember",
}

def get_supabase_client() -> Client:
    global _SUPABASE

    if _SUPABASE is not None:
        return _SUPABASE

    url = os.getenv("SUPABASE_URL")
    key = os.getenv("SUPABASE_KEY")

    if not url or not key:
        raise RuntimeError("SUPABASE_URL and SUPABASE_KEY must be set in .env")

    _SUPABASE = create_client(url, key)
    return _SUPABASE
