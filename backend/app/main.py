from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routers import (
    auth,
    autopilot,
    bills,
    budgets,
    dashboard,
    demo,
    insights,
    pockets,
    profile,
    squad,
    support,
    transactions,
)
from app.jobs.weekly_squad_insights import scheduler


@asynccontextmanager
async def lifespan(app: FastAPI):
    print("[BACKEND] GXBuddy server starting up...")
    scheduler.start()
    yield
    print("[BACKEND] GXBuddy server shutting down...")
    scheduler.shutdown()


app = FastAPI(lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5173",
        "http://127.0.0.1:5173",
        "http://localhost:3000",
        "http://127.0.0.1:3000",
        "http://localhost:8000",
        "http://127.0.0.1:8000",
        "http://localhost:45360",
        "http://127.0.0.1:45360",
    ],
    allow_origin_regex=r"^http://(localhost|127\.0\.0\.1):\d+$",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(profile.router)
app.include_router(dashboard.router)
app.include_router(transactions.router)
app.include_router(squad.router)
app.include_router(budgets.router)
app.include_router(pockets.router)
app.include_router(autopilot.router)
app.include_router(bills.router)
app.include_router(insights.router)
app.include_router(support.router)
app.include_router(demo.router)
