# [작업지시서] 유튜브 STT 기반 개인 맞춤형 영어 단어장 서비스

## 1. 프로젝트 개요
- **프로젝트명:** YT-Vocab (YouTube-based Personalized English Learning)
- **개발 목적:** 유튜브 영상의 원어민 음성을 STT(Speech-to-Text)로 분석하여 실제 쓰이는 단어와 숙어를 추출하고, 사용자의 망각 곡선을 고려한 맞춤형 반복 학습 서비스 제공.
- **핵심 특징:** - STT 기반 생생한 원어민 표현 학습.
    - 단어에서 긴 숙어(Idiom)까지 단계별 난이도 조절.
    - SRS(Spaced Repetition System) 알고리즘 적용.

## 2. 기술 스택 (Technical Stack)
- **Backend:** Java 17, Apache Tomcat 9.0, JSP/Servlet (MVC Pattern)
- **Database:** MariaDB (MySQL Compatible)
- **Language Processor:** Python 3.10+ (STT 및 NLP 전처리용)
- **Library/API:** - `OpenAI Whisper`: 고정밀 음성 인식 및 텍스트 변환.
    - `yt-dlp`: 유튜브 오디오 데이터 추출.
    - `NLTK/spaCy`: 형태소 분석 및 표제어 추출.
- **Environment:** Windows (개발) -> Ubuntu (운영 예정)

## 3. 데이터베이스 설계 (ERD 구성용)

### 3.1 회원 정보 (users)
- `user_no` (INT, PK, AI): 고유 번호
- `user_id` (VARCHAR(50), UNIQUE): 사용자 아이디
- `password` (VARCHAR(255)): 암호화된 비밀번호
- `email` (VARCHAR(100)): 이메일 (추후 인증용)
- `reg_date` (TIMESTAMP): 가입일

### 3.2 영상 정보 (videos)
- `video_no` (INT, PK, AI): 고유 번호
- `video_url` (VARCHAR(255)): 유튜브 URL
- `video_title` (VARCHAR(255)): 영상 제목
- `processed_date` (TIMESTAMP): 분석 완료일

### 3.3 단어 및 표현 마스터 (vocabulary)
- `word_id` (INT, PK, AI): 고유 번호
- `expression` (VARCHAR(255)): 단어 또는 숙어
- `meaning` (TEXT): 한국어 뜻
- `difficulty_level` (INT): 난이도 (1: 기초 ~ 5: 숙어/고급)
- `is_idiom` (BOOLEAN): 숙어 여부

### 3.4 학습 진행 상태 (learning_progress)
- `progress_id` (INT, PK, AI): 고유 번호
- `user_no` (INT, FK): 사용자 번호
- `word_id` (INT, FK): 단어 번호
- `status` (VARCHAR(20)): 상태 (NEW, LEARNING, MASTERED)
- `correct_streak` (INT): 연속 정답 횟수
- `next_test_date` (DATE): 다음 테스트 예정일

## 4. 핵심 로직 및 알고리즘

### 4.1 분석 파이프라인
1. **추출:** 사용자가 유튜브 URL 입력 시 `yt-dlp`로 오디오 파일(.mp3) 추출.
2. **변환:** `Whisper` 모델을 구동하여 텍스트 및 타임스탬프 추출.
3. **분류:** 추출된 텍스트를 NLP로 분석하여 불용어 제거 및 단어/숙어 분류.

### 4.2 SRS(간격 반복) 테스트 알고리즘
- **신규 단어:** 테스트 최초 정답 시 즉시 `MASTERED` (이후 추천 제외).
- **오답 시:** - `status`를 `LEARNING`으로 변경.
    - `next_test_date`를 익일(D+1)로 설정.
    - `correct_streak` 초기화(0).
- **정답 시 (LEARNING 상태):**
    - `next_test_date`를 2일 뒤(D+2)로 설정.
    - `correct_streak` 1 증가.
- **졸업 조건:**
    - `correct_streak`가 3회 연속 달성 시 `MASTERED` 처리.
    - 이후 모든 영상 분석 시 해당 단어는 문제 출제 대상에서 제외.

## 5. 단계별 개발 태스크 (Development Roadmap)

### Phase 1: 기반 시스템 구축
- [ ] MariaDB 테이블 생성 및 JSP-Tomcat 연동 설정.
- [ ] 일반 회원가입 및 로그인 기능 구현 (세션 방식).
- [ ] 기본적인 UI 레이아웃 구성 (CSS/JSP).

### Phase 2: STT 및 데이터 연동
- [ ] Python 환경 설정 및 `yt-dlp`, `Whisper` 연동 스크립트 작성.
- [ ] Java `ProcessBuilder`를 이용한 파이썬 스크립트 호출 및 결과 JSON 파싱.
- [ ] 분석된 데이터를 `vocabulary` 및 `learning_progress` 테이블에 적재하는 로직 구현.

### Phase 3: 학습/테스트 기능
- [ ] 난이도별(단어/숙어) 리스트 필터링 기능.
- [ ] 일일 테스트 퀴즈 화면 구현.
- [ ] 테스트 결과에 따른 SRS 알고리즘 반영 (DB 업데이트 로직).

### Phase 4: 고도화 및 이전 준비
- [ ] 숙어 데이터베이스 확충 및 패턴 매칭 정교화.
- [ ] 사용자 오답 노트 및 학습 통계 페이지.
- [ ] Ubuntu 이전을 위한 경로 설정 및 환경 변수화 작업.