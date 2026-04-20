package com.ytvocab.controller;

import com.ytvocab.dao.UserDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/join")
public class JoinServlet extends HttpServlet {
    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String userId = request.getParameter("userId");
        String pass = request.getParameter("password");
        String email = request.getParameter("email");

        boolean success = userDAO.register(userId, pass, email);

        if (success) {
            response.sendRedirect("index.jsp?msg=registered");
        } else {
            response.sendRedirect("index.jsp?error=register_failed");
        }
    }
}
