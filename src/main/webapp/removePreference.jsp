<%@ page import = "java.sql.*"%>
<%@ page import = "org.json.simple.JSONObject" %>
<%@ page import = "org.json.simple.parser.JSONParser" %>
<%@ page import = "org.json.simple.parser.*" %>
<%@page import="java.io.FileReader"%>
<%@page import="org.w3c.dom.*,javax.xml.parsers.*" %>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.time.LocalDateTime"%>
<%@ page import = "java.sql.*"%>
<%@ page import="com.project.entities.DatabaseConnector" %>
<%@ page import="com.project.entities.News" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.util.stream.Collectors" %>
<%@ page import="java.io.InputStreamReader" %>

<%
    int userId = Integer.parseInt(request.getParameter("user_id"));
    int newsId = Integer.parseInt(request.getParameter("news_id"));

    Connection conn = null;
    PreparedStatement stmt = null;
    String status = "";
    String message = "";

    try {
      conn = DatabaseConnector.getConnection();

      String sql = "DELETE FROM preferences WHERE user_id = ? AND news_id = ?";
      stmt = conn.prepareStatement(sql);
      stmt.setInt(1, userId);
      stmt.setInt(2, newsId);

      int rowsAffected = stmt.executeUpdate();

      if (rowsAffected > 0) {
        status = "success";
      } else {
        status = "error";
        message = "Failed to remove preference";
      }
    } catch (SQLException e) {
      status = "error";
      message = "Error: " + e.getMessage();
      e.printStackTrace();
    } finally {
      if (stmt != null) {
        stmt.close();
      }
      if (conn != null) {
        conn.close();
      }
    }

    response.setContentType("application/json");
  response.setCharacterEncoding("UTF-8");
  out.print("{\"status\": \"" + status + "\", \"message\": \"" + message + "\"}");
  out.flush();
%>

