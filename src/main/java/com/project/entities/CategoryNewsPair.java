package com.project.entities;

import java.util.ArrayList;

public class CategoryNewsPair {
    private String categoryName;
    private boolean categoryAvailability;
    private ArrayList<News> news;

    // Constructor
    public CategoryNewsPair(String categoryName, boolean categoryAvailability, ArrayList<News> news) {
        this.categoryName = categoryName;
        this.categoryAvailability = categoryAvailability;
        this.news = news;
    }

    // Getter and Setter for categoryName
    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    // Getter and Setter for categoryAvailability
    public boolean isCategoryAvailability() {
        return categoryAvailability;
    }

    public void setCategoryAvailability(boolean categoryAvailability) {
        this.categoryAvailability = categoryAvailability;
    }

    // Getter and Setter for news
    public ArrayList<News> getNews() {
        return news;
    }

    public void setNews(ArrayList<News> news) {
        this.news = news;
    }
}
