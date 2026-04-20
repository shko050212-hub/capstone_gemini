package com.ytvocab.dao;

import com.ytvocab.util.DBManager;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class VocabularyDAO {

    // 입력받은 단어가 vocabulary 테이블에 없으면 넣고 ID반환, 있으면 바로 ID반환
    public int saveOrGetWord(String expression) {
        String selectSql = "SELECT word_id FROM vocabulary WHERE expression = ?";
        String insertSql = "INSERT INTO vocabulary (expression, difficulty_level, is_idiom) VALUES (?, ?, ?)";
        
        try (Connection conn = DBManager.getConnection()) {
            
            // 1. 조회
            try (PreparedStatement selectStmt = conn.prepareStatement(selectSql)) {
                selectStmt.setString(1, expression);
                try (ResultSet rs = selectStmt.executeQuery()) {
                    if (rs.next()) {
                        return rs.getInt("word_id");
                    }
                }
            }
            
            // 2. 없으면 삽입
            try (PreparedStatement insertStmt = conn.prepareStatement(insertSql, PreparedStatement.RETURN_GENERATED_KEYS)) {
                insertStmt.setString(1, expression);
                insertStmt.setInt(2, 1); // 기본 난이도 1
                insertStmt.setBoolean(3, expression.contains(" ")); // 공백이 있으면 숙어로 취급
                
                insertStmt.executeUpdate();
                try (ResultSet rs = insertStmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }
}
