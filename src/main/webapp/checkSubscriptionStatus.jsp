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
    Connection conn = DatabaseConnector.getConnection();
    boolean isSubscribed = false;
    JSONObject jsonResponse = new JSONObject();
    if (session.getAttribute("accountType") != null) {

        String currentEmail = (String) session.getAttribute("email");

        //out.println("accountType: " + session.getAttribute("accountType"));
        String sql=null;

        if (session.getAttribute("accountType").equals("admin")) {
            sql = "SELECT * FROM authors WHERE email = ?";
        } else {
            sql = "SELECT * FROM " + session.getAttribute("accountType") + "s WHERE email = ?";
        }

        PreparedStatement findUser = conn.prepareStatement(sql);
        findUser.setString(1, currentEmail);

        ResultSet findUserRESULT = findUser.executeQuery();
        findUserRESULT.next();
        if (!session.getAttribute("accountType").equals("author")&&!session.getAttribute("accountType").equals("admin")) {
            int userId = findUserRESULT.getInt("user_id");
            session.setAttribute("userId", userId);
            PreparedStatement stmt = conn.prepareStatement("SELECT subscribed FROM users WHERE user_id = ?");
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                isSubscribed = rs.getInt("subscribed") == 1;
            }


            jsonResponse.put("isSubscribed", isSubscribed);

        }
    } else {
        jsonResponse.put("isSubscribed", false); // authors aren't subscribed
    }
    response.setContentType("application/json");
    out.print(jsonResponse.toJSONString());

%>
