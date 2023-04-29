<%@ page import = "org.json.simple.JSONObject" %>
<%@ page import = "org.json.simple.parser.JSONParser" %>
<%@ page import = "org.json.simple.parser.ParseException" %>
<%@page import="java.io.FileReader"%>
<%@ page import="java.sql.*" %><%@ page import="com.project.entities.DatabaseConnector"%><%@ page import="java.util.ArrayList"%><%@ page import="java.util.List"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>

<%
  if (session.getAttribute("accountType") == null) {
    response.setStatus(403);
    return;
  }

  int userId = Integer.parseInt(session.getAttribute("id").toString());
  int commentId = Integer.parseInt(request.getParameter("comment_id"));

  Connection conn = DatabaseConnector.getConnection();

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
      PreparedStatement getLikers = conn.prepareStatement("SELECT u.surname, u.name FROM users u JOIN comment_likes cl ON u.user_id = cl.user_id WHERE cl.comment_id=?");
getLikers.setInt(1, commentId);
ResultSet getLikersResult = getLikers.executeQuery();

List<String> likersList = new ArrayList<>();
while (getLikersResult.next()) {
    likersList.add(getLikersResult.getString("surname") + " " + getLikersResult.getString("name"));
}
responseJson.put("likers", String.join(", ", likersList));
    }
  }

  out.print(responseJson.toJSONString());
%>
