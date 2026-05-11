# Database Inspection Plan

This document outlines the plan for auditing and verifying the Supabase database schema for the GXBuddy project.

## 1. Required Supabase Tables

Based on the backend services and `seed.py`, the following tables are required:

| Table | Purpose |
| :--- | :--- |
| `User` | Stores user profiles and financial thresholds. |
| `Transaction` | Records all spending and income transactions. |
| `Budget` | Stores weekly/monthly spending limits per user/category. |
| `Pocket` | Stores "GX Pockets" balances, targets, and autopilot rules. |
| `Streak` | Tracks user savings streaks. |
| `BillReminder` | Stores upcoming recurring bills. |
| `Alert` | Stores AI-generated nudges and budget threshold alerts. |
| `Squad` | Stores social saving group details and goals. |
| `SquadMember` | Maps users to squads with progress and streak data. |

## 2. Table Column Definitions

### User
- `id`: `uuid` (Primary Key)
- `name`: `text`
- `email`: `text`
- `monthlyincome`: `numeric`
- `salarythreshold`: `numeric`
- `incometype`: `text` (e.g., 'SALARY')
- `createdat`: `timestamp with time zone`

### Transaction
- `id`: `uuid` (Primary Key)
- `userid`: `uuid` (Foreign Key -> User.id)
- `merchant`: `text`
- `amount`: `numeric`
- `category`: `text`
- `source`: `text` (e.g., 'BANK', 'MANUAL')
- `status`: `text` (e.g., 'POSTED', 'PENDING')
- `isbnpl`: `boolean`
- `timestamp`: `timestamp with time zone`
- `riskscore`: `numeric`
- `categoryconfidence`: `numeric`
- `alertgenerated`: `boolean`
- `externalref`: `text`

### Budget
- `id`: `uuid` (Primary Key)
- `userid`: `uuid` (Foreign Key -> User.id)
- `scope`: `text` (e.g., 'overall', 'category')
- `category`: `text` (nullable)
- `weeklylimit`: `numeric`
- `periodstart`: `timestamp with time zone`
- `periodend`: `timestamp with time zone`
- `alert60`: `boolean`
- `alert80`: `boolean`
- `alert100`: `boolean`

### Pocket
- `id`: `uuid` (Primary Key)
- `userid`: `uuid` (Foreign Key -> User.id)
- `name`: `text`
- `balance`: `numeric`
- `target`: `numeric`
- `splitrule`: `jsonb` (e.g., `{"type": "percent", "value": 20.0}`)

### Squad
- `id`: `uuid` (Primary Key)
- `name`: `text`
- `goalname`: `text`
- `goalamount`: `numeric`
- `deadline`: `timestamp with time zone`
- `createdby`: `uuid` (Foreign Key -> User.id)
- `invitecode`: `text` (unique)
- `privacymode`: `text` (e.g., 'ANONYMOUS')
- `isactive`: `boolean`

## 3. Row Level Security (RLS) Requirements

To ensure data privacy, the following RLS policies should be implemented:
- **Authenticated users** should only be able to `SELECT`, `INSERT`, `UPDATE`, and `DELETE` rows where `userid = auth.uid()`.
- **Squad Table**: Users should be able to `SELECT` squads they are members of (requires a join with `SquadMember`).
- **SquadMember Table**: Users can see other members in their own squads, but only certain fields if `privacymode` is 'ANONYMOUS'.

## 4. Safety Rules for Inspection

1.  **Read-Only**: Use `SELECT` statements for verification.
2.  **No Mass Deletion**: Never run `DELETE` without a specific `WHERE` clause matching a test user ID.
3.  **Local Credentials**: Store Supabase credentials in `backend/.env.local`.

### Recommended Environment Variables (`backend/.env.local`):
```env
SUPABASE_URL=
SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
DATABASE_URL=
```

## 5. Inspection & Seeding Workflow

### How to Inspect Schema
If the Supabase CLI is installed:
```bash
supabase db remote commit # (Experimental - read only)
```
Alternatively, use the Supabase Dashboard SQL Editor to run:
```sql
SELECT table_name, column_name, data_type 
FROM information_schema.columns 
WHERE table_schema = 'public';
```

### How to Seed Safely
Run the provided seed script from the `backend/` directory:
```bash
python seed.py <user_uuid>
```
*Note: This script deletes existing demo data for the specified user before re-inserting.*

## 6. Integration Gaps & Observations

- **Naming Convention**: The backend `database.py` maps lowercase keys (e.g., `TABLES["transactions"] = "Transaction"`), but some services might expect lowercase table names. **PascalCase singular** (e.g., `Transaction`) appears to be the standard in `seed.py`.
- **Missing Migrations**: There are currently no SQL migration files. We should generate a `schema.sql` based on the audit findings.
- **Supabase Config**: No `supabase/config.toml` is present; the project relies solely on environment variables.
