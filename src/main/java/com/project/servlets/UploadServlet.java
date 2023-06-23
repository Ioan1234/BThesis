package com.project.servlets;

import com.project.entities.DatabaseConnector;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.apache.commons.io.IOUtils;

import java.io.IOException;
import java.io.OutputStream;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.*;
import java.util.Collection;

@WebServlet("/fileUpload")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 50, // 50MB
        maxFileSize = 1024 * 1024 * 500,      // 500MB
        maxRequestSize = 1024 * 1024 * 500)   // 500MB
public class UploadServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = (String) request.getSession().getAttribute("email"); // Retrieve email from the session.

        if (email == null || email.isEmpty()) {
            // User is not logged in. Redirect them to the login page.
            response.sendRedirect("login.jsp");
            return;
        }

        Connection conn = DatabaseConnector.getConnection();
        PreparedStatement stmt = null;
        try {
            stmt = conn.prepareStatement("SELECT * FROM authors WHERE email = ?");
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        try {
            stmt.setString(1, email);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        ResultSet rs = null;
        try {
            rs = stmt.executeQuery();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }

        try {
            if (rs.next()) {
                // User has already submitted the form. Return an error message.
                Cookie message = new Cookie("message", URLEncoder.encode("You have already submitted your details", StandardCharsets.UTF_8));
                message.setMaxAge(60); // Set expire time. -1 means delete this cookie.
                response.addCookie(message);
                response.sendRedirect("authorForm.jsp");
                return;
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        HttpSession session = request.getSession();
        String surname = "";
        String name = "";

        if ("POST".equalsIgnoreCase(request.getMethod())) {
            if (session.getAttribute("accountType") != null) {
                String currentEmail = (String) session.getAttribute("email");
                String accountType = (String) session.getAttribute("accountType");
                String idColumn = "id"; // default column name

                if (accountType.equals("author")) {
                    idColumn = "author_id";
                } else if (accountType.equals("user")) {
                    idColumn = "user_id";
                }

                String sql = "SELECT * FROM " + accountType + "s WHERE email = ?";

                PreparedStatement findUser;
                try {
                    findUser = conn.prepareStatement(sql);
                    findUser.setString(1, currentEmail);
                    ResultSet findUserRESULT = findUser.executeQuery();

                    if (findUserRESULT.next()) {
                        int userId = findUserRESULT.getInt(idColumn);
                        session.setAttribute("userId", userId);
                    }
                } catch (SQLException e) {
                    throw new RuntimeException(e);
                }

                // Get user details
                try {
                    PreparedStatement getUserStmt = conn.prepareStatement("SELECT * FROM users WHERE email = ?");
                    getUserStmt.setString(1, currentEmail);
                    rs = getUserStmt.executeQuery();

                    if (rs.next()) {
                        String password = rs.getString("password");
                        name = rs.getString("name");
                        surname = rs.getString("surname");

                        if (password != null && !password.isEmpty()) {
                            Blob cvBlob = null;
                            Blob profilePictureBlob = null;
                            String linkedinUrl = "";
                            String facebookUrl = "";

                            final Collection<Part> parts = request.getParts();
                            for (final Part part : parts) {
                                String partName = part.getName();
                                if (!partName.equals("submit")) {
                                    String value = IOUtils.toString(part.getInputStream(), StandardCharsets.UTF_8);

                                    switch (partName) {
                                        case "cv":
                                        case "profile_picture":
                                            Blob blob = conn.createBlob();
                                            try (OutputStream os = blob.setBinaryStream(1)) {
                                                IOUtils.copy(part.getInputStream(), os);
                                            }
                                            if ("cv".equals(partName)) {
                                                cvBlob = blob;
                                            } else {
                                                profilePictureBlob = blob;
                                            }
                                            break;
                                        case "linkedin_url":
                                            linkedinUrl = value;
                                            break;
                                        case "facebook_url":
                                            facebookUrl = value;
                                            break;
                                    }
                                }
                            }

                            // Insert user into authors table
                            String insertAuthorQuery = "INSERT INTO authors (surname, name, email, password, date_of_registering, state_of_author, author_approval,cv,profile_picture_url,linkedin_url,facebook_url) VALUES (?,?,?,?,NOW(),0,0,?,?,?,?)";
                            PreparedStatement insertAuthorStmt = conn.prepareStatement(insertAuthorQuery);
                            insertAuthorStmt.setString(1, surname);
                            insertAuthorStmt.setString(2, name);
                            insertAuthorStmt.setString(3, currentEmail);
                            insertAuthorStmt.setString(4, password);
                            insertAuthorStmt.setBlob(5, cvBlob);
                            insertAuthorStmt.setBlob(6, profilePictureBlob);
                            insertAuthorStmt.setString(7, linkedinUrl);
                            insertAuthorStmt.setString(8, facebookUrl);
                            insertAuthorStmt.executeUpdate();
                            session.invalidate();
                            String message = "Your files have been uploaded successfully." +
                                    "Please wait for the admin to approve your request. In the meantime, you can continue to use our site as a user";
                            String encodedMessage = URLEncoder.encode(message, StandardCharsets.UTF_8);
                            Cookie cookie = new Cookie("message", encodedMessage);
                            response.addCookie(cookie);

                            response.sendRedirect("login.jsp");


                        }
                    } else {
                        request.getRequestDispatcher("login.jsp").forward(request, response);
                    }
                } catch (SQLException | ServletException e) {
                    throw new RuntimeException(e);
                }
            }
        }
    }
}

