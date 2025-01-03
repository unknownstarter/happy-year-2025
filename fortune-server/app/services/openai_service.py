from openai import AsyncOpenAI
from datetime import datetime
import os
from dotenv import load_dotenv

class OpenAIService:
    def __init__(self):
        load_dotenv()
        api_key = os.getenv("OPENAI_API_KEY")
        if not api_key:
            raise ValueError("OPENAI_API_KEY not found in environment variables")
            
        try:
            self.client = AsyncOpenAI(api_key=api_key)
        except Exception as e:
            print(f"Failed to initialize OpenAI client: {e}")
            raise
        
    async def get_fortune(self, name: str, gender: str, birth_date_time: datetime) -> dict:
        system_prompt = """당신은 2025년 운세를 봐주는 점성술사입니다. 
사용자의 이름, 성별, 생년월일시를 기반으로 정확하고 개인화된 운세를 제공합니다.

다음 규칙을 반드시 지켜주세요:
1. 각 운세는 구체적이고 실용적인 조언을 포함해야 합니다
2. 긍정적이면서도 현실적인 톤을 유지하세요
3. 각 카테고리별로 2-3문장으로 명확하게 설명해주세요
4. 생년월일시의 시간을 고려하여 더 정확한 운세를 제공하세요

응답 형식:

전체운:
(2025년의 전반적인 운세와 주요 기회, 도전 과제를 설명)

금전운:
(재물, 직장, 투자, 사업 등에 대한 구체적인 조언)

사랑운:
(연애, 결혼, 가족 관계에 대한 구체적인 조언)

건강운:
(신체적, 정신적 건강에 대한 구체적인 조언과 주의사항)
"""

        user_prompt = f"""
이름: {name}
성별: {gender}
생년월일시: {birth_date_time.strftime('%Y년 %m월 %d일 %H시')}

이 정보를 바탕으로 2025년의 운세를 봐주세요."""

        try:
            completion = await self.client.chat.completions.create(
                model="gpt-3.5-turbo",
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": user_prompt}
                ],
                temperature=0.7,
                max_tokens=1000,
            )
            
            return self._parse_fortune(completion.choices[0].message.content)
            
        except Exception as e:
            print(f"OpenAI API Error: {e}")
            raise
            
    def _parse_fortune(self, content: str) -> dict:
        fortune = {
            "전체운": "",
            "금전운": "",
            "사랑운": "",
            "건강운": ""
        }
        
        current_category = None
        current_content = []
        
        # 줄 단위로 파싱
        for line in content.split('\n'):
            line = line.strip()
            if not line:
                continue
                
            # 카테고리 확인
            if line.startswith('전체운:') or line.startswith('- 전체운:'):
                current_category = "전체운"
            elif line.startswith('금전운:') or line.startswith('- 금전운:'):
                current_category = "금전운"
            elif line.startswith('사랑운:') or line.startswith('- 사랑운:'):
                current_category = "사랑운"
            elif line.startswith('건강운:') or line.startswith('- 건강운:'):
                current_category = "건강운"
            elif current_category:
                # 카테고리 제목을 제외한 내용 추가
                if not line.endswith(':'):
                    current_content.append(line)
                    fortune[current_category] = ' '.join(current_content)
                    current_content = []
        
        # 빈 카테고리 처리
        for category in fortune:
            if not fortune[category]:
                fortune[category] = "해당 운세에 대한 분석이 누락되었습니다."
        
        return fortune 