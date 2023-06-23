<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="com.project.entities.DatabaseConnector" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.ResultSet" %>
<%
  Connection conn = DatabaseConnector.getConnection();

  if ("POST".equals(request.getMethod())) {
    int authorId = Integer.parseInt(request.getParameter("authorId"));
    String action = request.getParameter("action");

    if ("approve".equals(action)) {
      // Update author_approval and state_of_author to 1 for the author
      String sql = "UPDATE authors SET author_approval = 1, state_of_author = 1 WHERE author_id = ?";
      PreparedStatement ps = conn.prepareStatement(sql);
      ps.setInt(1, authorId);
      ps.executeUpdate();

      // Get the author's email
      String emailSql = "SELECT email FROM authors WHERE author_id = ?";
      PreparedStatement emailPs = conn.prepareStatement(emailSql);
      emailPs.setInt(1, authorId);
      ResultSet emailRs = emailPs.executeQuery();

      if (emailRs.next()) {
        String email = emailRs.getString("email");

        // Set active to 0 for the user with the same email
        String updateUserStatus = "UPDATE users SET active = 0 WHERE email = ?";
        PreparedStatement updateUserStmt = conn.prepareStatement(updateUserStatus);
        updateUserStmt.setString(1, email);
        updateUserStmt.executeUpdate();
      }
      Cookie authorCookie = new Cookie("authorApproved", String.valueOf(authorId));
      authorCookie.setMaxAge(60);
      response.addCookie(authorCookie);
    } else if ("deny".equals(action)) {
      // Delete the author from the database
      String sql = "DELETE FROM authors WHERE author_id = ?";
      PreparedStatement ps = conn.prepareStatement(sql);
      ps.setInt(1, authorId);
      ps.executeUpdate();
    }

    // Redirect back to the admin page
    response.sendRedirect("authorRequests.jsp");
  }
%>
