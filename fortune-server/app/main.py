from fastapi import FastAPI, Request, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from .models import FortuneRequest, FortuneResponse
from .services.openai_service import OpenAIService
from .utils.rate_limiter import RateLimiter
from dotenv import load_dotenv
import os
import logging

load_dotenv()

app = FastAPI()
openai_service = OpenAIService()
rate_limiter = RateLimiter()

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",
        "http://localhost:8000",
        "https://happy-year-2025.vercel.app",
        "https://happy-year-2025-git-*.vercel.app",
        "https://happy-year-2025-*.vercel.app",
        "https://happy-year-2025-9mq5-hzflfyfuo-noahs-projects-9b976b5c.vercel.app"
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@app.post("/api/fortune")
async def get_fortune(request: Request, fortune_request: FortuneRequest):
    client_ip = request.client.host
    logger.info(f"Request from IP: {client_ip}")
    
    await rate_limiter.check_rate_limit(request.client.host)
    
    try:
        fortune = await openai_service.get_fortune(
            fortune_request.name,
            fortune_request.gender,
            fortune_request.birthDateTime
        )
        return FortuneResponse(fortune=fortune)
    except Exception as e:
        logger.error(f"Error: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e)) 