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
<%@ page import="java.security.SecureRandom" %>
<%@ page import="java.net.URLDecoder" %>
<html>
<head>
    <meta charset="utf-8">
    <title> Login </title>
    <meta charset="UTF-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">
    <title>Login into your account</title>
</head>

<%!

    private static String generateSalt() {
        SecureRandom random = new SecureRandom();
        byte[] salt = new byte[16];
        random.nextBytes(salt);
        return Base64.getEncoder().encodeToString(salt);
    }

    private static String hashPassword(String password, String salt) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            digest.update(salt.getBytes(StandardCharsets.UTF_8));
            byte[] hash = digest.digest(password.getBytes(StandardCharsets.UTF_8));
            return salt + "$" + Base64.getEncoder().encodeToString(hash);
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException(e);
        }
    }
%>

<%
    String message = null;
    Cookie[] cookies = request.getCookies();
    if (cookies != null) {
        for (Cookie cookie : cookies) {
            if (cookie.getName().equals("message")) {
                message = URLDecoder.decode(cookie.getValue(), StandardCharsets.UTF_8);
                cookie.setMaxAge(0); // This will delete the cookie
                response.addCookie(cookie); // This will send the updated cookie back
                break;
            }
        }
    }
%>

<% if (message != null) { %>
<div id="message" style="position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%); font-size: 2em; text-align: center; background-color: #F8F9FA; padding: 20px; border-radius: 5px; z-index: 1000;">
    <%= message %>
</div>

<script>
    setTimeout(function() {
        document.getElementById('message').style.display = 'none';
    }, 5000);
</script>
<% } %>







<%
    Connection conn = DatabaseConnector.getConnection();

    String msg = "";
    boolean found = false;

    String email = "";
    String password = "";
    String hashedPassword = "";
    String inputHash = "";
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

        System.out.println("Email: " + email);
        System.out.println("Password: " + password);

        PreparedStatement stmt = conn.prepareStatement("SELECT email, password, active FROM users WHERE email = ?");
        stmt.setString(1, email);
        ResultSet rs = stmt.executeQuery();

        while (rs.next()) {
            System.out.println("Checking users...");
            if (rs.getString("email").equals(email) && rs.getInt("active") == 1) {
                String[] saltAndHash = rs.getString("password").split("\\$");
                if (saltAndHash.length != 2) {
                    continue;
                }
                String salt = saltAndHash[0];
                String storedHash = saltAndHash[1];
                inputHash = hashPassword(password, salt);

                if (inputHash.equals(salt + "$" + storedHash)) {
                    msg = "Authentication successful.";

                    found = true;
                    session.setAttribute("loggedIn", true);
                    session.setAttribute("accountType", "user");
                    System.out.println("Found user: " + email);
                }
            }
        }

        if (!found) {
            PreparedStatement authorList = conn.prepareStatement("SELECT email, password, state_of_author, author_approval, is_admin FROM authors WHERE email = ? AND (state_of_author = 1 OR state_of_author = 0)");
            authorList.setString(1, email);
            ResultSet authorListResult = authorList.executeQuery();

            while (authorListResult.next()) {
                System.out.println("Checking authors...");
                if (authorListResult.getString("email").equals(email)) {
                    String[] saltAndHash = authorListResult.getString("password").split("\\$");
                    if (saltAndHash.length != 2) {
                        continue;
                    }
                    String salt = saltAndHash[0];
                    String storedHash = saltAndHash[1];
                    inputHash = hashPassword(password, salt);

                    if (inputHash.equals(salt + "$" + storedHash)) {
                        if (authorListResult.getInt("author_approval") == 0) {
                            msg = "You have submitted an author request. Please wait for the admin's decision.";
                            break;
                        }
                        msg = "Authentication successful.";
                        found = true;
                        session.setAttribute("loggedIn", true);
                        if (authorListResult.getInt("is_admin") == 1) {
                            session.setAttribute("accountType", "admin");
                            System.out.println("Found admin: " + email);
                        } else {
                            session.setAttribute("accountType", "author");
                            session.setAttribute("stateOfAuthor", authorListResult.getInt("state_of_author"));
                            System.out.println("Found author: " + email);
                        }
                    }
                }
            }
        }

        if (!found && msg.isEmpty()) {
            msg = "Wrong email or password!";
            System.out.println(msg);

        }
        System.out.println("Message: " + msg);

    }

    if (msg.equals("Authentication successful.")) {
        session.setAttribute("email", email);
        session.setAttribute("password", password);
        System.out.println("Account type: " + session.getAttribute("accountType"));

        if (session.getAttribute("accountType").equals("user")) {
            PreparedStatement getID = conn.prepareStatement("SELECT user_id FROM users WHERE email=? AND password = ?");
            getID.setString(1, email);
            getID.setString(2, inputHash);

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
            PreparedStatement getID = conn.prepareStatement("SELECT author_id, is_admin FROM authors WHERE email=? AND password = ?");
            getID.setString(1, email);
            getID.setString(2, inputHash);

            ResultSet getIDRESULT = getID.executeQuery();

            if(getIDRESULT.next()){
                System.out.println("Getting author ID and admin status");
                int id = getIDRESULT.getInt(1);
                boolean isAdmin = getIDRESULT.getInt("is_admin") == 1;

                session.setAttribute("id", id);
                session.setAttribute("isAdmin", isAdmin);

                System.out.println("Is admin: " + isAdmin);

                if (isAdmin) {
                    System.out.println("Account Type: " + session.getAttribute("accountType"));
                    System.out.println("About to redirect admin to News.jsp");
                    response.sendRedirect("News.jsp");
                    System.out.println("Redirecting...");

                } else {
                    if (newsId != -1) {
                        response.sendRedirect("seeNews.jsp?id=" + newsId);
                    } else {
                        response.sendRedirect("News.jsp");
                    }
                    if (session.getAttribute("id") != null) {
                        int authorId = (Integer) session.getAttribute("id");
                    }
                }
            }
        }else if (session.getAttribute("accountType").equals("admin")) {
            PreparedStatement getID = conn.prepareStatement("SELECT author_id FROM authors WHERE email=? AND password = ?");
            getID.setString(1, email);
            getID.setString(2, inputHash);

            ResultSet getIDRESULT = getID.executeQuery();

            if(getIDRESULT.next()){
                System.out.println("Getting admin ID");
                int id = getIDRESULT.getInt(1);

                session.setAttribute("id", id);

                System.out.println("About to redirect admin to News.jsp");
                response.sendRedirect("News.jsp");
                System.out.println("Redirecting...");
            }
        }
    }


%>



<body>


<section class="vh-100 bg-image" style="background-image: url('https://img.freepik.com/free-vector/global-earth-blue-technology-digital-background-design_1017-27075.jpg'); background-repeat: no-repeat; background-size: cover;">
    <div class="mask d-flex align-items-center h-100 gradient-custom-3">
        <div class="container h-100">
            <div class="row d-flex justify-content-center align-items-center h-100">
                <div class="col-12 col-md-8 col-lg-8 col-xl-6">
                    <div class="card" style="border-radius: 15px;">
                        <div class="card-body p-5">
                            <h2 class="text-uppercase text-center mb-5">Login into your account:</h2>

                            <form method="POST">
                                <input type="hidden" name="from" value="News.jsp">

                                <div class="form-outline mb-4">
                                    <input type="email" id="form3Example3cg" class="form-control form-control-lg" name="email" required/>
                                    <label class="form-label" for="form3Example3cg">Your Email</label>
                                </div>

                                <div class="form-outline mb-4">
                                    <input type="password" id="form3Example1cg" class="form-control form-control-lg" name="password" required />
                                    <label class="form-label" for="form3Example1cg">Your Password</label>
                                </div>

                                <div class="d-flex justify-content-center">
                                    <button type="submit" class="btn btn-success btn-block btn-lg" name="submit" style="background-color: #FF3131; color: white;">Login</button>
                                </div>

                                <p class="text-center mt-3">Don't have an account yet? <a href="index.jsp">Sign up</a></p>

                                <%
                                    if (msg.equals("Wrong email or password!")) {
                                        out.print(" <div class=\"alert alert-danger mt-2\" role=\"alert\">" +
                                                "      Wrong email or password! " + "</div>");
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
