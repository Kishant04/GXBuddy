from contextlib import asynccontextmanager

from fastapi import FastAPI

from app.routers import (
    auth,
    autopilot,
    bills,
    budgets,
    dashboard,
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
    scheduler.start()
    yield
    scheduler.shutdown()


app = FastAPI(lifespan=lifespan)

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
