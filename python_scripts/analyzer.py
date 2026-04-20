import os
import sys
import json
import yt_dlp
import whisper
import spacy

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
        'no_warnings': True
    }
    try:
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url, download=True)
            return True, info.get('title', 'Unknown Title')
    except Exception as e:
        return False, str(e)

def analyze_video(url):
    temp_dir = "temp"
    os.makedirs(temp_dir, exist_ok=True)
    audio_path = os.path.join(temp_dir, "audio.%(ext)s")
    
    # 1. Download Audio
    success, title_or_error = download_audio(url, audio_path)
    if not success:
        return {"status": "error", "message": f"Download failed: {title_or_error}"}
    
    actual_audio_path = os.path.join(temp_dir, "audio.mp3")

    # 2. STT via Whisper
    try:
        model = whisper.load_model("base") # Use small or medium for better accuracy if resources allow.
        result = model.transcribe(actual_audio_path)
        text = result["text"]
    except Exception as e:
        return {"status": "error", "message": f"STT failed: {str(e)}"}

    # 3. NLP via spaCy
    # Requires: python -m spacy download en_core_web_sm
    try:
        try:
            nlp = spacy.load("en_core_web_sm")
        except OSError:
             return {"status": "error", "message": "spacy model not found. Run python -m spacy download en_core_web_sm"}
             
        doc = nlp(text)
        
        vocabulary = []
        for token in doc:
            # Simple heuristic: ignore stop words and punctuation, keep only lemmas
            if not token.is_stop and not token.is_punct and token.is_alpha:
                 if len(token.lemma_) > 2: # Ignore very short words
                     vocabulary.append(token.lemma_.lower())
                     
        # Deduplicate
        vocabulary = list(set(vocabulary))
        
        # Clean up temp file
        if os.path.exists(actual_audio_path):
            os.remove(actual_audio_path)
            
        return {
            "status": "success",
            "title": title_or_error,
            "text": text,
            "vocabulary": vocabulary
        }
    except Exception as e:
         return {"status": "error", "message": f"NLP failed: {str(e)}"}

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(json.dumps({"status": "error", "message": "No URL provided"}))
        sys.exit(1)
        
    url = sys.argv[1]
    result = analyze_video(url)
    # Output solely the JSON string for Java to parse
    print(json.dumps(result))
