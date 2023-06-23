<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="com.project.entities.DatabaseConnector" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.SQLException" %><%
    // Get connection
    Connection conn = DatabaseConnector.getConnection();

    // Get author_id from URL parameters
    String authorIdParam = request.getParameter("author_id");
    if (authorIdParam == null) {
        // Error handling: author_id parameter is missing
        session.setAttribute("message", "Missing author_id parameter");
        response.sendRedirect("seeAuthors.jsp");
        return;
    }
    int authorId = Integer.parseInt(authorIdParam);

    // SQL to update author state
    String sql = "UPDATE authors SET state_of_author = 0 WHERE author_id = ?";

    // Use PreparedStatement to execute SQL
    try {
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, authorId);
        ps.executeUpdate();

        // Set success message
        session.setAttribute("message", "Author retired successfully.");

    } catch (SQLException e) {
        // Error handling: something went wrong with the SQL
        // Ideally, log the exception somewhere
        session.setAttribute("message", "SQL error while retiring author.");
    }

    // Redirect back to the author list
    response.sendRedirect("seeAuthors.jsp");

%>
