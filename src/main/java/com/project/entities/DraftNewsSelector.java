package com.project.entities;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.*;

public class DraftNewsSelector extends Connections {

    public ArrayList<News> getDraftNews() throws SQLException {
        Connection conn = Connections.getConnection();

        String sql = "SELECT n.news_id, n.draft_id, n.news_title, n.news_posted_on, n.category_id, n.news_content, n.news_availability, n.is_draft, a.surname, a.name FROM news n JOIN draft_authors da ON n.draft_id = da.draft_id JOIN authors a ON da.author_id = a.author_id WHERE n.is_draft = 1 ORDER BY n.news_posted_on DESC";
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
    public List<String> getAllCategories() throws SQLException {
        List<String> categories = new ArrayList<>();
        String sql = "SELECT DISTINCT category_name FROM categories WHERE category_availability=1";
        PreparedStatement stmt = getConnection().prepareStatement(sql);
        ResultSet resultSet = stmt.executeQuery();

        while (resultSet.next()) {
            categories.add(resultSet.getString(1));
        }

        return categories;
    }
    public List<News> getNewsByCategory(String category) throws SQLException {
        List<News> newsList = new ArrayList<>();
        Connection conn = Connections.getConnection();

        String sql = "SELECT n.news_id, n.draft_id, n.news_title, n.news_posted_on, n.category_id, n.news_content, n.news_availability, n.is_draft, a.surname, a.name FROM news n JOIN draft_authors da ON n.draft_id = da.draft_id JOIN authors a ON da.author_id = a.author_id JOIN categories c ON n.category_id = c.category_id WHERE c.category_name = ? ORDER BY n.news_id";
        PreparedStatement stmt = conn.prepareStatement(sql);
        stmt.setString(1, category);
        ResultSet resultSet = stmt.executeQuery();

        while (resultSet.next()) {
            int newsId = resultSet.getInt("news_id");
            int draftId = resultSet.getInt("draft_id");
            String newsTitle = resultSet.getString("news_title");
            int categoryId = resultSet.getInt("category_id");
            byte[] newsContent = resultSet.getBytes("news_content");
            Date newsPostedOn = resultSet.getDate("news_posted_on");
            boolean newsAvailability = resultSet.getBoolean("news_availability");
            boolean isDraft = resultSet.getBoolean("is_draft");
            String authorName = resultSet.getString("name");
            String authorSurname = resultSet.getString("surname");

            Author author = new Author();
            author.setName(authorName);
            author.setSurname(authorSurname);

            News newsObj = new News(newsId, draftId, newsTitle, categoryId, newsContent, newsPostedOn, newsAvailability, isDraft);
            newsObj.setAuthor(author);
            newsList.add(newsObj);
        }

        return newsList;
    }
    public List<String> getAllAuthors() throws SQLException {
        List<String> authorsList = new ArrayList<>();
        String sql = "SELECT DISTINCT a.name, a.surname " +
                "FROM authors a " +
                "INNER JOIN draft_authors da ON a.author_id = da.author_id " +
                "INNER JOIN draft d ON da.draft_id = d.draft_id " +
                "INNER JOIN news n ON d.draft_id = n.draft_id WHERE news_availability=1";
        PreparedStatement stmt = getConnection().prepareStatement(sql);
        ResultSet resultSet = stmt.executeQuery();

        while (resultSet.next()) {
            authorsList.add(resultSet.getString("name") + " " + resultSet.getString("surname"));
        }

        return authorsList;
    }
    public Map<String, List<News>> getCategorizedNewsByAuthor(String author) throws SQLException {
        Map<String, List<News>> categorizedNewsMap = new HashMap<>();
        String[] authorNames = author.split(" "); // assuming author is in "name surname" format

        String sql = "SELECT n.* " +
                "FROM news n " +
                "INNER JOIN draft d ON n.draft_id = d.draft_id " +
                "INNER JOIN draft_authors da ON d.draft_id = da.draft_id " +
                "INNER JOIN authors a ON da.author_id = a.author_id " +
                "WHERE a.name = ? AND a.surname = ?";
        PreparedStatement stmt = getConnection().prepareStatement(sql);
        stmt.setString(1, authorNames[0]);
        stmt.setString(2, authorNames[1]);

        ResultSet resultSet = stmt.executeQuery();

        while (resultSet.next()) {
            int newsId = resultSet.getInt("news_id");
            int draftId = resultSet.getInt("draft_id");
            String newsTitle = resultSet.getString("news_title");
            int categoryId = resultSet.getInt("category_id");
            byte[] newsContent = resultSet.getBytes("news_content");
            Date newsPostedOn = resultSet.getDate("news_posted_on");
            boolean newsAvailability = resultSet.getBoolean("news_availability");
            boolean isDraft = resultSet.getBoolean("is_draft");

            News newsObj = new News(newsId, draftId, newsTitle, categoryId, newsContent, newsPostedOn, newsAvailability, isDraft);

            // Getting the category name for the current news item
            String categorySql = "SELECT category_name FROM categories WHERE category_id = ?";
            PreparedStatement categoryStmt = getConnection().prepareStatement(categorySql);
            categoryStmt.setInt(1, categoryId);

            ResultSet categoryResultSet = categoryStmt.executeQuery();
            if (categoryResultSet.next()) {
                String categoryName = categoryResultSet.getString("category_name");

                // Add the news item to its category's list
                categorizedNewsMap.computeIfAbsent(categoryName, k -> new ArrayList<>()).add(newsObj);
            }
        }

        return categorizedNewsMap;
    }





}