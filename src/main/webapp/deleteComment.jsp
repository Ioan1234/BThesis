<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@ page import = "org.json.simple.JSONObject" %>
<%@ page import = "org.json.simple.parser.JSONParser" %>
<%@ page import = "org.json.simple.parser.*" %>
<%@page import="java.io.FileReader"%>
<%@ page import="com.project.entities.DatabaseConnector" %>

<%
  Connection conn = DatabaseConnector.getConnection();
  PreparedStatement deleteComment = null;
  conn.setAutoCommit(false);

  try {
    int commentId = request.getParameter("comment_id") != null ? Integer.parseInt(request.getParameter("comment_id")) : 0;

    int currentUserId = (int) session.getAttribute("id");
    deleteComment = conn.prepareStatement("UPDATE comments SET availability = 0 WHERE comment_id = ? AND user_id = ?");
    deleteComment.setInt(1, commentId);
    deleteComment.setInt(2, currentUserId);
    int affectedRows = deleteComment.executeUpdate();

    JSONObject jsonResponse = new JSONObject();
    if (affectedRows > 0) {
      jsonResponse.put("status", "success");
      conn.commit();
    } else {
      jsonResponse.put("status", "failure");
    }
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    out.print(jsonResponse.toJSONString());
    out.flush();

  } catch (SQLException e) {
    throw new RuntimeException(e);
  } finally {
    if (deleteComment != null) {
      try {
        deleteComment.close();
      } catch (SQLException e) {
        throw new RuntimeException(e);
      }
    }
    if (conn != null) {
      try {
        conn.close();
      } catch (SQLException e) {
        throw new RuntimeException(e);
      }
    }
  }

%>

