<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>

<html>
<head>
  <meta charset="utf-8">
  <title> Sign in</title>
  <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">
  <style>
    .loader-container {
      position: fixed;
      display: none;
      width: 100%;
      height: 100%;
      top: 0;
      left: 0;
      background-color: rgba(0, 0, 0, 0.7);
      z-index: 9999;
    }

    .loader {
      border: 16px solid #f3f3f3;
      border-radius: 50%;
      border-top: 16px solid #3498db;
      width: 120px;
      height: 120px;
      -webkit-animation: spin 2s linear infinite;
      animation: spin 2s linear infinite;
      position: absolute;
      top: 50%;
      left: 50%;
      margin: -60px 0 0 -60px;
    }

    @-webkit-keyframes spin {
      0% {
        -webkit-transform: rotate(0deg);
      }
      100% {
        -webkit-transform: rotate(360deg);
      }
    }

    @keyframes spin {
      0% {
        transform: rotate(0deg);
      }
      100% {
        transform: rotate(360deg);
      }
    }
  </style>

</head>

<%@page import="java.util.*"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.concurrent.TimeUnit"%>

<%@ page import = "org.json.simple.JSONObject" %>
<%@ page import = "org.json.simple.parser.JSONParser" %>
<%@ page import = "org.json.simple.parser.*" %>
<%@page import="java.io.FileReader"%>
<%@page import="jakarta.servlet.http.HttpSession"%>


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


%>

<%
  String msg = "";


  if ("POST".equals(request.getMethod())) {

    String surname = request.getParameter("surname");
    String name = request.getParameter("name");
    String email = request.getParameter("email");
    String password = request.getParameter("password");

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

    while (true) {
      try {
        if (!userListResult.next()) break;
      } catch (SQLException e) {
        throw new RuntimeException(e);
      }
      try {
        if (userListResult.getString("email").equals(email)) {
          msg = "Email already exists!";
          break;
        }
      } catch (SQLException e) {
        throw new RuntimeException(e);
      }

      try {
        if (userListResult.getString("password").equals(password)) {
          msg = "Password already used!";
          break;
        }
      } catch (SQLException e) {
        throw new RuntimeException(e);
      }
    }

    if (!msg.equals("Email already exists!") && !msg.equals("Password already used!")) {
      String insert = "INSERT INTO users (surname, name, email, password, active, subscribed) VALUES (?,?,?,?,1,1)";
      PreparedStatement stmt = null;
      try {
        stmt = conn.prepareStatement(insert, Statement.RETURN_GENERATED_KEYS);
        stmt.setString(1, surname);
        stmt.setString(2, name);
        stmt.setString(3, email);
        stmt.setString(4, password);
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

      out.print("<script>document.getElementById('loader').style.display = 'block'; setTimeout(function() { window.location.href = '" + redirectTo + "'; }, 2000);</script>");

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
              <h2 class="text-uppercase text-center mb-5">Create an account: </h2>

              <form action="index.jsp" method="POST">

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
                  <button type="submit" class="btn btn-success btn-block btn-lg gradient-custom-4 text-body" name="submit">Register</button>
                </div>
                <div class="loader-container" id="loader-container">
                  <div class="loader"></div>
                  <div class="text-center text-white" style="position: absolute; top: 60%; left: 50%; transform: translate(-50%, -50%);">
                    Authentication successful. Redirecting you to the news page...
                  </div>
                </div>


                <p class="text-center text-muted mt-5 mb-0">Already have an account? <a href="login.jsp" class="fw-bold text-body"><u>Login here</u></a></p>
                <%

                  if(msg.equals("Email already exists!"))
                  {
                    out.print(" <div class=\"alert alert-danger mt-2  \" role=\"alert\">"+
                            "      Email already exists!"+"</div>");
                  }


                  if(msg.equals("Password already used!"))
                  {
                    out.print(" <div class=\"alert alert-danger mt-2  \" role=\"alert\">"+
                            "      Password already used!"+"</div>");
                  }


                  if(msg.equals("Authentication successful."))
                  {
                    out.print(" <div class=\"alert alert-success\" role=\"alert\">"+
                            "Authentication successful."+"</div>");


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