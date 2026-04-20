package com.ytvocab.dao;

import com.ytvocab.model.User;
import com.ytvocab.util.DBManager;

import com.ytvocab.util.PasswordUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class UserDAO {
    
    public User login(String userId, String password) {
        String sql = "SELECT * FROM users WHERE user_id = ? AND password = ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, userId);
            // 비밀번호 해싱 적용
            pstmt.setString(2, PasswordUtil.hashPassword(password));
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    User user = new User();
                    user.setUserNo(rs.getInt("user_no"));
                    user.setUserId(rs.getString("user_id"));
                    user.setPassword(rs.getString("password"));
                    user.setEmail(rs.getString("email"));
                    user.setRegDate(rs.getTimestamp("reg_date"));
                    return user;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean register(String userId, String password, String email) {
        String sql = "INSERT INTO users (user_id, password, email) VALUES (?, ?, ?)";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
             
            pstmt.setString(1, userId);
            // 들어온 원본 비밀번호를 해싱하여 DB에 암호화된 상태로 저장
            pstmt.setString(2, PasswordUtil.hashPassword(password));
            pstmt.setString(3, email);
            
            return pstmt.executeUpdate() > 0;
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
