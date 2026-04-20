<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, com.ytvocab.util.DBManager" %>
<!DOCTYPE html>
<html>
<head>
    <title>DB Viewer (Easter Egg)</title>
    <style>
        body { font-family: 'Inter', sans-serif; padding: 20px; background: #0f172a; color: #fff; }
        h2 { color: #38bdf8; }
        table { border-collapse: collapse; width: 100%; margin-bottom: 30px; background: #1e293b; border-radius: 8px; overflow: hidden; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #334155; }
        th { background: #0f172a; color: #94a3b8; }
        tr:hover { background: #334155; }
    </style>
</head>
<body>
    <div style="max-width: 1000px; margin: auto;">
        <h2>[ 1. Users Table ]</h2>
        <table>
            <tr><th>No</th><th>ID</th><th>Email</th><th>Created</th></tr>
            <% 
                try (Connection conn = DBManager.getConnection();
                     Statement stmt = conn.createStatement();
                     ResultSet rs = stmt.executeQuery("SELECT user_no, id, email, created_at FROM users LIMIT 10")) {
                    while(rs.next()) {
            %>
            <tr>
                <td><%= rs.getInt("user_no") %></td>
                <td><%= rs.getString("id") %></td>
                <td><%= rs.getString("email") %></td>
                <td><%= rs.getTimestamp("created_at") %></td>
            </tr>
            <%      } 
                } catch(Exception e) { out.print("<tr><td colspan='4'>" + e.getMessage() + "</td></tr>"); } %>
        </table>

        <h2>[ 2. Vocabulary Table ]</h2>
        <table>
            <tr><th>Word ID</th><th>Expression</th><th>Level</th></tr>
            <% 
                try (Connection conn = DBManager.getConnection();
                     Statement stmt = conn.createStatement();
                     ResultSet rs = stmt.executeQuery("SELECT word_id, expression, difficulty_level FROM vocabulary LIMIT 15")) {
                    while(rs.next()) {
            %>
            <tr>
                <td><%= rs.getInt("word_id") %></td>
                <td><%= rs.getString("expression") %></td>
                <td><%= rs.getInt("difficulty_level") %></td>
            </tr>
            <%      } 
                } catch(Exception e) { out.print("<tr><td colspan='3'>" + e.getMessage() + "</td></tr>"); } %>
        </table>

        <h2>[ 3. Learning Progress ]</h2>
        <table>
            <tr><th>User No</th><th>Word ID</th><th>Status</th><th>Streak</th><th>Next Test</th></tr>
            <% 
                try (Connection conn = DBManager.getConnection();
                     Statement stmt = conn.createStatement();
                     ResultSet rs = stmt.executeQuery("SELECT user_no, word_id, status, correct_streak, next_test_date FROM learning_progress LIMIT 15")) {
                    while(rs.next()) {
            %>
            <tr>
                <td><%= rs.getInt("user_no") %></td>
                <td><%= rs.getInt("word_id") %></td>
                <td><%= rs.getString("status") %></td>
                <td><%= rs.getInt("correct_streak") %></td>
                <td><%= rs.getDate("next_test_date") %></td>
            </tr>
            <%      } 
                } catch(Exception e) { out.print("<tr><td colspan='5'>" + e.getMessage() + "</td></tr>"); } %>
        </table>
    </div>
</body>
</html>
