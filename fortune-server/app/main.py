from fastapi import FastAPI, Request, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from .models import FortuneRequest, FortuneResponse
from .services.openai_service import OpenAIService
from .utils.rate_limiter import RateLimiter
from dotenv import load_dotenv
import os
import logging
import sys

# 로깅 설정을 가장 먼저
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

load_dotenv()

def check_environment():
    logger.info("Checking environment...")
    required_vars = ['OPENAI_API_KEY', 'REDIS_URL', 'PORT']
    for var in required_vars:
        value = os.getenv(var)
        exists = bool(value)
        logger.info(f"{var} exists: {exists}")
        if exists:
            logger.info(f"{var} length: {len(value)}")
    
    logger.info(f"Current working directory: {os.getcwd()}")
    logger.info(f"Python path: {sys.path}")

check_environment()
app = FastAPI()
openai_service = None  # 전역 변수 선언

# CORS 미들웨어를 가장 먼저 추가
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 개발 중에는 모든 origin 허용
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("startup")
async def startup_event():
    try:
        global openai_service  # 전역 변수 사용
        logger.info("=== Server Starting ===")
        logger.info(f"Python version: {sys.version}")
        logger.info(f"Working directory: {os.getcwd()}")
        logger.info(f"Directory contents: {os.listdir('.')}")
        logger.info(f"OPENAI_API_KEY exists: {bool(os.getenv('OPENAI_API_KEY'))}")
        logger.info(f"OPENAI_API_KEY length: {len(os.getenv('OPENAI_API_KEY', ''))}")
        logger.info(f"REDIS_URL exists: {bool(os.getenv('REDIS_URL'))}")
        logger.info("=====================")
    except Exception as e:
        logger.error(f"Startup error: {e}", exc_info=True)
        raise

    try:
        logger.info("Initializing OpenAI service...")
        openai_service = OpenAIService()
        logger.info("OpenAI service initialized successfully")
    except Exception as e:
        logger.error(f"Failed to initialize OpenAI service: {str(e)}", exc_info=True)
        raise

@app.get("/")
async def root():
    return {"status": "ok", "message": "Server is running"}

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

@app.options("/api/fortune")
async def options_fortune():
    return JSONResponse(
        content={"message": "OK"},
        headers={
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "POST, OPTIONS",
            "Access-Control-Allow-Headers": "Content-Type, Accept",
        },
    ) 