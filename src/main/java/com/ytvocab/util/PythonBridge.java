package com.ytvocab.util;

import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;
import java.util.concurrent.ConcurrentHashMap;

import org.json.JSONObject;

public class PythonBridge {
    private static final boolean IS_WINDOWS = System.getProperty("os.name").toLowerCase().contains("win");
    private static final String PYTHON_EXE = IS_WINDOWS ? "python" : "/home/ec2-user/yt-vocab/python_scripts/venv/bin/python3"; 
    private static final String SCRIPT_DIR = IS_WINDOWS ? "c:\\capstone\\python_scripts" : "/home/ec2-user/yt-vocab/python_scripts";
    private static final String SCRIPT_PATH = SCRIPT_DIR + (IS_WINDOWS ? "\\analyzer.py" : "/analyzer.py");

    public static final ConcurrentHashMap<Integer, JSONObject> tasks = new ConcurrentHashMap<>();

    public interface AnalyzeCallback {
        void onSuccess(JSONObject result) throws Exception;
        void onError(JSONObject errorResult);
    }

    public static void startAnalysisAsync(int userNo, String url, AnalyzeCallback callback) {
        JSONObject initMsg = new JSONObject();
        initMsg.put("status", "running");
        initMsg.put("percent", 0);
        initMsg.put("message", "AI 파이프라인 초기화 중...");
        tasks.put(userNo, initMsg);

        new Thread(() -> {
            try {
                ProcessBuilder pb = new ProcessBuilder(PYTHON_EXE, SCRIPT_PATH, url);
                pb.redirectErrorStream(true);
                pb.directory(new File(SCRIPT_DIR));
                Process process = pb.start();

                BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream(), "UTF-8"));
                String line;
                String lastLine = "";
                
                while ((line = reader.readLine()) != null) {
                    lastLine = line;
                    try {
                        JSONObject msg = new JSONObject(line);
                        if ("progress".equals(msg.optString("type"))) {
                            JSONObject progressUpdate = tasks.get(userNo);
                            if(progressUpdate != null) {
                                progressUpdate.put("percent", msg.optInt("percent", 0));
                                progressUpdate.put("message", msg.optString("state", ""));
                                tasks.put(userNo, progressUpdate);
                            }
                        }
                    } catch(Exception ignored) { }
                }
                
                int exitCode = process.waitFor();
                if (exitCode != 0) {
                    throw new Exception("Script crashed. Output: " + lastLine);
                }
                
                JSONObject finalResult = new JSONObject(lastLine);
                callback.onSuccess(finalResult);

            } catch (Exception e) {
                e.printStackTrace();
                JSONObject errorMsg = new JSONObject();
                errorMsg.put("type", "result");
                errorMsg.put("status", "error");
                errorMsg.put("message", e.getMessage());
                callback.onError(errorMsg);
            }
        }).start();
    }
}
