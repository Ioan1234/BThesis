package com.project.servlets;

import com.project.entities.DatabaseConnector;
import com.project.entities.News;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.*;
import java.util.stream.Collectors;

@WebServlet("/SimilarNewsServlet")
public class SimilarNewsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int newsId = Integer.parseInt(request.getParameter("news_id"));
            Connection conn = DatabaseConnector.getConnection();

            // Fetch the news title for the provided newsId
            PreparedStatement titleStmt = conn.prepareStatement("SELECT news_title FROM news WHERE news_id = ?");
            titleStmt.setInt(1, newsId);
            ResultSet titleRs = titleStmt.executeQuery();

            if (titleRs.next()) {
                String title = titleRs.getString("news_title");
                String[] keywords = title.split(" ");

                Set<String> stopWords = new HashSet<>(
                        Arrays.asList("a", "pe", "la", "spre", "cu", "de",
                                "fără", "sub", "în", "prin", "pentru", "către", "contra", "lângă"));

                List<String> filteredKeywords = Arrays.stream(keywords)
                        .filter(word -> !stopWords.contains(word.toLowerCase()))
                        .collect(Collectors.toList());

                StringBuilder queryBuilder = new StringBuilder("SELECT * FROM news WHERE news_id != ? AND (");
                for (int i = 0; i < filteredKeywords.size(); i++) {
                    queryBuilder.append("news_title LIKE ?");
                    if (i != filteredKeywords.size() - 1) {
                        queryBuilder.append(" OR ");
                    }
                }
                queryBuilder.append(")");

                PreparedStatement similarNewsStmt = conn.prepareStatement(queryBuilder.toString());
                similarNewsStmt.setInt(1, newsId); // set the excluded news_id
                for (int i = 0; i < filteredKeywords.size(); i++) {
                    similarNewsStmt.setString(i + 2, "%" + filteredKeywords.get(i) + "%");
                }

                ResultSet similarNewsRs = similarNewsStmt.executeQuery();

                // Initialize a new similarNewsList for every request
                List<News> similarNewsList = new ArrayList<>();

                // Fetch and add similar news to the list
                while (similarNewsRs.next()) {
                    News news = new News(similarNewsRs.getInt("news_id"), similarNewsRs.getString("news_title"), similarNewsRs.getString("news_content"));
                    similarNewsList.add(news);
                }

                // Redirect to a JSP page and pass the similar news
                request.setAttribute("similarNews", similarNewsList);
                request.getRequestDispatcher("/similarNews.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }





}

