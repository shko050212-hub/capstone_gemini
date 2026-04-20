package com.ytvocab.controller;

import com.ytvocab.model.User;
import com.ytvocab.util.PythonBridge;
import org.json.JSONArray;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

import com.ytvocab.dao.VocabularyDAO;
import com.ytvocab.dao.ProgressDAO;
import com.ytvocab.util.DBManager;
import java.sql.Connection;

@WebServlet("/analyze")
public class AnalyzeServlet extends HttpServlet {

    private VocabularyDAO vocabDAO = new VocabularyDAO();
    private ProgressDAO progressDAO = new ProgressDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("authUser");
        response.setContentType("application/json;charset=UTF-8");
        JSONObject res = new JSONObject();

        if (user == null) {
            res.put("status", "error");
            res.put("message", "not_logged_in");
            response.getWriter().write(res.toString());
            return;
        }

        String youtubeUrl = request.getParameter("youtubeUrl");
        if (youtubeUrl == null || youtubeUrl.isEmpty()) {
            res.put("status", "error");
            res.put("message", "url_missing");
            response.getWriter().write(res.toString());
            return;
        }

        PythonBridge.startAnalysisAsync(user.getUserNo(), youtubeUrl, new PythonBridge.AnalyzeCallback() {
            @Override
            public void onSuccess(JSONObject analysisResult) throws Exception {
                if ("success".equals(analysisResult.optString("status"))) {
                    JSONArray vocabArray = analysisResult.optJSONArray("vocabulary");
                    int addedWords = 0;
                    if(vocabArray != null) {
                        try (Connection conn = DBManager.getConnection()) {
                            for (int i = 0; i < vocabArray.length(); i++) {
                                String word = vocabArray.getString(i);
                                int wordId = vocabDAO.saveOrGetWord(word);
                                if (wordId != -1) {
                                    progressDAO.addProgressIfNotExists(conn, user.getUserNo(), wordId);
                                    addedWords++;
                                }
                            }
                        }
                    }
                    JSONObject doneData = new JSONObject();
                    doneData.put("status", "completed");
                    doneData.put("msg", "분석 완료! 총 " + addedWords + "개의 학습 단어가 추가되었습니다.");
                    PythonBridge.tasks.put(user.getUserNo(), doneData);
                } else {
                    JSONObject failData = new JSONObject();
                    failData.put("status", "completed");
                    failData.put("error", "분석 실패: " + analysisResult.optString("message"));
                    PythonBridge.tasks.put(user.getUserNo(), failData);
                }
            }

            @Override
            public void onError(JSONObject errorResult) {
                JSONObject failData = new JSONObject();
                failData.put("status", "completed");
                failData.put("error", "서버 내부 에러: " + errorResult.optString("message"));
                PythonBridge.tasks.put(user.getUserNo(), failData);
            }
        });
        
        res.put("status", "started");
        response.getWriter().write(res.toString());
    }
}
