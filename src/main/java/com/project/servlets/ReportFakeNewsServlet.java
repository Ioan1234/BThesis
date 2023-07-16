package com.project.servlets;

import com.project.entities.DatabaseConnector;
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

@WebServlet("/ReportFakeNewsServlet")
public class ReportFakeNewsServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int userId = Integer.parseInt(request.getParameter("userId").trim());
        int newsId = Integer.parseInt(request.getParameter("newsId").trim());
        String draftId = request.getParameter("draftId").trim();

        if (draftId != null) {
            try {
                Connection conn = DatabaseConnector.getConnection();

                if (!conn.getAutoCommit()) {
                    conn.setAutoCommit(true);
                }

                String sql = "SELECT * FROM UserReports WHERE user_id = ? AND news_id = ?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setInt(1, userId);
                ps.setInt(2, newsId);
                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    response.sendRedirect("News.jsp?id=" + newsId);
                    return;
                }

                PreparedStatement pstmt = conn.prepareStatement("UPDATE news SET reports = COALESCE(reports, 0) + 1 WHERE news_id = ?");
                pstmt.setInt(1, newsId);
                pstmt.executeUpdate();
                sql = "INSERT INTO UserReports (user_id, news_id) VALUES (?, ?)";
                ps = conn.prepareStatement(sql);
                ps.setInt(1, userId);
                ps.setInt(2, newsId);
                ps.executeUpdate();

                PreparedStatement pstmt2 = conn.prepareStatement("SELECT reports FROM news WHERE news_id = ?");
                pstmt2.setInt(1, newsId);
                rs = pstmt2.executeQuery();
                if (rs.next()) {
                    int reports = rs.getInt("reports");
                    if(reports >= 1){
                        pstmt = conn.prepareStatement("UPDATE news SET news_availability = 0 WHERE news_id = ?");
                        pstmt.setInt(1, newsId);
                        pstmt.executeUpdate();

                        pstmt = conn.prepareStatement("UPDATE comments SET availability = 0 WHERE news_id = ?");
                        pstmt.setInt(1, newsId);
                        pstmt.executeUpdate();

                    }
//                    PreparedStatement pstmtCount = conn.prepareStatement("SELECT COUNT(*) AS userCount FROM users");
//                    ResultSet rs1 = pstmtCount.executeQuery();
//
//                    int userThreshold = 0;
//                    if(rs1.next()) {
//                        userThreshold = rs1.getInt("userCount") / 4;
//                    }
//                    if(reports >= userThreshold){
//                        pstmt = conn.prepareStatement("UPDATE news SET news_availability = 0 WHERE news_id = ?");
//                        pstmt.setInt(1, newsId);
//                        pstmt.executeUpdate();
//
//                        pstmt = conn.prepareStatement("UPDATE comments SET availability = 0 WHERE news_id = ?");
//                        pstmt.setInt(1, newsId);
//                        pstmt.executeUpdate();
//                    }

                }

                conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
                System.out.println("SQLException: " + e.getMessage());
            }
        }
        
        response.sendRedirect("News.jsp?id=" + newsId);
    }

}
