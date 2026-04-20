package com.ytvocab.controller;

import com.ytvocab.dao.ProgressDAO;
import com.ytvocab.model.LearningProgress;
import com.ytvocab.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/study")
public class StudyServlet extends HttpServlet {

    private ProgressDAO progressDAO = new ProgressDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("authUser");
        if (user == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        List<LearningProgress> quizList = progressDAO.getTodayQuizList(user.getUserNo());
        request.setAttribute("quizList", quizList);
        // JSP로 포워드
        request.getRequestDispatcher("study.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("authUser");
        if (user == null) {
            return;
        }

        try {
            int wordId = Integer.parseInt(request.getParameter("wordId"));
            boolean isCorrect = Boolean.parseBoolean(request.getParameter("isCorrect"));
            
            progressDAO.updateQuizResult(user.getUserNo(), wordId, isCorrect);
            
            // Ajax 응답용 (200 OK)
            response.setStatus(HttpServletResponse.SC_OK);
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}
