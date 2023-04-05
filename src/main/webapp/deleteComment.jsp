<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@ page import = "org.json.simple.JSONObject" %>
<%@ page import = "org.json.simple.parser.JSONParser" %>
<%@ page import = "org.json.simple.parser.*" %>
<%@page import="java.io.FileReader"%>

<%
  JSONParser jsonParser = new JSONParser();
  JSONObject jsonObject = null;
  try {
    jsonObject = (JSONObject) jsonParser.parse(new FileReader("C:/Users/gogul/IdeaProjects/project/src/main/webapp/newjson.json"));
  } catch (ParseException e) {
    throw new RuntimeException(e);
  }

  String User = (String) jsonObject.get("username");
  String Pass = (String) jsonObject.get("password");
  String Driver = (String) jsonObject.get("driverName");
  String Drive = (String) jsonObject.get("driver");
  try {
    Class.forName(Driver);
  } catch (ClassNotFoundException e) {
    throw new RuntimeException(e);
  }
  Connection conn = null;
  PreparedStatement deleteComment = null;
  try {
    conn = DriverManager.getConnection(Drive, User, Pass);
    conn.setAutoCommit(false);
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

