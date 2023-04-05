package com.project.entities;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
public class JavaBean extends Connections{
    public ArrayList<News> getNews() throws SQLException{

        Connection conn = Connections.getConnection();

        String sql = "SELECT news_id, draft_id, news_title, news_posted_on, category_id, news_content, news_availability, is_draft FROM news ORDER BY news_id";
        PreparedStatement getNews = conn.prepareStatement(sql);
        ResultSet getNewsRESULT = getNews.executeQuery();


        ArrayList<News> news = new ArrayList<News>();



        while(getNewsRESULT.next()){

            int newsId = getNewsRESULT.getInt("news_id");
            int draftId = getNewsRESULT.getInt("draft_id");
            String newsTitle = getNewsRESULT.getString("news_title");
            int categoryId = getNewsRESULT.getInt("category_id");
            byte[] newsContent = getNewsRESULT.getBytes("news_content");
            Date newsPostedOn = getNewsRESULT.getDate("news_posted_on");
            boolean newsAvailability = getNewsRESULT.getBoolean("news_availability");
            boolean isDraft = getNewsRESULT.getBoolean("is_draft");

            News newsObj = new News(newsId, draftId, newsTitle, categoryId, newsContent, newsPostedOn, newsAvailability, isDraft);
            news.add(newsObj);


        }

        return news;
    }
}
