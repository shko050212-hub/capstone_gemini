package com.ytvocab.model;

import java.sql.Date;

public class LearningProgress {
    private int progressId;
    private int userNo;
    private int wordId;
    private String status;
    private int correctStreak;
    private Date nextTestDate;
    
    // 조인을 위해 같이 담을 변수
    private String expression;

    public LearningProgress() {}

    public int getProgressId() { return progressId; }
    public void setProgressId(int progressId) { this.progressId = progressId; }
    public int getUserNo() { return userNo; }
    public void setUserNo(int userNo) { this.userNo = userNo; }
    public int getWordId() { return wordId; }
    public void setWordId(int wordId) { this.wordId = wordId; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public int getCorrectStreak() { return correctStreak; }
    public void setCorrectStreak(int correctStreak) { this.correctStreak = correctStreak; }
    public Date getNextTestDate() { return nextTestDate; }
    public void setNextTestDate(Date nextTestDate) { this.nextTestDate = nextTestDate; }
    
    public String getExpression() { return expression; }
    public void setExpression(String expression) { this.expression = expression; }
}
