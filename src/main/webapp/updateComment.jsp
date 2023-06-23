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
        JSONObject jsonResponse = new JSONObject();
        try {
            // Connect to the database
            Connection conn = DatabaseConnector.getConnection();
            // Get the comment_id and content parameters from the request
            int commentId = Integer.parseInt(request.getParameter("comment_id"));
            String content = request.getParameter("content");

            // Prepare an SQL statement to update the comment's content
            PreparedStatement updateComment = conn.prepareStatement("UPDATE comments SET content = ? WHERE comment_id = ?");

            // Set the parameters for the prepared statement
            updateComment.setString(1, content);
            updateComment.setInt(2, commentId);

            // Execute the update
            int rowsUpdated = updateComment.executeUpdate();

            // Check if the update was successful
            if (rowsUpdated > 0) {
                jsonResponse.put("status", "success");
            } else {
                jsonResponse.put("status", "error");
                jsonResponse.put("error", "Error updating comment.");
            }
            // Close resources
            updateComment.close();
            conn.close();

        } catch (SQLException e) {
            jsonResponse.put("status", "error");
            jsonResponse.put("error", "Error: " + e.getMessage());
        } finally {
            out.print(jsonResponse.toString()); // Print the JSON response
        }
%>