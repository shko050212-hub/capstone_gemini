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
        <% String errorMsg = request.getParameter("error"); 
           if(errorMsg != null) { %>
            <div class="msg error" style="background-color:#fee2e2; color:#ef4444; padding:1rem; border-radius:10px; margin-bottom:1rem;"><%= errorMsg %></div>
        <% } %>
        
        <p style="color: #94a3b8; margin-bottom: 1rem;">유튜브 영상의 영어 문장을 AI로 분석하여 나만의 단어장을 만드세요.</p>
        
        <form action="<%=request.getContextPath()%>/analyze" method="post" id="analyzeForm">
            <div class="input-group">
                <input type="url" name="youtubeUrl" placeholder="https://www.youtube.com/watch?v=..." required>
                <button class="btn" type="submit" style="width: auto;" id="analyzeBtn">Analyze Video</button>
            </div>
            <p id="loadingText" style="display:none; color:var(--primary); text-align:center; font-weight:bold;">🔥 AI가 영상을 분석 중입니다... 잠시만 기다려 주세요!</p>
            
            <div id="progressContainer" style="display:none; margin-top:1.5rem;">
                <p id="progressMessage" style="color:var(--primary); font-weight:bold; margin-bottom: 0.5rem; text-align: center;">분석 작업을 준비 중입니다...</p>
                <div style="width: 100%; background-color: #e2e8f0; border-radius: 999px; height: 1.5rem; overflow: hidden; position: relative;">
                    <div id="progressBar" style="width: 0%; height: 100%; background: linear-gradient(90deg, #ec4899, #3b82f6); transition: width 0.5s ease;"></div>
                    <span id="progressPercent" style="position: absolute; top:0; left:0; width: 100%; text-align: center; color: white; font-weight: bold; font-size: 0.9rem; line-height: 1.5rem; text-shadow: 1px 1px 2px rgba(0,0,0,0.5);">0%</span>
                </div>
            </div>
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
        document.getElementById('analyzeForm').onsubmit = function(e) {
            e.preventDefault(); // Prevent standard form submit
            const urlInput = document.querySelector('input[name="youtubeUrl"]');
            
            document.getElementById('analyzeBtn').style.display = 'none';
            document.getElementById('progressContainer').style.display = 'block';
            
            fetch('<%=request.getContextPath()%>/analyze', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'youtubeUrl=' + encodeURIComponent(urlInput.value)
            })
            .then(res => res.json())
            .then(data => {
                if(data.status === 'error') {
                    window.location.href = 'main.jsp?error=' + encodeURIComponent(data.message);
                    return;
                }
                
                // Start polling progress
                const timer = setInterval(() => {
                    fetch('<%=request.getContextPath()%>/analyze-progress')
                    .then(r => r.json())
                    .then(p => {
                        if (p.status === 'running') {
                            document.getElementById('progressBar').style.width = p.percent + '%';
                            document.getElementById('progressPercent').innerText = p.percent + '%';
                            document.getElementById('progressMessage').innerText = '🔥 ' + p.message;
                        } else if (p.status === 'completed') {
                            clearInterval(timer);
                            if (p.error) {
                                window.location.href = 'main.jsp?error=' + encodeURIComponent(p.error);
                            } else {
                                window.location.href = 'main.jsp?msg=' + encodeURIComponent(p.msg);
                            }
                        }
                    });
                }, 1000);
            })
            .catch(err => {
                window.location.href = 'main.jsp?error=' + encodeURIComponent("네트워크 에러가 발생했습니다.");
            });
        };
    </script>
</body>
</html>
