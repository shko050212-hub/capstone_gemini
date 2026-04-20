package com.ytvocab.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBManager {
    // 실제 사용 시 환경변수 또는 프로퍼티 파일에서 로드하는 것이 좋습니다.
    private static final String URL = "jdbc:mariadb://capstone-db.cfw4cygk4dks.ap-northeast-2.rds.amazonaws.com:3306/testdb?allowPublicKeyRetrieval=true";
    private static final String USER = "admin"; // AWS RDS 마스터 사용자
    private static final String PASSWORD = "CapstonePassword123!"; // AWS RDS 암호

    static {
        try {
            Class.forName("org.mariadb.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
