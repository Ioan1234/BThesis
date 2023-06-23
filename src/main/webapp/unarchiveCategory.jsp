<%@ page import="com.project.entities.DatabaseConnector" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.SQLException" %><%
    String categoryName = request.getParameter("category_name");

    // Open a connection to the database
    Connection conn = DatabaseConnector.getConnection();

    try {
        // Turn off auto-commit
        conn.setAutoCommit(false);

        // Archive category
        String sqlCategory = "UPDATE categories SET category_availability=1 WHERE category_name=?";
        PreparedStatement pstmtCategory = conn.prepareStatement(sqlCategory);
        pstmtCategory.setString(1, categoryName);
        pstmtCategory.executeUpdate();

        // Archive news of that category
        String sqlNews = "UPDATE news INNER JOIN categories ON news.category_id = categories.category_id SET news.news_availability=1 WHERE categories.category_name=?";
        PreparedStatement pstmtNews = conn.prepareStatement(sqlNews);
        pstmtNews.setString(1, categoryName);
        pstmtNews.executeUpdate();

        // Commit the transaction
        conn.commit();
        response.sendRedirect("News.jsp");
    } catch (SQLException e) {
        // Rollback the transaction in case of an error
        conn.rollback();
        out.println("Error: " + e.getMessage());
    } finally {
        // Close the connection
        conn.close();
    }
%>