package com.ytvocab.model;

public class Vocabulary {
    private int wordId;
    private String expression;
    private String meaning;
    private int difficultyLevel;
    private boolean isIdiom;

    public Vocabulary() {}
    
    public int getWordId() { return wordId; }
    public void setWordId(int wordId) { this.wordId = wordId; }
    public String getExpression() { return expression; }
    public void setExpression(String expression) { this.expression = expression; }
    public String getMeaning() { return meaning; }
    public void setMeaning(String meaning) { this.meaning = meaning; }
    public int getDifficultyLevel() { return difficultyLevel; }
    public void setDifficultyLevel(int difficultyLevel) { this.difficultyLevel = difficultyLevel; }
    public boolean isIdiom() { return isIdiom; }
    public void setIsIdiom(boolean isIdiom) { this.isIdiom = isIdiom; }
}
