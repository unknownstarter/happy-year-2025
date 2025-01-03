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
        "https://happy-year-2025-9mq5-hzflfyfuo-noahs-projects-9b976b5c.vercel.app",
        # Vercel preview 도메인도 허용
        "https://*.vercel.app"
    ],
    allow_credentials=True,
    allow_methods=["GET", "POST", "OPTIONS"],
    allow_headers=["*"],
    expose_headers=["*"]
)

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

@app.post("/api/fortune")
async def get_fortune(request: Request, fortune_request: FortuneRequest):
    client_ip = request.client.host
    logger.info(f"Received request from IP: {client_ip}")
    logger.info(f"Request data: {fortune_request}")
    
    try:
        fortune = await openai_service.get_fortune(
            fortune_request.name,
            fortune_request.gender,
            fortune_request.birthDateTime
        )
        logger.info("Fortune generated successfully")
        return FortuneResponse(fortune=fortune)
    except Exception as e:
        logger.error(f"Error generating fortune: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e)) 