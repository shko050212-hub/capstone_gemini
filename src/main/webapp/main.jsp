<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ytvocab.model.User" %>
<%@ page import="com.ytvocab.dao.ProgressDAO" %>
<%
    User authUser = (User) session.getAttribute("authUser");
    if(authUser == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    ProgressDAO pDao = new ProgressDAO();
    int totalWords = pDao.getCountByStatus(authUser.getUserNo(), null);
    int learningWords = pDao.getCountByStatus(authUser.getUserNo(), "LEARNING") + pDao.getCountByStatus(authUser.getUserNo(), "NEW");
    int masteredWords = pDao.getCountByStatus(authUser.getUserNo(), "MASTERED");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>YT-Vocab | Dashboard</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="container container-large">
        <div class="dashboard-header">
            <h2 class="title" style="margin-bottom:0;">Welcome, <%= authUser.getUserId() %>!</h2>
            <a href="index.jsp" style="color: #ef4444; text-decoration: none; font-weight: bold;">Logout</a>
        </div>
        
        <% String msg = request.getParameter("msg"); 
           if(msg != null) { %>
            <div class="msg success"><%= msg %></div>
        <% } %>
        
        <p style="color: #94a3b8; margin-bottom: 1rem;">유튜브 영상의 영어 문장을 AI로 분석하여 나만의 단어장을 만드세요.</p>
        
        <form action="<%=request.getContextPath()%>/analyze" method="post" id="analyzeForm">
            <div class="input-group">
                <input type="url" name="youtubeUrl" placeholder="https://www.youtube.com/watch?v=..." required>
                <button class="btn" type="submit" style="width: auto;" id="analyzeBtn">Analyze Video</button>
            </div>
            <p id="loadingText" style="display:none; color:var(--primary); text-align:center; font-weight:bold;">🔥 AI가 영상을 분석 중입니다... 잠시만 기다려 주세요!</p>
        </form>
        
        <div style="text-align: center; margin-top: 1rem; margin-bottom: 2rem;">
            <a href="<%=request.getContextPath()%>/study" class="btn" style="text-decoration: none; display: inline-block; max-width: 300px;">🎓 오늘의 영단어 복습하기 (테스트)</a>
        </div>

        <div class="stats-grid">
            <div class="stat-card">
                <h3><%= totalWords %></h3>
                <p>전체 누적 단어</p>
            </div>
            <div class="stat-card">
                <h3><%= learningWords %></h3>
                <p>학습 중인 단어 (NEW/LEARNING)</p>
            </div>
            <div class="stat-card">
                <h3><%= masteredWords %></h3>
                <p>마스터한 숙어 및 단어 (MASTERED)</p>
            </div>
        </div>
    </div>
    
    <script>
        document.getElementById('analyzeForm').onsubmit = function() {
            document.getElementById('analyzeBtn').style.display = 'none';
            document.getElementById('loadingText').style.display = 'block';
        }
    </script>
</body>
</html>
