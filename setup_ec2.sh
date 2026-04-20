#!/bin/bash
set -e

echo "Setting up Free Tier Tuning (2GB Swap)..."
if [ ! -f /swapfile ] && [ ! -f /swapfile_done ]; then
    sudo dd if=/dev/zero of=/swapfile bs=1M count=2048 || true
    sudo chmod 600 /swapfile || true
    sudo mkswap /swapfile || true
    sudo swapon /swapfile || true
fi

echo "Installing Amazon Linux Packages (Java 17, Tomcat, Python 3)..."
sudo yum update -y
sudo yum install -y java-17-amazon-corretto-devel || sudo yum install -y java-17-openjdk-devel
sudo yum install -y tomcat python3 python3-pip || sudo dnf install -y tomcat python3 python3-pip

echo "Starting Tomcat..."
sudo systemctl enable tomcat || true
sudo systemctl start tomcat || true

echo "Installing Static FFmpeg for Amazon Linux..."
if ! command -v ffmpeg &> /dev/null; then
    wget https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz
    tar -xf ffmpeg-release-amd64-static.tar.xz
    sudo cp ffmpeg-*-static/ffmpeg /usr/bin/
    sudo cp ffmpeg-*-static/ffprobe /usr/bin/
    rm -rf ffmpeg-*-static.tar.xz ffmpeg-*-static
fi

echo "Preparing Python AI Environment for Amazon Linux (ec2-user)..."
mkdir -p /home/ec2-user/yt-vocab/python_scripts
cp -r python_scripts/* /home/ec2-user/yt-vocab/python_scripts/ 2>/dev/null || true
cd /home/ec2-user/yt-vocab/python_scripts

# Virtual Env
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi
source venv/bin/activate
pip install yt-dlp openai-whisper spacy pymysql
python -m spacy download en_core_web_sm

echo "Setup Completed Successfully."
