<%@page session="true" %>
<%@page import="java.sql.*"%>

<%@ page import = "org.json.simple.JSONObject" %>
<%@ page import = "org.json.simple.parser.JSONParser" %>
<%@ page import = "org.json.simple.parser.*" %>
<%@page import="java.io.FileReader"%>
<%@ page import="com.project.entities.DatabaseConnector" %>
<%@ page import="java.security.MessageDigest" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="java.security.NoSuchAlgorithmException" %>
<%@ page import="java.util.Base64" %>
<html>
<head>
    <meta charset="utf-8">
    <title> Login </title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">
</head>

<%! private static String hashPassword(String password) {
    try {
        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        byte[] hash = digest.digest(password.getBytes(StandardCharsets.UTF_8));
        return Base64.getEncoder().encodeToString(hash);
    } catch (NoSuchAlgorithmException e) {
        throw new RuntimeException(e);
    }
} %>
<%
    String message = (String) request.getAttribute("msg");
    if(message != null){
%>
<p><%= message %></p>
<%
    }
%>



<%
        Connection conn = DatabaseConnector.getConnection();

        String msg = "";
        boolean found = false;

        String email = "";
        String password = "";
    String hashedPassword = ""; // declare hashedPassword variable here
        String redirectPage = "News.jsp";

        int newsId = -1;
        if (request.getParameter("news_id") != null) {
            try {
                newsId = Integer.parseInt(request.getParameter("news_id"));
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        }
    // Hash the password from the request

    if ("POST".equals(request.getMethod())) {
        email = request.getParameter("email");
        password = request.getParameter("password");

        if (password != null && !password.isEmpty()) {
            hashedPassword = hashPassword(password);
            if (request.getParameter("from") != null) {
                redirectPage = request.getParameter("from");
            }


            PreparedStatement stmt = conn.prepareStatement("SELECT email, password FROM users where active = 1");
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                if (rs.getString("email").equals(email) && rs.getString("password").equals(hashedPassword)) {
                    msg = "Authentication successful.";
                    found = true;
                    session.setAttribute("loggedIn", true);
                    session.setAttribute("accountType", "user");
                }
            }

            if (!found) {
                PreparedStatement authorList = conn.prepareStatement("Select email, password from authors where state_of_author= 1");
                ResultSet authorListRESULT = authorList.executeQuery();

                while (authorListRESULT.next()) {
                    if (authorListRESULT.getString("email").equals(email) && authorListRESULT.getString("password").equals(hashedPassword)) {
                        msg = "Authentication successful.";
                        found = true;
                        session.setAttribute("loggedIn", true);
                        session.setAttribute("accountType", "author");
                    }
                }
            }


            if (!found) {
                msg = "Wrong email or password!";
            }
        }
    }

        if (msg.equals("Authentication successful.")) {
            session.setAttribute("email", email);
            session.setAttribute("password", password);

            if (session.getAttribute("accountType").equals("user")) {
                PreparedStatement getID = conn.prepareStatement("SELECT user_id FROM users WHERE email=? AND password = ?");
                getID.setString(1, email);
                getID.setString(2, hashedPassword);

                ResultSet getIDRESULT = getID.executeQuery();

                getIDRESULT.next();

                int id = getIDRESULT.getInt(1);

                session.setAttribute("id", id);

                if (newsId != -1) {
                    response.sendRedirect("seeNews.jsp?id=" + newsId);
                } else {
                    response.sendRedirect("News.jsp");
                }

            } else if (session.getAttribute("accountType").equals("author")) {
                PreparedStatement getID = conn.prepareStatement("SELECT author_id FROM authors WHERE email=? AND password = ?");
                getID.setString(1, email);
                getID.setString(2, hashedPassword);

                ResultSet getIDRESULT = getID.executeQuery();

                getIDRESULT.next();

                int id = getIDRESULT.getInt(1);

                session.setAttribute("id", id);

                if (newsId != -1) {
                    response.sendRedirect("seeNews.jsp?id=" + newsId);
                } else {
                    response.sendRedirect("News.jsp");
                }
            }
        }
%>


<body>

<section class="vh-100 bg-image" style="background-image: url('https://mdbcdn.b-cdn.net/img/Photos/new-templates/search-box/img4.webp');">
    <div class="mask d-flex align-items-center h-100 gradient-custom-3">
        <div class="container h-100">
            <div class="row d-flex justify-content-center align-items-center h-100">
                <div class="col-12 col-md-9 col-lg-7 col-xl-6">
                    <div class="card" style="border-radius: 15px;">
                        <div class="card-body p-5">
                            <h2 class="text-uppercase text-center mb-5">Login into your account: </h2>

                            <form  method="POST">
                                <input type="hidden" name="from" value="News.jsp">

                                <div class="form-outline mb-4">
                                    <input type="email" id="form3Example3cg" class="form-control form-control-lg" name="email" required/>
                                    <label class="form-label" for="form3Example3cg" >Your Email</label>
                                </div>

                                <div class="form-outline mb-4">
                                    <input type="password" id="form3Example1cg" class="form-control form-control-lg" name="password" required />
                                    <label class="form-label" for="form3Example1cg">Your Password</label>
                                </div>


                                <div class="d-flex justify-content-center">
                                    <button type="submit" class="btn btn-success btn-block btn-lg gradient-custom-4 text-body" name="submit">Login</button>
                                </div>

                                <p class="text-center mt-3">Don't have an account yet? <a href="index.jsp">Sign up</a></p>

                                <%

                                    if(msg.equals("Wrong email or password!"))
                                    {
                                        out.print(" <div class=\"alert alert-danger mt-2  \" role=\"alert\">"+
                                                "      Wrong email or password! "+"</div>");

                                    }

                                %>

                            </form>

                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

</body>

</html>
