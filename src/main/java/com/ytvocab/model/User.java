package com.ytvocab.model;

import java.sql.Timestamp;

public class User {
    private int userNo;
    private String userId;
    private String password;
    private String email;
    private Timestamp regDate;

    public User() {}

    public User(int userNo, String userId, String password, String email, Timestamp regDate) {
        this.userNo = userNo;
        this.userId = userId;
        this.password = password;
        this.email = email;
        this.regDate = regDate;
    }

    public int getUserNo() { return userNo; }
    public void setUserNo(int userNo) { this.userNo = userNo; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public Timestamp getRegDate() { return regDate; }
    public void setRegDate(Timestamp regDate) { this.regDate = regDate; }
}
