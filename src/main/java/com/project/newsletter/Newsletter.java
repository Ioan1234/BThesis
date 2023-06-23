package com.project.newsletter;

import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.sql.*;
import java.util.Properties;

public class Newsletter {

    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587";
    private static final String EMAIL_FROM = "ioanconst07@gmail.com";

    private final Connection dbConnection;

    public Newsletter(Connection dbConnection) {
        this.dbConnection = dbConnection;
    }

    public void sendNewsletters() throws SQLException {
        // Fetch User Preferences
        PreparedStatement stmt = dbConnection.prepareStatement("SELECT * FROM preferences");
        ResultSet rs = stmt.executeQuery();

        while (rs.next()) {
            int userId = rs.getInt("user_id");
            int newsId = rs.getInt("news_id");

            // Fetch New Comments with Username, Surname and News Title
            PreparedStatement commentsStmt = dbConnection.prepareStatement(
                    "SELECT c.*, u.name as user_name, u.surname as user_surname, n.news_title as news_title " +
                            "FROM comments c " +
                            "JOIN users u ON c.user_id = u.user_id " +
                            "JOIN news n ON c.news_id = n.news_id " +
                            "WHERE c.news_id = ? AND c.date_posted_on > ? AND n.news_availability = 1"
            );

            commentsStmt.setInt(1, newsId);
            commentsStmt.setTimestamp(2, new Timestamp(System.currentTimeMillis() - 24 * 60 * 60 * 1000)); // Fetch comments from last 24 hours
            ResultSet commentsRs = commentsStmt.executeQuery();

            // Check if there are any comments
            if (!commentsRs.next()) {
                System.out.println("No comments found for news_id = " + newsId);
                continue; // No comments found, skip to the next news item
            } else {
                StringBuilder content = new StringBuilder();
                content.append("<p>");

                do {
                    String userName = commentsRs.getString("user_name");
                    String userSurname = commentsRs.getString("user_surname"); // Get the user surname
                    String newsTitle = commentsRs.getString("news_title");
                    String commentContent = commentsRs.getString("content");
                    String timestamp = commentsRs.getTimestamp("date_posted_on").toString();

                    content.append(userName)
                            .append(" ")
                            .append(userSurname)
                            .append(" wrote in ")
                            .append(newsTitle)
                            .append(": ")
                            .append(commentContent)
                            .append(" at ")
                            .append(timestamp)
                            .append("<br>");

                } while (commentsRs.next());

                content.append("</p>");

                // Fetch user email
                PreparedStatement emailStmt = dbConnection.prepareStatement("SELECT email FROM users WHERE user_id = ?");
                emailStmt.setInt(1, userId);
                ResultSet emailRs = emailStmt.executeQuery();
                if (emailRs.next()) {
                    String emailTo = emailRs.getString("email");

                    // Send Email
                    sendEmail(emailTo, "Newsletter - New Comments on Your Preferred News", content.toString());
                }
            }
        }
    }





    private void sendEmail(String to, String subject, String content) {
        Properties props = new Properties();
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true"); // Use TLS
        props.put("mail.smtp.user", EMAIL_FROM);
        props.put("mail.smtp.password", "flexppgzhhnxpxkh"); // App Password
        Authenticator auth = new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(EMAIL_FROM, "flexppgzhhnxpxkh");
            }
        };

        Session session = Session.getInstance(props,auth);
        try {
            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(EMAIL_FROM));
            message.setRecipients(
                    Message.RecipientType.TO,
                    InternetAddress.parse(to)
            );
            message.setSubject(subject);
            message.setContent(content, "text/html");

            Transport.send(message);

            System.out.println("Email sent to " + to);

        } catch (MessagingException e) {
            e.printStackTrace();
            throw new RuntimeException(e);
        }

    }
}
