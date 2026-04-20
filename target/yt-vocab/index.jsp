<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>YT-Vocab | Login</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="container" id="login-container">
        <h1 class="title">YT-Vocab</h1>
        <p style="text-align: center; color: #94a3b8; margin-bottom: 2rem;">Personalized English Learning via YouTube</p>
        
        <% 
            String error = request.getParameter("error");
            String msg = request.getParameter("msg");
            if("invalid".equals(error)) { 
        %>
            <div class="msg error">Invalid Username or Password</div>
        <% } else if("register_failed".equals(error)) { %>
            <div class="msg error">Registration failed. ID might be in use.</div>
        <% } else if("registered".equals(msg)) { %>
            <div class="msg success">Successfully registered! Please log in.</div>
        <% } %>

        <form action="<%=request.getContextPath()%>/login" method="post">
            <div class="form-group">
                <label for="userId">Username</label>
                <input type="text" id="userId" name="userId" required placeholder="Enter your username">
            </div>
            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" required placeholder="Enter your password">
            </div>
            <button type="submit" class="btn">Sign In</button>
        </form>
        <a href="#" class="toggle-link" onclick="toggleForms(event)">Don't have an account? Sign up</a>
    </div>

    <!-- Register Form (Hidden by default) -->
    <div class="container hidden" id="register-container">
        <h1 class="title">Join Us</h1>
        <form action="<%=request.getContextPath()%>/join" method="post">
            <div class="form-group">
                <label for="regId">Username</label>
                <input type="text" id="regId" name="userId" required placeholder="Choose a username">
            </div>
            <div class="form-group">
                <label for="email">Email</label>
                <input type="email" id="email" name="email" required placeholder="Your email address">
            </div>
            <div class="form-group">
                <label for="regPass">Password</label>
                <input type="password" id="regPass" name="password" required placeholder="Create a password">
            </div>
            <button type="submit" class="btn">Create Account</button>
        </form>
        <a href="#" class="toggle-link" onclick="toggleForms(event)">Already using YT-Vocab? Sign in</a>
    </div>

    <script>
        function toggleForms(e) {
            e.preventDefault();
            document.getElementById('login-container').classList.toggle('hidden');
            document.getElementById('register-container').classList.toggle('hidden');
        }
    </script>
</body>
</html>
