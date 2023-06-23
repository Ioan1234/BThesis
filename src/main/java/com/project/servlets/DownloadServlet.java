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
import java.io.OutputStream;
import java.sql.*;

@WebServlet("/downloadCv")
public class DownloadServlet extends HttpServlet {
    private Blob getCvAsBlob(String email) {
        Blob cvBlob = null;

        try {
            Connection conn = DatabaseConnector.getConnection();

            // Prepare SQL statement
            String sql = "SELECT cv FROM authors WHERE email = ?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, email);

            // Execute SQL query and get result
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                cvBlob = rs.getBlob("cv");
            }

            rs.close();
            stmt.close();
        } catch (SQLException ex) {
            // Handle SQL exception
            ex.printStackTrace();
        }

        return cvBlob;
    }


    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = req.getParameter("email");

        Blob cvBlob = getCvAsBlob(email);

        resp.setContentType("application/pdf");
        resp.setHeader("Content-Disposition", "inline; filename=\"cv_" + email + ".pdf\""); // To view inline in browser
        // Write Blob data to the servlet output stream
        InputStream in = null;
        try {
            in = cvBlob.getBinaryStream();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        OutputStream out = resp.getOutputStream();
        IOUtils.copy(in, out);
    }
}
