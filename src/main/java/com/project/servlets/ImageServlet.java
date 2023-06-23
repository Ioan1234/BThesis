package com.project.servlets;

import com.project.entities.DatabaseConnector;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.commons.io.IOUtils;

import java.io.IOException;
import java.io.InputStream;
import java.sql.*;

@WebServlet("/imageServlet")
public class ImageServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Get the author_id and draft_id from the request
        String authorIdStr = request.getParameter("author_id");
        String draftIdStr = request.getParameter("draft_id");

        if (authorIdStr != null) {
            // Handle author profile picture request
            handleAuthorProfilePictureRequest(authorIdStr, request, response);
        } else if (draftIdStr != null) {
            // Handle draft multimedia request
            handleDraftMultimediaRequest(draftIdStr, request, response);
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing ID parameter");
        }
    }
    private void handleAuthorProfilePictureRequest(String authorIdStr, HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int authorId;
        try {
            authorId = Integer.parseInt(authorIdStr);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid author ID");
            return;
        }

        try {
            Connection conn = DatabaseConnector.getConnection();

            PreparedStatement stmt = conn.prepareStatement("SELECT profile_picture_url FROM authors WHERE author_id = ?");
            stmt.setInt(1, authorId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                Blob imageBlob = rs.getBlob("profile_picture_url");
                if (imageBlob != null) {
                    response.setContentType("image/jpeg"); // Or whatever the image type is
                    try (InputStream in = imageBlob.getBinaryStream()) {
                        IOUtils.copy(in, response.getOutputStream());
                    }
                } else {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "No image found for author");
                }
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Author not found");
            }
        } catch (SQLException e) {
            throw new ServletException("Database access error", e);
        }
    }
    private void handleDraftMultimediaRequest(String draftIdStr, HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int draftId;
        try {
            draftId = Integer.parseInt(draftIdStr);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid draft ID");
            return;
        }
        try {
            Connection conn = DatabaseConnector.getConnection();

            PreparedStatement multimediaIdStmt = conn.prepareStatement(
                    "SELECT dmultimedia_id " +
                            "FROM draft_dmultimedia " +
                            "WHERE draft_id = ?"
            );
            multimediaIdStmt.setInt(1, draftId);

            // Use try-with-resources to automatically close ResultSet
            try (ResultSet multimediaIdRs = multimediaIdStmt.executeQuery()) {
                if (multimediaIdRs.next()) {
                    int multimediaId = multimediaIdRs.getInt("dmultimedia_id");

                    PreparedStatement multimediaStmt = conn.prepareStatement(
                            "SELECT dmm " +
                                    "FROM dmultimedia " +
                                    "WHERE dmultimedia_id = ?"
                    );
                    multimediaStmt.setInt(1, multimediaId);

                    // Use try-with-resources to automatically close ResultSet
                    try (ResultSet multimediaRs = multimediaStmt.executeQuery()) {
                        if (multimediaRs.next()) {
                            Blob imageBlob = multimediaRs.getBlob("dmm");
                            if (imageBlob != null) {
                                response.setContentType("image/jpeg");
                                try (InputStream in = imageBlob.getBinaryStream()) {
                                    IOUtils.copy(in, response.getOutputStream());
                                }
                            } else {
                                response.sendError(HttpServletResponse.SC_NOT_FOUND, "No image found for draft");
                            }
                        } else {
                            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Draft not found");
                        }
                    }
                } else {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "No multimedia ID found for draft");
                }
            }
        } catch (SQLException e) {
            throw new ServletException("Database access error", e);
        }
    }



}
