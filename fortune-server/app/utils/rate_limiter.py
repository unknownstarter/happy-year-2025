from fastapi import HTTPException
from datetime import datetime
import redis
import os

class RateLimiter:
    def __init__(self):
        redis_url = os.getenv('REDIS_URL', 'redis://localhost:6379')
        self.redis = redis.from_url(redis_url)
        self.daily_limit = 100
        
    async def check_rate_limit(self, ip: str):
        try:
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
        except redis.ConnectionError:
            # Redis 연결 실패시 제한 없이 허용
            pass 