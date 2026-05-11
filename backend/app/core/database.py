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
    service_key = os.getenv("SUPABASE_SERVICE_ROLE_KEY")
    anon_key = os.getenv("SUPABASE_KEY")
    
    key = service_key or anon_key

    if not url or not key:
        raise RuntimeError("SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set in .env")

    print(f"[DB] Initializing client. URL: {url}")
    if service_key:
        print(f"[DB] Using Service Role Key (starts with {service_key[:10]}...)")
    else:
        print("[DB] WARNING: Service Role Key missing, using fallback key")

    _SUPABASE = create_client(url, key)
    return _SUPABASE

def get_admin_client() -> Client:
    """Returns a fresh client using the service role key to ensure RLS bypass."""
    url = os.getenv("SUPABASE_URL")
    key = os.getenv("SUPABASE_SERVICE_ROLE_KEY")
    if not url or not key:
        return get_supabase_client()
    return create_client(url, key)
