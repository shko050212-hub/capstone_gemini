#!/bin/bash
set -e

echo "Setting up Free Tier Tuning (2GB Swap)..."
if [ ! -f /swapfile ] && [ ! -f /swapfile_done ]; then
    sudo dd if=/dev/zero of=/swapfile bs=1M count=2048 || true
    sudo chmod 600 /swapfile || true
    sudo mkswap /swapfile || true
    sudo swapon /swapfile || true
fi

echo "Installing Amazon Linux Packages (Java 17, Python 3)..."
sudo yum update -y
sudo yum install -y java-17-amazon-corretto-devel || sudo yum install -y java-17-openjdk-devel
sudo yum install -y python3 python3-pip || sudo dnf install -y python3 python3-pip

echo "Manual Install of Tomcat 9 for AL2023..."
if [ ! -d "/opt/tomcat9" ]; then
    wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.98/bin/apache-tomcat-9.0.98.tar.gz
    sudo mkdir -p /opt/tomcat9
    sudo tar xvf apache-tomcat-9.0.98.tar.gz -C /opt/tomcat9 --strip-components=1
    rm -f apache-tomcat-9.0.98.tar.gz
fi

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
