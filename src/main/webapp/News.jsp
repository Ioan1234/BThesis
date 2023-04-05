<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@page import="java.util.ArrayList"%>
<%@page import="com.project.entities.News"%>
<%@ page import = "org.json.simple.JSONObject" %>
<%@ page import = "org.json.simple.parser.JSONParser" %>
<%@ page import = "org.json.simple.parser.*" %>
<%@page import="java.io.FileReader"%>
<%@ page import = "java.sql.*"%>
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
    try {
        conn = DriverManager.getConnection(Drive, User, Pass);
    } catch (SQLException e) {
        throw new RuntimeException(e);
    }

    PreparedStatement ps1 = conn.prepareStatement("SELECT COUNT(*) FROM authors");
%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css" integrity="sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh" crossorigin="anonymous">
    <title>News</title>
    <link rel="stylesheet" href="./css/utils.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
</head>
<body>

<nav class="navbar navbar-expand-lg navbar-dark bg-main p-3">
    <a class="navbar-brand" href="#"></a>
    <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
        <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navbarNav">
        <ul class="navbar-nav">

            <li class="nav-item active">
                <a class="nav-link" href="#">News <span class="sr-only">(current)</span></a>
            </li>

                <% if(session.getAttribute("accountType") == null) { %>
            <li class="nav-item">
                <a class="nav-link" href="login.jsp?from=News.jsp">Login <span class="sr-only">(current)</span></a>
            </li>
                <% } %>

            <li class="nav-item mx-5">
                <a class="nav-link text-warning" href="#">

<%

        if(session.getAttribute("accountType") == null)
            out.println("<strong>Guest</strong>");
        if(session.getAttribute("accountType") == "user")
        {

            String currentEmail = (String)session.getAttribute("email");

            String sql = "SELECT * FROM users WHERE email = " + " '"+currentEmail+"'  ";

            PreparedStatement findUser = conn.prepareStatement(sql);


            ResultSet findUserRESULT = findUser.executeQuery();
            findUserRESULT.next();

            out.println("<strong>" + findUserRESULT.getString("surname") + " " + findUserRESULT.getString("name") + " - " + session.getAttribute("accountType") + "</strong>");
        }

        if(session.getAttribute("accountType") == "author")
        {

            String currentEmail = (String)session.getAttribute("email");

            String sql = "SELECT * FROM authors WHERE email = " + " '"+currentEmail+"'  ";

            PreparedStatement findAuthor = conn.prepareStatement(sql);


            ResultSet findAuthorRESULT = findAuthor.executeQuery();
            findAuthorRESULT.next();

            out.println("<strong>" + findAuthorRESULT.getString("surname") + " " + findAuthorRESULT.getString("name") + " - " +session.getAttribute("accountType") + "</strong>");
        }
%>

                    <span class="sr-only">(current)</span></a>
            </li>


            <% if(session.getAttribute("accountType") != null){ %>
            <li class="nav-item mx-3">
                <a class="nav-link" href="logout.jsp">Logout <span class="sr-only">(current)</span></a>
            </li>
            <% } %>
        </ul>
    </div>
</nav>
    <% if(session.getAttribute("accountType") == "author") { %>

<div class="container mt-5 text-center">
    <a href="add_draft.jsp" class="btn bg-main text-white w-50">Write draft</a>
</div>
    <% } %>

<div class="container mt-5 text-center">
    <input type="text" class="form-control w-50" id="myInput" placeholder="Search news...">
    <table class="table mt-3">
        <thead>
        <tr>
            <th scope="col">News title</th>
            <th scope="col">Posted on</th>
            <th scope="col">Category</th>
            <th scope="col">Actions</th>
        </tr>
        </thead>
        <tbody id="myTable">

        <jsp:useBean id="obj" class="com.project.entities.JavaBean"/>
        <%

            ArrayList<News> news = obj.getNews();

            for(News n : news){

                PreparedStatement categoryName = conn.prepareStatement("SELECT category_name FROM categories WHERE category_id = " + n.getCategoryId());
                ResultSet categoryNameRESULT = categoryName.executeQuery();

                categoryNameRESULT.next();


                try {
                    out.println(
                            "<tr>" +
                                    "<th>" + n.getNewsTitle() + "</th>" +
                                    "<th>" + n.getNewsPostedOn() + "</th>" +
                                    "<th>" + categoryNameRESULT.getString(1) + "</th>" +
                                    "<th><a href=\"seeNews.jsp?id= "+ n.getNewsId() +"\"><button class=\"btn bg-main text-white\">View</button></a></th>" +
                                    "</tr>"
                    );
                } catch (SQLException e) {
                    throw new RuntimeException(e);
                }
            }
        %>

        </tbody>
    </table>
</div>
<script>
    $(document).ready(function(){
        $("#myInput").on("keyup", function() {
            var value = $(this).val().toLowerCase();
            $("#myTable tr").filter(function() {
                $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
            });
        });
    });
</script>
</body>
</html>
