package com.project.entities;

import java.sql.Timestamp;

public class Draft {
    private int draftId;
    private String draftTitle;
    private int categoryId;
    private Timestamp lastEditedOn;
    private boolean isPublished;

    public Draft(int draftId, String draftTitle, int categoryId, Timestamp lastEditedOn, boolean isPublished) {
        this.draftId = draftId;
        this.draftTitle = draftTitle;
        this.categoryId = categoryId;
        this.lastEditedOn = lastEditedOn;
        this.isPublished = isPublished;
    }

    // getters and setters
    public int getDraftId() {
        return draftId;
    }

    public void setDraftId(int draftId) {
        this.draftId = draftId;
    }

    public String getDraftTitle() {
        return draftTitle;
    }

    public void setDraftTitle(String draftTitle) {
        this.draftTitle = draftTitle;
    }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public Timestamp getLastEditedOn() {
        return lastEditedOn;
    }

    public void setLastEditedOn(Timestamp lastEditedOn) {
        this.lastEditedOn = lastEditedOn;
    }

    public boolean isPublished() {
        return isPublished;
    }

    public void setPublished(boolean published) {
        isPublished = published;
    }
}
