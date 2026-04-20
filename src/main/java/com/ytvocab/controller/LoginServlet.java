package com.ytvocab.controller;

import com.ytvocab.dao.UserDAO;
import com.ytvocab.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String userId = request.getParameter("userId");
        String pass = request.getParameter("password");

        User user = userDAO.login(userId, pass);

        if (user != null) {
            HttpSession session = request.getSession();
            session.setAttribute("authUser", user);
            response.sendRedirect("main.jsp");
        } else {
            response.sendRedirect("index.jsp?error=invalid");
        }
    }
}
