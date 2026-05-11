# GXBuddy — Smart Financial Companion (Backend)

GXBuddy is a smart financial companion that integrates with GXBank, providing AI-powered spending coaching, budget tracking, automated salary splitting (Autopilot), and social financial features (Squads).

This repository contains the backend services for GXBuddy.

## Repository Structure

- **`backend/`**: FastAPI application with Supabase integration.
- **`docs/`**: Documentation, screenshots, and uploads.
- **`legacy-mockups/`**: Original React/Claude Design mockup files (for reference only).

---

## Getting Started (Backend)

1.  Navigate to the backend directory:
    ```bash
    cd backend
    ```
2.  Set up a virtual environment and install dependencies:
    ```bash
    python -m venv venv
    .\venv\Scripts\activate  # Windows
    source venv/bin/activate  # Unix/macOS
    pip install -r requirements.txt
    ```
3.  Run the server:
    ```bash
    uvicorn app.main:app --reload
    ```
    *Note: Ensure a `.env` file is present in `backend/`.*


## License

This project is developed for the UTM Hackathon.
