package com.project.entities;
import java.util.ArrayList;
import java.util.Date;
public class News {
    private int newsId;
    private int draftId;
    private String newsTitle;
    private int categoryId;
    private byte[] newsContent;
    private  Date newsPostedOn;
    private boolean newsAvailability;
    private boolean isDraft;

    public News(int newsId, int draftId, String newsTitle, int categoryId, byte[] newsContent, Date newsPostedOn, boolean newsAvailability, boolean isDraft) {
        this.newsId = newsId;
        this.draftId = draftId;
        this.newsTitle = newsTitle;
        this.categoryId = categoryId;
        this.newsContent = newsContent;
        this.newsPostedOn = newsPostedOn;
        this.newsAvailability = newsAvailability;
        this.isDraft = isDraft;
    }

    public int getNewsId() {
        return newsId;
    }

    public int getDraftId() {
        return draftId;
    }

    public String getNewsTitle() {
        return newsTitle;
    }

    public int getCategoryId() {
        return categoryId;
    }

    public byte[] getNewsContent() {
        return newsContent;
    }

    public Date getNewsPostedOn() {
        return newsPostedOn;
    }

    public boolean isNewsAvailability() {
        return newsAvailability;
    }

    public boolean isDraft() {
        return isDraft;
    }
}
