import os
from dotenv import load_dotenv
from supabase import create_client

load_dotenv()

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

def reset_password():
    if not SUPABASE_URL or not SUPABASE_KEY:
        print("Error: SUPABASE_URL and SUPABASE_KEY must be set in .env")
        return

    supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
    
    email = "test@gxbuddy.com"
    new_password = "Test123456!"
    
    print(f"Force updating password for {email}...")
    
    try:
        # Get user by email to get their ID
        # Note: auth.admin.list_users() is better if we have service key
        users = supabase.auth.admin.list_users()
        target_user = next((u for u in users if u.email == email), None)
        
        if not target_user:
            print(f"User {email} not found. Creating new user...")
            res = supabase.auth.admin.create_user({
                "email": email,
                "password": new_password,
                "email_confirm": True
            })
            print(f"Successfully created user: {res.user.id}")
        else:
            res = supabase.auth.admin.update_user_by_id(
                target_user.id,
                {"password": new_password}
            )
            print(f"Successfully updated password for user: {target_user.id}")
            
    except Exception as e:
        print(f"Error resetting password: {e}")

if __name__ == "__main__":
    reset_password()
