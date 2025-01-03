from fastapi import HTTPException
from datetime import datetime, timedelta
import redis

class RateLimiter:
    def __init__(self):
        self.redis = redis.Redis(host='localhost', port=6379, db=0)
        self.daily_limit = 100
        
    async def check_rate_limit(self, ip: str):
        today = datetime.now().strftime("%Y-%m-%d")
        key = f"rate_limit:{ip}:{today}"
        
        count = self.redis.incr(key)
        if count == 1:
            self.redis.expire(key, 86400)  # 24시간
            
        if count > self.daily_limit:
            raise HTTPException(
                status_code=429,
                detail="일일 사용량을 초과했습니다. 내일 다시 시도해주세요."
            ) 