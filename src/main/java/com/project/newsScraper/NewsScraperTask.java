package com.project.newsScraper;

import com.google.gson.Gson;
import com.project.entities.DatabaseConnector;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

import java.io.IOException;
import java.sql.*;
import java.util.List;
import java.util.TimerTask;
public class NewsScraperTask extends TimerTask {
    @Override
    public void run() {
        try {
            scrapeForNewArticles("https://www.biziday.ro/");
            scrapeForNewArticles("https://www.hotnews.ro/");
        } catch (IOException | SQLException e) {
            throw new RuntimeException(e);
        }
    }
    public boolean isNewsExist(String url) {
        boolean exist = false;
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConnector.getConnection();
            String sql = "SELECT COUNT(*) FROM news WHERE url = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, url);
            rs = stmt.executeQuery();

            if(rs.next()) {
                int count = rs.getInt(1);
                if(count > 0) {
                    exist = true;
                }
            }
        } catch (SQLException ex) {
            // handle exception
            ex.printStackTrace();
        } finally {
            try {
                if(rs != null) {
                    rs.close();
                }
                if(stmt != null) {
                    stmt.close();
                }
                if(conn != null) {
                    conn.close();
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
        return exist;
    }



    public void scrapeForNewArticles(String url) throws IOException, SQLException {
        Connection conn = DatabaseConnector.getConnection();

        try {
            Document doc = Jsoup.connect(url).get();
            Elements articleLinks;

            if (url.contains("biziday.ro")) {
                articleLinks = doc.select("a.post-url");
            } else if (url.contains("hotnews.ro")) {
                articleLinks = doc.select("a[aria-label]");
            } else {
                return; // Not a recognized URL
            }

            for (Element link : articleLinks) {
                String articleUrl = link.attr("abs:href");

                // Check if this article is already in the database
                if (!isNewsExist(articleUrl)) {
                    ContentFetcher fetcher = new ContentFetcher(url);
                    String newsTitle = fetcher.fetchTitle(articleUrl);
                    List<ContentBlock> fetchedContentBlocks = fetcher.fetchContent(articleUrl);
                    String contentJson = new Gson().toJson(fetchedContentBlocks);

                    // Truncate long titles
                    if (newsTitle.length() > 255) {
                        newsTitle = newsTitle.substring(0, 255);
                    }
                    if(url.length()>255){
                        url=url.substring(0,255);
                    }

                    PreparedStatement insertStmt = conn.prepareStatement("INSERT INTO news(news_title, news_content, news_posted_on, news_availability, is_draft, url) VALUES(?, ?, NOW(), 1, 0, ?)", Statement.RETURN_GENERATED_KEYS);
                    insertStmt.setString(1, newsTitle);
                    insertStmt.setBlob(2, new javax.sql.rowset.serial.SerialBlob(contentJson.getBytes()));
                    insertStmt.setString(3, articleUrl);
                    int affectedRows = insertStmt.executeUpdate();
                    int newsId = -1;

                    if (affectedRows != 1) {
                        throw new SQLException("Failed to insert news into the database.");
                    } else {
                        try (ResultSet generatedKeys = insertStmt.getGeneratedKeys()) {
                            if (generatedKeys.next()) {
                                newsId = generatedKeys.getInt(1);
                            }
                            else {
                                throw new SQLException("Creating news failed, no ID obtained.");
                            }
                        }
                    }

                    for (ContentBlock block : fetchedContentBlocks) {
                        if (block.getType().equals("image")) {
                            String imageUrl = block.getContent();

                            PreparedStatement multimediaStmt = conn.prepareStatement("INSERT INTO multimedia(url) VALUES(?)", Statement.RETURN_GENERATED_KEYS);
                            multimediaStmt.setString(1, imageUrl);
                            multimediaStmt.executeUpdate();
                            try (ResultSet multimediaGeneratedKeys = multimediaStmt.getGeneratedKeys()) {
                                if (multimediaGeneratedKeys.next()) {
                                    int multimediaId = multimediaGeneratedKeys.getInt(1);
                                    PreparedStatement newsMultimediaStmt = conn.prepareStatement("INSERT INTO news_multimedia(news_id, multimedia_id) VALUES(?, ?)");
                                    newsMultimediaStmt.setInt(1, newsId);
                                    newsMultimediaStmt.setInt(2, multimediaId);
                                    newsMultimediaStmt.executeUpdate();
                                }
                            }
                        }
                    }
                }
        }
        } catch (IOException | SQLException e) {
            e.printStackTrace();
        }
    }


}

