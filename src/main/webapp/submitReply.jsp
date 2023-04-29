<%@ page import = "java.sql.*"%>
<%@ page import = "org.json.simple.JSONObject" %>
<%@ page import = "org.json.simple.parser.JSONParser" %>
<%@ page import = "org.json.simple.parser.*" %>
<%@page import="java.io.FileReader"%>
<%@page import="org.w3c.dom.*,javax.xml.parsers.*" %>
<%@page import="java.text.SimpleDateFormat"%>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import = "java.sql.*"%>
<%@page import="com.google.gson.Gson" %>
<%@ page import="java.util.Map" %>
<%@page import="com.google.gson.JsonParseException" %>
<%@ page import="java.io.IOException" %>
<%@page contentType="application/json; charset=UTF-8" %>
<%@ page import="java.time.format.DateTimeFormatter"%>
<%@ page import="com.project.entities.DatabaseConnector"%>


<%
Connection conn = DatabaseConnector.getConnection();


request.setCharacterEncoding("UTF-8");
String content = request.getParameter("content");
String parentCommentIdParam = request.getParameter("parent_comment_id");
int userId = (int) session.getAttribute("id");

JSONObject jsonResponse = new JSONObject();

if (content != null && content.trim().length() > 0 && parentCommentIdParam != null) {
    int parentCommentId = Integer.parseInt(parentCommentIdParam);
    int newsId = -1;
    String fetchNewsIdSql = "SELECT news_id, content FROM comments WHERE comment_id = ?";
    PreparedStatement fetchNewsIdPstmt = conn.prepareStatement(fetchNewsIdSql);
    fetchNewsIdPstmt.setInt(1, parentCommentId);
    ResultSet fetchNewsIdRs = fetchNewsIdPstmt.executeQuery();
    String parentCommentText = null;
    if (fetchNewsIdRs.next()) {
        newsId = fetchNewsIdRs.getInt("news_id");
        parentCommentText = fetchNewsIdRs.getString("content");
    } else {
        jsonResponse.put("status", "failed");
        jsonResponse.put("error", "could not fetch news_id and content from parent comment");
        out.print(jsonResponse.toString());
        return;
    }
    fetchNewsIdRs.close();
    fetchNewsIdPstmt.close();
    try {
    String sql = "INSERT INTO comments (content, user_id, news_id, date_posted_on, availability, parent_comment_id) VALUES (?, ?, ?, ?, ?, ?)";
    PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
    pstmt.setString(1, content);
    pstmt.setInt(2, userId);
    pstmt.setInt(3, newsId);
    pstmt.setString(4, LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
    pstmt.setInt(5, 1);
    pstmt.setInt(6, parentCommentId);

    int result = pstmt.executeUpdate();

    ResultSet generatedKeys = pstmt.getGeneratedKeys();
    if (generatedKeys.next()) {
        jsonResponse.put("status", "success");
        jsonResponse.put("userId", userId);
        jsonResponse.put("userName", session.getAttribute("username"));
        jsonResponse.put("commentId", generatedKeys.getInt(1));
        jsonResponse.put("postedOn", LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        jsonResponse.put("parentCommentText", parentCommentText); // Add the parent comment text to the JSON response
    } else {
        jsonResponse.put("status", "failed");
        jsonResponse.put("error", "failed to get the inserted comment ID");
    }

    generatedKeys.close();
    pstmt.close();
    conn.close();
} catch (Exception e) {
    e.printStackTrace();
    jsonResponse.put("status", "failed");
    jsonResponse.put("error", "exception - " + e.getMessage());
}

}
out.print(jsonResponse.toString());

%>

