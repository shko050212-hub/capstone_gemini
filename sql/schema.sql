-- 마리아DB용 기초 스키마 설계 및 테이블 생성 (AWS RDS 용도)

-- 1. 회원 정보 테이블
CREATE TABLE IF NOT EXISTS users (
    user_no INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100),
    reg_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. 영상 정보 테이블
CREATE TABLE IF NOT EXISTS videos (
    video_no INT AUTO_INCREMENT PRIMARY KEY,
    video_url VARCHAR(255) NOT NULL,
    video_title VARCHAR(255),
    processed_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. 단어 및 표현 마스터 테이블
CREATE TABLE IF NOT EXISTS vocabulary (
    word_id INT AUTO_INCREMENT PRIMARY KEY,
    expression VARCHAR(255) NOT NULL,
    meaning TEXT,
    difficulty_level INT DEFAULT 1, -- 1: 기초 ~ 5: 고급/숙어
    is_idiom BOOLEAN DEFAULT FALSE,
    CONSTRAINT unique_expression UNIQUE (expression)
);

-- 4. 영상별 단어 매핑 정보 (옵션, 향후 확장성)
-- 영상 시청 시 어떤 단어가 출현했는지 저장하기 위한 추적용 
CREATE TABLE IF NOT EXISTS video_vocabulary (
    video_no INT,
    word_id INT,
    PRIMARY KEY (video_no, word_id),
    FOREIGN KEY (video_no) REFERENCES videos(video_no) ON DELETE CASCADE,
    FOREIGN KEY (word_id) REFERENCES vocabulary(word_id) ON DELETE CASCADE
);

-- 5. 학습 진행 상태 (학습내역 및 망각곡선)
CREATE TABLE IF NOT EXISTS learning_progress (
    progress_id INT AUTO_INCREMENT PRIMARY KEY,
    user_no INT NOT NULL,
    word_id INT NOT NULL,
    status VARCHAR(20) DEFAULT 'NEW', -- NEW, LEARNING, MASTERED
    correct_streak INT DEFAULT 0,
    next_test_date DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY (user_no) REFERENCES users(user_no) ON DELETE CASCADE,
    FOREIGN KEY (word_id) REFERENCES vocabulary(word_id) ON DELETE CASCADE,
    CONSTRAINT unique_user_word UNIQUE (user_no, word_id)
);

-- 테스트를 위한 더미 데이터 삽입 
INSERT IGNORE INTO users (user_id, password, email) VALUES ('testuser', '1234', 'test@ytvocab.com');
