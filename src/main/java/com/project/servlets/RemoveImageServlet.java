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
import java.sql.SQLException;

@WebServlet("/removeImageServlet")
public class RemoveImageServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get the draft ID from the request
        int draftId = Integer.parseInt(request.getParameter("draftId"));

        // Get the database connection
        Connection conn = DatabaseConnector.getConnection(); /*get your database connection here*/

        try {
            // Begin transaction
            conn.setAutoCommit(false);

            // Remove relation to draft
            PreparedStatement multimediaIdStmt = conn.prepareStatement(
                    "DELETE FROM draft_dmultimedia WHERE draft_id = ?"
            );
            multimediaIdStmt.setInt(1, draftId);
            multimediaIdStmt.executeUpdate();

            // Remove image itself
            PreparedStatement multimediaStmt = conn.prepareStatement(
                    "DELETE FROM dmultimedia WHERE dmultimedia_id IN (SELECT dmultimedia_id FROM draft_dmultimedia WHERE draft_id = ?)"
            );
            multimediaStmt.setInt(1, draftId);
            multimediaStmt.executeUpdate();

            // Commit transaction
            conn.commit();

        } catch (SQLException e) {
            // Roll back transaction if there was an error
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
        } finally {
            // End transaction
            try {
                conn.setAutoCommit(true);
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        // Redirect back to the original page
        String contextPath = request.getContextPath();
        String redirectTo = contextPath + "/draft?draft_id=" + draftId;
        response.sendRedirect(redirectTo);
    }
}
