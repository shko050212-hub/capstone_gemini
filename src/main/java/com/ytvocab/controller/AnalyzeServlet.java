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
        if (user == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        String youtubeUrl = request.getParameter("youtubeUrl");
        if (youtubeUrl == null || youtubeUrl.isEmpty()) {
            response.sendRedirect("main.jsp?error=url_missing");
            return;
        }

        try {
            JSONObject analysisResult = PythonBridge.analyzeVideo(youtubeUrl);
            
            if ("success".equals(analysisResult.getString("status"))) {
                JSONArray vocabArray = analysisResult.getJSONArray("vocabulary");
                int addedWords = 0;
                
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
                
                // TODO: 영상 히스토리 테이블에도 저장 (생략)
                
                response.sendRedirect("main.jsp?msg=" + java.net.URLEncoder.encode("분석 완료! 총 " + addedWords + "개의 학습 단어가 추가되었습니다.", "UTF-8"));
            } else {
                response.sendRedirect("main.jsp?error=" + java.net.URLEncoder.encode("분석 실패: " + analysisResult.getString("message"), "UTF-8"));
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("main.jsp?error=" + java.net.URLEncoder.encode("서버 내부 에러가 발생했습니다.", "UTF-8"));
        }
    }
}
