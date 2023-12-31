<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.security.MessageDigest" %>
<%@ page import="java.security.NoSuchAlgorithmException" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@page import="java.util.*"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.concurrent.TimeUnit"%>

<%@ page import = "org.json.simple.JSONObject" %>
<%@ page import = "org.json.simple.parser.JSONParser" %>
<%@ page import = "org.json.simple.parser.*" %>
<%@page import="java.io.FileReader"%>
<%@page import="jakarta.servlet.http.HttpSession"%>
<%@ page import="com.project.entities.DatabaseConnector" %>
<%@ page import="java.security.SecureRandom" %>

<!DOCTYPE html>

<html>
<head>
  <meta charset="utf-8">
  <title> Sign in</title>
  <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">
  <link rel="stylesheet" href="./css/utils.css">

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
Connection conn = DatabaseConnector.getConnection();
String msg = "";

if ("POST".equals(request.getMethod())) {
    String surname = request.getParameter("surname");
    String name = request.getParameter("name");
    String email = request.getParameter("email");
    String password = request.getParameter("password");
String salt = generateSalt(); // Generate a new salt for this user
String hashedPassword = hashPassword(password, salt); // Hash the password with the salt


    PreparedStatement userList = null;
    try {
        userList = conn.prepareStatement("SELECT email, password FROM users");
    } catch (SQLException e) {
        throw new RuntimeException(e);
    }

    ResultSet userListResult = null;
    try {
        userListResult = userList.executeQuery();
    } catch (SQLException e) {
        throw new RuntimeException(e);
    }

    boolean emailExists = false;
    boolean passwordExists = false;

    while (true) {
        try {
            if (!userListResult.next()) break;
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        try {
            if (userListResult.getString("email").equals(email)) {
                emailExists = true;
                if (userListResult.getString("password").equals(password)) {
                    passwordExists = true;
                    break;
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    if (emailExists && passwordExists) {
        msg = "An account is already linked with this email address!";
    } else {
       String insert = "INSERT INTO users (surname, name, email, password, active, subscribed, date_of_registering) VALUES (?,?,?,?,1,0, NOW())";
PreparedStatement stmt = null;
try {
    stmt = conn.prepareStatement(insert, Statement.RETURN_GENERATED_KEYS);
    stmt = conn.prepareStatement(insert, Statement.RETURN_GENERATED_KEYS);
            stmt = conn.prepareStatement(insert, Statement.RETURN_GENERATED_KEYS);
            stmt.setString(1, surname);
            stmt.setString(2, name);
            stmt.setString(3, email);
             stmt.setString(4, hashedPassword); // set hashed password in the prepared statement
    stmt.executeUpdate();
            ResultSet rs = stmt.getGeneratedKeys();
            if (rs.next()) {
                int id = rs.getInt(1);
                System.out.println("Generated user ID: " + id);
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        msg = "Authentication successful.";

        HttpSession session1 = request.getSession();
        session1.setAttribute("user", email);

        out.print("<div id='loader' style='display:none;'><h3>Authentication successful. Redirecting you to the news page...</h3></div>");
        String redirectTo = (String) request.getSession().getAttribute("lastPageBeforeLogin");

        if (redirectTo == null || redirectTo.isEmpty()) {
            redirectTo = "News.jsp";
        }

        out.print("<script>document.getElementById('loader-container').style.display = 'block'; setTimeout(function() { window.location.href = '" + redirectTo + "'; }, 2000);</script>");
    }

    String redirectTo = (String) request.getSession().getAttribute("lastPageBeforeLogin");

    if (redirectTo == null || redirectTo.isEmpty()) {
        redirectTo = "News.jsp";
    }

    out.print("<script>document.getElementById('loader-container').style.display = 'block'; setTimeout(function() { window.location.href = '" + redirectTo + "'; }, 2000);</script>");
}
%>




<body>


<section class="vh-100 d-flex justify-content-center align-items-center bg-image" style="background-image: url('https://img.freepik.com/free-vector/global-earth-blue-technology-digital-background-design_1017-27075.jpg'); background-repeat: no-repeat; background-size: cover;">
  <div class="container">
    <div class="row justify-content-center">
      <div class="col-12 col-md-8 col-lg-6">
        <div class="card">
          <div class="card-body p-5">
        <h2 class="text-uppercase text-center mb-5">Create an account: </h2>

        <form action="" method="POST">

          <div class="form-outline mb-4">
            <input type="text" id="surname" class="form-control form-control-lg" name="surname" required />
            <label class="form-label" for="surname">Your Surname</label>
          </div>

          <div class="form-outline mb-4">
            <input type="text" id="name" class="form-control form-control-lg" name="name" required/>
            <label class="form-label" for="name">Your Name</label>
          </div>

          <div class="form-outline mb-4">
            <input type="email" id="email" class="form-control form-control-lg" name="email" required/>
            <label class="form-label" for="email" >Your Email</label>
          </div>

          <div class="form-outline mb-4">
            <input type="password" id="password" class="form-control form-control-lg" name="password" required/>
            <label class="form-label" for="password" >Your Password</label>
          </div>

          <div class="d-flex justify-content-center">
            <button type="submit" class="btn btn-success btn-block btn-lg " name="submit" style="background-color: #FF3131; color: white;">Register</button>
          </div>

          <div class="loader-container" id="loader-container" style="display: none;">
            <div class="loader"></div>
            <div class="text-center text-white" style="position: absolute; top: 60%; left: 50%; transform: translate(-50%, -50%);">
              Authentication successful. Redirecting you to the news page...
            </div>
          </div>

          <p class="text-center text-muted mt-5 mb-0">Already have an account? <a href="login.jsp" class="fw-bold text-body"><u>Login here</u></a></p>

          <%
            if (msg.equals("Authentication successful.")) {
              out.print(" <div class=\"alert alert-success\" role=\"alert\">" +
                      "Authentication successful." + "</div>");
            }

            if (msg.equals("An account is already linked with this email address!")) {
              out.print("<div class='alert alert-danger mt-2' role='alert'>" + msg + "</div>");
            }
          %>

        </form>
      </div>
        </div>
      </div>
    </div>
  </div>
</section>
