<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="com.project.entities.DatabaseConnector" %>
<%@ page import="java.sql.Connection" %><%
    Connection conn = DatabaseConnector.getConnection();
    int newsId = Integer.parseInt(request.getParameter("news_id"));

    // The SQL statement to update news_availability
    String sql = "UPDATE news SET news_availability = 0 WHERE news_id = ?";

    // Prepare and execute the SQL statement
    PreparedStatement ps = conn.prepareStatement(sql);
    ps.setInt(1, newsId);
    ps.executeUpdate();

    response.sendRedirect("News.jsp");
%>
