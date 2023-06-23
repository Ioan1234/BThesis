        <%@page contentType="text/html" pageEncoding="UTF-8"%>
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
  JSONObject updateResultJson = new JSONObject();
  if (!session.getAttribute("accountType").equals("author")) {
    Connection conn = DatabaseConnector.getConnection();
    String userIdParam = request.getParameter("user_id");
    if (userIdParam != null && !userIdParam.isEmpty()) {
      int userId = Integer.parseInt(userIdParam);
      PreparedStatement ps = conn.prepareStatement("UPDATE users SET subscribed = 1 WHERE user_id = ?");
      ps.setInt(1, userId);
      ps.executeUpdate();
      updateResultJson.put("result", "success");
    }
  } else {
    updateResultJson.put("result", "failure");
  }
  response.setContentType("application/json");
  out.print(updateResultJson.toJSONString());
%>
