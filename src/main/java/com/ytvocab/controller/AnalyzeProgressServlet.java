package com.ytvocab.controller;

import com.ytvocab.model.User;
import com.ytvocab.util.PythonBridge;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/analyze-progress")
public class AnalyzeProgressServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
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

        JSONObject progress = PythonBridge.tasks.get(user.getUserNo());
        if (progress == null) {
            res.put("status", "idle");
            response.getWriter().write(res.toString());
            return;
        }

        response.getWriter().write(progress.toString());
        
        if ("completed".equals(progress.optString("status"))) {
            PythonBridge.tasks.remove(user.getUserNo());
        }
    }
}
