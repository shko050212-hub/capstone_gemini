#!/bin/bash
set -e

echo "Setting up Free Tier Tuning (2GB Swap)..."
if [ ! -f /swapfile ] && [ ! -f /swapfile_done ]; then
    sudo fallocate -l 2G /swapfile || sudo dd if=/dev/zero of=/swapfile bs=1M count=2048
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
fi

echo "Installing Java 17, Tomcat 9, Python 3, FFmpeg..."
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install -y openjdk-17-jdk tomcat9 python3-pip python3-venv ffmpeg

echo "Preparing Python AI Environment..."
mkdir -p /home/ubuntu/yt-vocab/python_scripts
cp -r python_scripts/* /home/ubuntu/yt-vocab/python_scripts/ 2>/dev/null || true
cd /home/ubuntu/yt-vocab/python_scripts

# Virtual Env
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi
source venv/bin/activate
pip install yt-dlp openai-whisper spacy pymysql
python -m spacy download en_core_web_sm

echo "Setup Completed Successfully."
