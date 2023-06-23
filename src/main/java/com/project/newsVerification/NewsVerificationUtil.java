package com.project.newsVerification;

import com.project.entities.DatabaseConnector;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class NewsVerificationUtil {
    public static void verifyAndDeleteEmptyNews() {
        Connection conn = null;
        PreparedStatement selectStmt = null;
        PreparedStatement deleteStmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConnector.getConnection();
            String selectSql = "SELECT news_id FROM news WHERE news_title = '' OR news_content = ''";
            selectStmt = conn.prepareStatement(selectSql);
            rs = selectStmt.executeQuery();

            while (rs.next()) {
                int newsId = rs.getInt("news_id");

                // Delete corresponding multimedia
                String deleteMultimediaSql = "DELETE FROM multimedia WHERE multimedia_id IN (SELECT multimedia_id FROM news_multimedia WHERE news_id = ?)";
                deleteStmt = conn.prepareStatement(deleteMultimediaSql);
                deleteStmt.setInt(1, newsId);
                deleteStmt.executeUpdate();

                // Delete news
                String deleteNewsSql = "DELETE FROM news WHERE news_id = ?";
                deleteStmt = conn.prepareStatement(deleteNewsSql);
                deleteStmt.setInt(1, newsId);
                deleteStmt.executeUpdate();
            }

        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }
                if (deleteStmt != null) {
                    deleteStmt.close();
                }
                if (selectStmt != null) {
                    selectStmt.close();
                }
                if (conn != null) {
                    conn.close();
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
    }
}
