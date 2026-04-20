import os
import sys
import json
import yt_dlp
import whisper
import spacy
import math

last_percent = -1

def print_progress(percent, state):
    print(json.dumps({"type": "progress", "percent": percent, "state": state}))
    sys.stdout.flush()

def my_hook(d):
    global last_percent
    if d['status'] == 'downloading':
        try:
            total_bytes = d.get('total_bytes') or d.get('total_bytes_estimate')
            downloaded = d.get('downloaded_bytes', 0)
            if total_bytes:
                percent = math.floor((downloaded / total_bytes) * 100)
                # 0~100% Download -> 0~40% Overall progress
                overall_percent = int((percent / 100.0) * 40.0)
                if overall_percent >= last_percent + 2:
                    print_progress(overall_percent, f"영상을 다운로드 중입니다... ({percent}%)")
                    last_percent = overall_percent
        except:
            pass

def download_audio(url, output_path):
    ydl_opts = {
        'format': 'bestaudio/best',
        'postprocessors': [{
            'key': 'FFmpegExtractAudio',
            'preferredcodec': 'mp3',
            'preferredquality': '192',
        }],
        'outtmpl': output_path,
        'quiet': True,
        'no_warnings': True,
        'progress_hooks': [my_hook]
    }
    try:
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url, download=True)
            return True, info.get('title', 'Unknown Title')
    except Exception as e:
        return False, str(e)

def analyze_video(url):
    print_progress(0, "분석 준비 중...")
    
    temp_dir = "temp"
    os.makedirs(temp_dir, exist_ok=True)
    audio_path = os.path.join(temp_dir, "audio.%(ext)s")
    
    # 1. Download
    success, title_or_error = download_audio(url, audio_path)
    if not success:
        return {"type": "result", "status": "error", "message": f"Download failed: {title_or_error}"}
    
    actual_audio_path = os.path.join(temp_dir, "audio.mp3")

    # 2. STT via Whisper
    print_progress(45, "AI 음성 인식 중입니다... (1~3분 소요)")
    try:
        model = whisper.load_model("base") 
        result = model.transcribe(actual_audio_path)
        text = result["text"]
    except Exception as e:
        return {"type": "result", "status": "error", "message": f"STT failed: {str(e)}"}

    # 3. NLP via spaCy
    print_progress(85, "단어 품사 분석 및 추출 중입니다...")
    try:
        try:
            nlp = spacy.load("en_core_web_sm")
        except OSError:
             return {"type": "result", "status": "error", "message": "spacy model not found."}
             
        doc = nlp(text)
        
        vocabulary = []
        for token in doc:
            if not token.is_stop and not token.is_punct and token.is_alpha:
                 if len(token.lemma_) > 2:
                     vocabulary.append(token.lemma_.lower())
                     
        vocabulary = list(set(vocabulary))
        
        if os.path.exists(actual_audio_path):
            os.remove(actual_audio_path)
            
        return {
            "type": "result",
            "status": "success",
            "title": title_or_error,
            "text": text,
            "vocabulary": vocabulary
        }
    except Exception as e:
         return {"type": "result", "status": "error", "message": f"NLP failed: {str(e)}"}

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(json.dumps({"type": "result", "status": "error", "message": "No URL provided"}))
        sys.exit(1)
        
    url = sys.argv[1]
    result = analyze_video(url)
    print_progress(100, "분석 완료!")
    print(json.dumps(result))
