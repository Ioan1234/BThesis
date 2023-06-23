package com.project.entities;

import java.sql.Timestamp;

public class NewsArticle {
    private int newsId;
    private int newsAvailability;
    private String newsTitle;
    private Timestamp newsPostedOn;
    private String categoryName;
    private int categoryAvailability;
    public int getNewsId() {
        return newsId;
    }

    public void setNewsId(int newsId) {
        this.newsId = newsId;
    }

    public int getNewsAvailability() {
        return newsAvailability;
    }

    public void setNewsAvailability(int newsAvailability) {
        this.newsAvailability = newsAvailability;
    }

    public String getNewsTitle() {
        return newsTitle;
    }

    public void setNewsTitle(String newsTitle) {
        this.newsTitle = newsTitle;
    }

    public Timestamp getNewsPostedOn() {
        return newsPostedOn;
    }

    public void setNewsPostedOn(Timestamp newsPostedOn) {
        this.newsPostedOn = newsPostedOn;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }
    public int getCategoryAvailability() {
        return categoryAvailability;
    }

    public void setCategoryAvailability(int categoryAvailability) {
        this.categoryAvailability = categoryAvailability;
    }

}
