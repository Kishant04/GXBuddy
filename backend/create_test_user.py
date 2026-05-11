import os
from dotenv import load_dotenv
from supabase import create_client

load_dotenv()

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_SERVICE_ROLE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY")

def create_test_user():
    if not SUPABASE_URL or not SUPABASE_SERVICE_ROLE_KEY:
        print("Error: SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set in .env")
        return

    supabase = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
    
    email = "test@gxbuddy.com"
    password = "Test123456!"
    
    print(f"Ensuring user {email} exists in Supabase Auth...")
    
    try:
        # Try to find user first
        users = supabase.auth.admin.list_users()
        user_id = None
        for u in users:
            if u.email == email:
                user_id = u.id
                break
        
        if user_id:
            print(f"User exists (ID: {user_id}). Updating password...")
            supabase.auth.admin.update_user_by_id(
                user_id, 
                {"password": password}
            )
            print("Password updated successfully.")
        else:
            print(f"Creating new user {email}...")
            res = supabase.auth.admin.create_user({
                "email": email,
                "password": password,
                "email_confirm": True
            })
            print(f"Successfully created user: {res.user.id}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    create_test_user()
