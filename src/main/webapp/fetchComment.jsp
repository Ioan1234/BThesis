<%@ page import = "java.sql.*"%>
<%@ page import = "org.json.simple.JSONObject" %>
<%@ page import = "org.json.simple.parser.JSONParser" %>
<%@ page import = "org.json.simple.parser.*" %>
<%@page import="java.io.FileReader"%>
<%@page import="org.w3c.dom.*,javax.xml.parsers.*" %>
<%@page import="java.text.SimpleDateFormat"%>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import = "java.sql.*"%>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.google.gson.JsonParseException" %>
<%@ page import="java.io.IOException" %>
<%@page contentType="application/json; charset=UTF-8" %>
<%@ page import="java.time.format.DateTimeFormatter"%>
<%@ page import="com.project.entities.DatabaseConnector"%>

<%
try{
    Connection conn = DatabaseConnector.getConnection();
    String commentIdParam = request.getParameter("comment_id");
    if (commentIdParam != null) {
        int commentId = Integer.parseInt(commentIdParam);

        // Fetch the comment text from the database
        String sql = "SELECT content FROM comments WHERE comment_id = ?";
        PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
        pstmt.setInt(1, commentId);
        ResultSet rs = pstmt.executeQuery();

        if (rs.next()) {
            String commentText = rs.getString("content");
            out.print(commentText);
        } else {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
        }

        rs.close();
        pstmt.close();
    } else {
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
    }
    }
catch (Exception e) {
    e.printStackTrace(); // This will print the stack trace to the server logs
    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
}
%>

