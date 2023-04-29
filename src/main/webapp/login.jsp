<%@page session="true" %>

<html>
<head>
    <meta charset="utf-8">
    <title> Login </title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">
</head>
<%@page import="java.sql.*"%>

<%@ page import = "org.json.simple.JSONObject" %>
<%@ page import = "org.json.simple.parser.JSONParser" %>
<%@ page import = "org.json.simple.parser.*" %>
<%@page import="java.io.FileReader"%>
<%@ page import="com.project.entities.DatabaseConnector" %>


<%
    Connection conn = DatabaseConnector.getConnection();

    String msg = "";
    boolean found = false;

    String email = "";
    String password = "";
    String redirectPage = "News.jsp";

    int newsId = -1;
    if (request.getParameter("news_id") != null) {
        try {
            newsId = Integer.parseInt(request.getParameter("news_id"));
        } catch (NumberFormatException e) {
            e.printStackTrace();
        }
    }
    if ("POST".equals(request.getMethod())) {

        email = request.getParameter("email");
        password = request.getParameter("password");
        if (request.getParameter("from") != null) {
            redirectPage = request.getParameter("from");
        }

        PreparedStatement stmt = conn.prepareStatement("SELECT email, password FROM users");
        ResultSet rs = stmt.executeQuery();

        while(rs.next())
        {
            if(rs.getString("email").equals(email) && rs.getString("password").equals(password))
            {
                msg="Authentication successful.";
                found=true;
                session.setAttribute("loggedIn", true);
                session.setAttribute("accountType", "user");
            }
        }

        if(!found){
            PreparedStatement authorList= conn.prepareStatement("Select email,password from authors");
            ResultSet authorListRESULT=authorList.executeQuery();

            while(authorListRESULT.next())
            {
                if(authorListRESULT.getString("email").equals(email) && authorListRESULT.getString("password").equals(password))
                {
                    msg="Authentication successful.";
                    found=true;
                    session.setAttribute("loggedIn", true);
                    session.setAttribute("accountType", "author");
                }
            }
        }
        if (!found) {
            msg = "Wrong email or password!";
        }
    }

    if (msg.equals("Authentication successful.")) {
        session.setAttribute("email", email);
        session.setAttribute("password", password);

        if (session.getAttribute("accountType").equals("user")) {
            PreparedStatement getID = conn.prepareStatement("SELECT user_id FROM users WHERE email=? AND password = ?");
            getID.setString(1, email);
            getID.setString(2, password);

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
            getID.setString(2, password);

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

                                    if(msg.equals("Authentication sucessful.")){


                                        session.setAttribute("email", email);
                                        session.setAttribute("password", password);



                                        if (session.getAttribute("accountType").equals("user")) {
                                            PreparedStatement getID = conn.prepareStatement("SELECT user_id FROM users WHERE email=? AND password = ?");
                                            getID.setString(1, email);
                                            getID.setString(2, password);

                                            ResultSet getIDRESULT = getID.executeQuery();

                                            getIDRESULT.next();

                                            int id = getIDRESULT.getInt(1);

                                            session.setAttribute("id", id);

                                            if ("News.jsp".equals(redirectPage)) {

                                            } else if ("seeNews.jsp".equals(redirectPage)) {
                                                if (newsId != -1) {
                                                    session.setAttribute("redirectPage", "seeNews.jsp?id=" + newsId);
                                                } else {
                                                    session.setAttribute("redirectPage", "News.jsp");
                                                }
                                            } else {
                                                session.setAttribute("redirectPage", redirectPage);
                                            }
                                            response.sendRedirect((String) session.getAttribute("redirectPage"));


                                        } else if (session.getAttribute("accountType").equals("author")) {

                                            PreparedStatement getID = conn.prepareStatement("SELECT author_id FROM authors WHERE email=? AND password = ?");
                                            getID.setString(1, email);
                                            getID.setString(2, password);

                                            ResultSet getIDRESULT = getID.executeQuery();

                                            getIDRESULT.next();

                                            int id = getIDRESULT.getInt(1);

                                            session.setAttribute("id", id);

                                            if ("News.jsp".equals(redirectPage)) {
                                                response.sendRedirect("News.jsp");
                                            } else if ("seeNews.jsp".equals(redirectPage)) {
                                                if (newsId != -1) {
                                                    response.sendRedirect("seeNews.jsp?id=" + newsId);
                                                } else {
                                                    response.sendRedirect("News.jsp");
                                                }
                                            } else {
                                                response.sendRedirect("News.jsp");
                                            }
                                        }
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