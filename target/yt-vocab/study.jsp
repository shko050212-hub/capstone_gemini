<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ytvocab.model.LearningProgress" %>
<%@ page import="java.util.List" %>
<%
    List<LearningProgress> quizList = (List<LearningProgress>) request.getAttribute("quizList");
    int total = quizList != null ? quizList.size() : 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>YT-Vocab | Review</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .flashcard-container {
            perspective: 1000px;
            width: 100%;
            height: 300px;
            margin: 2rem 0;
        }
        .flashcard {
            width: 100%;
            height: 100%;
            position: relative;
            transition: transform 0.6s;
            transform-style: preserve-3d;
            cursor: pointer;
        }
        .flashcard.is-flipped {
            transform: rotateY(180deg);
        }
        .card-face {
            position: absolute;
            width: 100%;
            height: 100%;
            -webkit-backface-visibility: hidden; /* Safari */
            backface-visibility: hidden;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-direction: column;
            border-radius: 1.5rem;
            box-shadow: 0 10px 25px rgba(0,0,0,0.3);
        }
        .card-front {
            background: linear-gradient(135deg, rgba(30, 41, 59, 0.9), rgba(15, 23, 42, 0.9));
            border: 1px solid var(--border);
        }
        .card-back {
            background: linear-gradient(135deg, rgba(59, 130, 246, 0.2), rgba(139, 92, 246, 0.2));
            transform: rotateY(180deg);
            border: 1px solid var(--primary);
        }
        .word-text {
            font-size: 3rem;
            font-weight: 800;
            margin-bottom: 1rem;
            color: var(--primary);
            text-transform: lowercase;
        }
        .action-buttons {
            display: flex;
            gap: 1rem;
            margin-top: 2rem;
            opacity: 0;
            pointer-events: none;
            transition: opacity 0.3s;
        }
        .flashcard.is-flipped ~ .action-buttons {
            opacity: 1;
            pointer-events: auto;
        }
        .btn-correct { background: var(--success); }
        .btn-wrong { background: var(--error); }
    </style>
</head>
<body>
    <div class="container container-large" style="max-width: 600px;">
        <div class="dashboard-header">
            <h2 class="title" style="margin-bottom:0; font-size: 1.8rem;">Daily Quiz</h2>
            <a href="main.jsp" style="color: #94a3b8; text-decoration: none;">&larr; Back</a>
        </div>

        <% if (total == 0) { %>
            <div class="msg success">
                🎉 축하합니다! 오늘 복습할 단어가 없습니다. 휴식을 취하거나 새로운 영상을 분석하세요!
            </div>
            <div style="text-align: center;"><a href="main.jsp" class="btn" style="text-decoration: none;">메인으로 돌아가기</a></div>
        <% } else { %>
            <div style="text-align: center; color: #94a3b8; margin-bottom: 1rem;">
                <span id="currentIndex">1</span> / <%= total %> Words
            </div>
            
            <div class="flashcard-container" onclick="flipCard()">
                <div class="flashcard" id="card">
                    <!-- 앞면: 영단어 -->
                    <div class="card-front">
                        <div class="word-text" id="frontWord"></div>
                        <p style="color: #cbd5e1;">카드를 눌러 정답 표시</p>
                    </div>
                    <!-- 뒷면: 확인용 -->
                    <div class="card-back">
                        <div class="word-text" id="backWord" style="color:var(--text-color);"></div>
                        <p style="color: #94a3b8; font-size:1.2rem;">해당 단어의 뜻을 알고 있었나요?</p>
                    </div>
                </div>
                
                <div class="action-buttons" style="justify-content: center;">
                    <button class="btn btn-wrong" onclick="submitAnswer(false, event)">❌ 몰랐어요</button>
                    <button class="btn btn-correct" onclick="submitAnswer(true, event)">✅ 알았어요</button>
                </div>
            </div>
        <% } %>
    </div>

    <script>
        const words = [
            <% if (quizList != null) {
                for (int i=0; i<quizList.size(); i++) {
                    LearningProgress p = quizList.get(i);
            %>
                { id: <%= p.getWordId() %>, text: "<%= p.getExpression().replace("\"", "\\\"") %>" }<%= i < quizList.size() - 1 ? "," : "" %>
            <%  }
               } %>
        ];

        let index = 0;
        
        function loadCard() {
            if (index >= words.length) {
                alert("오늘의 퀴즈를 모두 완료했습니다! 🎉");
                window.location.href = "main.jsp";
                return;
            }
            document.getElementById('card').classList.remove('is-flipped');
            document.getElementById('currentIndex').innerText = (index + 1);
            document.getElementById('frontWord').innerText = words[index].text;
            document.getElementById('backWord').innerText = words[index].text;
        }

        function flipCard() {
            document.getElementById('card').classList.add('is-flipped');
        }

        function submitAnswer(isCorrect, e) {
            e.stopPropagation(); // 카드 플립 방지
            const currentWord = words[index];

            // 1. 서버로 결과 전송
            fetch('<%=request.getContextPath()%>/study', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'wordId=' + currentWord.id + '&isCorrect=' + isCorrect
            }).then(response => {
                // 2. 다음 카드로 이동
                index++;
                loadCard();
            });
        }

        if (words.length > 0) {
            loadCard();
        }
    </script>
</body>
</html>
