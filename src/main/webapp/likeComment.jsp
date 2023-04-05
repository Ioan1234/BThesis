<%@ page import = "org.json.simple.JSONObject" %>
<%@ page import = "org.json.simple.parser.JSONParser" %>
<%@ page import = "org.json.simple.parser.ParseException" %>
<%@page import="java.io.FileReader"%>
<%@ page import="java.sql.*" %>
<%@page contentType="application/json" pageEncoding="UTF-8"%>

<%
  if (session.getAttribute("accountType") == null) {
    response.setStatus(403);
    return;
  }

  int userId = Integer.parseInt(session.getAttribute("id").toString());
  int commentId = Integer.parseInt(request.getParameter("comment_id"));

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
  try {
    conn = DriverManager.getConnection(Drive, User, Pass);
  } catch (SQLException e) {
    throw new RuntimeException(e);
  }

  JSONObject responseJson = new JSONObject();
  if (conn != null) {
    PreparedStatement checkLike = conn.prepareStatement("SELECT * FROM comment_likes WHERE user_id=? AND comment_id=?");
    checkLike.setInt(1, userId);
    checkLike.setInt(2, commentId);

    ResultSet checkLikeResult = checkLike.executeQuery();

    if (checkLikeResult.next()) {
      PreparedStatement deleteLike = conn.prepareStatement("DELETE FROM comment_likes WHERE user_id=? AND comment_id=?");
      deleteLike.setInt(1, userId);
      deleteLike.setInt(2, commentId);
      deleteLike.executeUpdate();
      responseJson.put("action", "unliked");
    } else {
      PreparedStatement insertLike = conn.prepareStatement("INSERT INTO comment_likes (user_id, comment_id) VALUES (?, ?)");
      insertLike.setInt(1, userId);
      insertLike.setInt(2, commentId);
      insertLike.executeUpdate();
      responseJson.put("action", "liked");
    }

    PreparedStatement countLikes = conn.prepareStatement("SELECT COUNT(*) as likes_count FROM comment_likes WHERE comment_id=?");
    countLikes.setInt(1, commentId);
    ResultSet countLikesResult = countLikes.executeQuery();

    if (countLikesResult.next()) {
      responseJson.put("likes_count", countLikesResult.getInt("likes_count"));
    }
  }

  out.print(responseJson.toJSONString());
%>
