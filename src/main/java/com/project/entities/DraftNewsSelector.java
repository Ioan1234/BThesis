package com.project.entities;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.Map;

public class DraftNewsSelector extends Connections {

    public ArrayList<News> getDraftNews() throws SQLException {
        Connection conn = Connections.getConnection();

        String sql = "SELECT n.news_id, n.draft_id, n.news_title, n.news_posted_on, n.category_id, n.news_content, n.news_availability, n.is_draft, a.surname, a.name FROM news n JOIN draft_authors da ON n.draft_id = da.draft_id JOIN authors a ON da.author_id = a.author_id WHERE n.is_draft = 1 ORDER BY n.news_id";
        PreparedStatement getDraftNews = conn.prepareStatement(sql);
        ResultSet getDraftNewsRESULT = getDraftNews.executeQuery();

        ArrayList<News> draftNews = new ArrayList<News>();

        while(getDraftNewsRESULT.next()){
            int newsId = getDraftNewsRESULT.getInt("news_id");
            int draftId = getDraftNewsRESULT.getInt("draft_id");
            String newsTitle = getDraftNewsRESULT.getString("news_title");
            int categoryId = getDraftNewsRESULT.getInt("category_id");
            byte[] newsContent = getDraftNewsRESULT.getBytes("news_content");
            Date newsPostedOn = getDraftNewsRESULT.getDate("news_posted_on");
            boolean newsAvailability = getDraftNewsRESULT.getBoolean("news_availability");
            boolean isDraft = getDraftNewsRESULT.getBoolean("is_draft");
            String authorName = getDraftNewsRESULT.getString("name");
            String authorSurname = getDraftNewsRESULT.getString("surname");

            Author author = new Author();
            author.setName(authorName);
            author.setSurname(authorSurname);

            News newsObj = new News(newsId, draftId, newsTitle, categoryId, newsContent, newsPostedOn, newsAvailability, isDraft);
            newsObj.setAuthor(author);
            draftNews.add(newsObj);
        }

        return draftNews;
    }

    public Map<String, CategoryNewsPair> getCategorizedDraftNews() throws SQLException {
        Map<String, CategoryNewsPair> categorizedDraftNews = new LinkedHashMap<>();
        ArrayList<News> draftNews = this.getDraftNews();

        for (News news : draftNews) {
            String sql = "SELECT category_name, category_availability FROM categories WHERE category_id = " + news.getCategoryId();
            PreparedStatement stmt = getConnection().prepareStatement(sql);
            ResultSet resultSet = stmt.executeQuery();

            if (resultSet.next()) {
                String category = resultSet.getString(1);
                boolean availability = resultSet.getBoolean(2);
                categorizedDraftNews.putIfAbsent(category, new CategoryNewsPair(category, availability, new ArrayList<>()));
                categorizedDraftNews.get(category).getNews().add(news);
            }
        }

        return categorizedDraftNews;
    }
    public ArrayList<News> getHotNews() throws SQLException {
        Connection conn = Connections.getConnection();

        // Include `news_availability = 1` in the WHERE clause to only fetch non-archived news
        String sql = "SELECT news.* FROM news INNER JOIN categories ON news.category_id = categories.category_id WHERE news.draft_id IS NOT NULL AND categories.category_availability = 1 AND news.news_availability = 1 ORDER BY news.news_posted_on DESC LIMIT 5";
        PreparedStatement getHotNews = conn.prepareStatement(sql);
        ResultSet getHotNewsRESULT = getHotNews.executeQuery();

        ArrayList<News> hotNews = new ArrayList<>();

        while (getHotNewsRESULT.next()) {
            int newsId = getHotNewsRESULT.getInt("news_id");
            int draftId = getHotNewsRESULT.getInt("draft_id");
            String newsTitle = getHotNewsRESULT.getString("news_title");
            int categoryId = getHotNewsRESULT.getInt("category_id");
            byte[] newsContent = getHotNewsRESULT.getBytes("news_content");
            Date newsPostedOn = getHotNewsRESULT.getDate("news_posted_on");
            boolean newsAvailability = getHotNewsRESULT.getBoolean("news_availability");
            boolean isDraft = getHotNewsRESULT.getBoolean("is_draft");

            News newsObj = new News(newsId, draftId, newsTitle, categoryId, newsContent, newsPostedOn, newsAvailability, isDraft);
            hotNews.add(newsObj);
        }

        return hotNews;
    }


}