package com.ytvocab.util;

import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;

import org.json.JSONObject;

public class PythonBridge {
    // OS 구분
    private static final boolean IS_WINDOWS = System.getProperty("os.name").toLowerCase().contains("win");
    
    // 실행 환경에 맞게 python 실행 경로 및 스크립트 경로 변경
    private static final String PYTHON_EXE = IS_WINDOWS ? "python" : "/home/ubuntu/yt-vocab/python_scripts/venv/bin/python3"; 
    private static final String SCRIPT_DIR = IS_WINDOWS ? "c:\\capstone\\python_scripts" : "/home/ubuntu/yt-vocab/python_scripts";
    private static final String SCRIPT_PATH = SCRIPT_DIR + (IS_WINDOWS ? "\\analyzer.py" : "/analyzer.py");

    public static JSONObject analyzeVideo(String url) throws Exception {
        ProcessBuilder pb = new ProcessBuilder(PYTHON_EXE, SCRIPT_PATH, url);
        pb.redirectErrorStream(true); // 에러 스트림을 출력 스트림에 병합
        
        // 작업 디렉토리를 스크립트가 있는 곳으로 변경
        pb.directory(new File(SCRIPT_DIR));
        
        Process process = pb.start();

        BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream(), "UTF-8"));
        StringBuilder output = new StringBuilder();
        String line;
        
        while ((line = reader.readLine()) != null) {
            output.append(line);
        }
        
        int exitCode = process.waitFor();
        if (exitCode != 0) {
            throw new Exception("Python script exited with code: " + exitCode + ". Output: " + output.toString());
        }
        
        // 파이썬에서 print(json.dumps(...))로 출력한 마지막 문장을 파싱
        return new JSONObject(output.toString());
    }
}
