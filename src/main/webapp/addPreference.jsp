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
<%@ page import="java.io.InputStreamReader" %><%@ page import="java.io.PrintWriter"%>
<%@ page contentType="application/json" %>

<%
int userId = Integer.parseInt(request.getParameter("user_id").trim());
int newsId = Integer.parseInt(request.getParameter("news_id").trim());
int categoryId = Integer.parseInt(request.getParameter("category_id").trim());

   Connection conn = DatabaseConnector.getConnection();

JSONObject result = new JSONObject();

try {
    PreparedStatement checkExistsStmt = conn.prepareStatement("SELECT * FROM preferences WHERE user_id = ? AND news_id = ?");
    checkExistsStmt.setInt(1, userId);
    checkExistsStmt.setInt(2, newsId);

    ResultSet checkExistsRs = checkExistsStmt.executeQuery();

    if (!checkExistsRs.next()) {
        PreparedStatement addPreferenceStmt = conn.prepareStatement("INSERT INTO preferences (user_id, news_id, category_id) VALUES (?, ?, ?)");
        addPreferenceStmt.setInt(1, userId);
        addPreferenceStmt.setInt(2, newsId);
        addPreferenceStmt.setInt(3, categoryId);

        int affectedRows = addPreferenceStmt.executeUpdate();

        if (affectedRows > 0) {
            result.put("status", "success");
        } else {
            result.put("status", "failure");
            result.put("message", "Failed to insert preference.");
        }
    } else {
        result.put("status", "failure");
        result.put("message", "Preference already exists.");
    }
} catch (Exception e) {
    result.put("status", "error");
    result.put("message", e.getMessage());
}

out.print(result);
out.flush();
%>
