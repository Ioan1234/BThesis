
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
  if (Driver != null) {
    try {
      Class.forName(Driver);
    } catch (ClassNotFoundException e) {
      throw new RuntimeException(e);
    }
  }

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
  String id = (String)request.getParameter("id");
  PreparedStatement ps = conn.prepareStatement("SELECT * FROM news WHERE news_id=" + id);
  PreparedStatement comment = conn.prepareStatement("SELECT c.*, COUNT(cl.user_id) as like_count, GROUP_CONCAT(u.surname, ' ', u.name SEPARATOR ', ') as likers FROM comments c LEFT JOIN comment_likes cl ON c.comment_id = cl.comment_id LEFT JOIN users u ON cl.user_id = u.user_id WHERE c.news_id=" + id + " AND c.availability = 1 GROUP BY c.comment_id, c.date_posted_on ORDER BY c.date_posted_on DESC");

  PreparedStatement totalComments = conn.prepareStatement("SELECT COUNT(*) FROM comments WHERE news_id=" + id + " AND availability = 1");
  ResultSet result = ps.executeQuery();
  ResultSet commentResult = comment.executeQuery();
  ResultSet totalCommentsRESULT = totalComments.executeQuery();
  int noComments = 0;
  String newsTitle = "";
  String newsContent = "";
  Date postedOn = null;
  if(result.next()&&totalCommentsRESULT.next()) {
    noComments = totalCommentsRESULT.getInt(1);
    newsTitle = result.getString("news_title");
    newsContent = result.getString("news_content");
    postedOn = result.getDate("news_posted_on");
  }
%>



<!DOCTYPE html>
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.11.0/umd/popper.min.js" integrity="sha384-b/U6ypiBEHpOf/4+1nzFpr53nxSS+GLCkfwBdFNTxtclqqenISfwAzpKaMNFNmj4" crossorigin="anonymous"></script>
  <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css" integrity="sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh" crossorigin="anonymous">
  <title>View news</title>
  <link rel="stylesheet" href="./css/utils.css">
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
        <a class="nav-link" href="News.jsp">News <span class="sr-only">(current)</span></a>
      </li>
      <% if(session.getAttribute("accountType") == null){ %>
      <li class="nav-item mx-3">
        <a href="login.jsp?from=seeNews.jsp&news_id=<%= id %>" class="btn btn-warning">Login</a>

      </li>
      <% } %>
      <li class="nav-item mx-5">
        <a class="nav-link text-warning" href="#">
          <%

            if(session.getAttribute("accountType") == null)
              out.println("<strong>Guest</strong>");


            if (session.getAttribute("accountType") != null) {

              String currentEmail = (String) session.getAttribute("email");

              //out.println("accountType: " + session.getAttribute("accountType"));

              String sql = "SELECT * FROM " + session.getAttribute("accountType") + "s WHERE email = ?";

              PreparedStatement findUser = conn.prepareStatement(sql);
              findUser.setString(1, currentEmail);

              ResultSet findUserRESULT = findUser.executeQuery();
              findUserRESULT.next();

              out.println("<strong>" + findUserRESULT.getString("surname") + " " + findUserRESULT.getString("name") + " - " + session.getAttribute("accountType") + "</strong>");
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

<div class="container m-5 p-2" style="max-width: 80%;">

  <div class="d-flex justify-content-between">
    <div>
      <p class="h2"><%=newsTitle %></p>

      <p class="h5 mt-2 p-4"><%=newsContent%></p>

      <em class="mt-1"><%=postedOn%>, posted by <%


        PreparedStatement noAuthors = conn.prepareStatement("SELECT COUNT(*) FROM draft_authors WHERE draft_id =" + id);
        ResultSet noAuthorsRESULT = noAuthors.executeQuery();
        noAuthorsRESULT.next();


        PreparedStatement idAuthors = conn.prepareStatement("SELECT author_id FROM draft_authors WHERE draft_id=" +id);
        ResultSet idAuthorsRESULT = idAuthors.executeQuery();

        String r = "";

        int authors = noAuthorsRESULT.getInt(1);

        while(idAuthorsRESULT.next() && authors !=0 )
        {
          PreparedStatement authorName = conn.prepareStatement("SELECT surname,name FROM authors WHERE author_id=" + idAuthorsRESULT.getInt(1));
          ResultSet authorNameRESULT = authorName.executeQuery();
          authorNameRESULT.next();

          if(authors != 1) r+=authorNameRESULT.getString("surname") + " " + authorNameRESULT.getString("name") +", ";
          else r+=authorNameRESULT.getString("surname") + " " + authorNameRESULT.getString("name");

          authors--;
        }

        authors = noAuthorsRESULT.getInt(1);

        out.println(r);

        if(authors>1)out.println(" (" + authors + " authors)");
        else out.println("(one author)");



      %></em><br><br>

      <p class="lead" id="num-comments">
        <% if (noComments > 0) { %>
        Comments (<span id="num-comments-value"><%= noComments %></span>)
        <% } else { %>
        <b class="text-danger">The news either has no comments or the creator disabled them!</b>
        <% } %>
      </p>

    </div>

    <div class="d-flex flex-column">

      <%

        PreparedStatement urlMultimediaNews = conn.prepareStatement("SELECT url FROM multimedia m, news_multimedia con WHERE m.multimedia_id = con.multimedia_id AND news_id = " + id);
        ResultSet urlMultimediaNewsRESULT = urlMultimediaNews.executeQuery();

        while(urlMultimediaNewsRESULT.next())
        {
          out.println("<img src=" + urlMultimediaNewsRESULT.getString(1) +" heigth=\"200\" width=\"400\">");
        }
      %>


    </div>

  </div>






  <table class="table">

    <tbody>

    <%
      int currentUserId = -1;
      if (session.getAttribute("id") != null) {
        currentUserId = (int) session.getAttribute("id");
      }
      out.println("<tbody>");
      while (commentResult.next()) {
        int userId = commentResult.getInt("user_id");
        String commentContent = commentResult.getString("content");
        Date commentPostedOn = commentResult.getDate("date_posted_on");
        int likeCount = commentResult.getInt("like_count");
        String likers = commentResult.getString("likers");
        int commentId = commentResult.getInt("comment_id");

        PreparedStatement user = conn.prepareStatement("SELECT surname,name FROM users WHERE user_id=?");
        user.setInt(1, userId);

        ResultSet userRESULT = user.executeQuery();

        userRESULT.next();

        String[] likersArray;

        if (likers != null) {
          likersArray = likers.split(", ");
        }
        else {
          likersArray = new String[0];
        }
        out.println("<tr id=\"comment-row-" + commentResult.getInt("comment_id") + "\">");
        String buttonText;
        if (likeCount > 1) {
          buttonText = "Liked by " + likersArray[0] + " + " + (likeCount - 1);
        } else if (likeCount == 1) {
          buttonText = "Liked by " + likers;
        } else {
          buttonText = "Like";
        }
        out.println(""
                + "<tr>"
                +"<tr id=\"comment-container-" + commentId + "\">"
                + "<td width=\"25%\" class=\"text-secondary\">" + userRESULT.getString("surname") + " " + userRESULT.getString("name") + " said </td>"
                + "<td width=\"55%\"><i>" + commentContent + "</i></td>"
                + "<td width=\"10%\">" + commentPostedOn + "</td>"
                + "<td width=\"5%\"><button type=\"button\" class=\"btn btn-primary btn-sm\" onclick=\"likeComment(" + commentResult.getInt("comment_id") + ")\" title=\"" + likers + "\" " + (session.getAttribute("accountType") == null ? "disabled" : "") + ">" + buttonText + "</button></td>"
                + "</tr>");

        if (currentUserId == userId) {
          out.println("<td width=\"5%\"><button type=\"button\" id=\"remove-" + commentResult.getInt("comment_id") + "\" class=\"btn btn-warning btn-sm\" onclick=\"deleteComment(" + commentResult.getInt("comment_id") + ")\">Remove</button></td>");
        } else {
          out.println("<td width=\"5%\"></td>");
        }
      }
      out.println("</tbody>");
    %>



    </tbody>
  </table>

  <% if(session.getAttribute("accountType") == null){ %>
  <form action="#" method="post">
    <input type="text" placeholder="Type comment" name="comment" class="w-50" disabled>
    <button type="submit" class="btn btn-warning" disabled>Post</button>
  </form>
  <% } %>

  <% if(session.getAttribute("accountType") == "user"){ %>
  <form action="#" method="post">
    <input type="text" placeholder="Type comment" name="comment" class="w-50" required title="Please fill out this field.">
    <button type="submit" name="submit" class="btn btn-warning">Post</button>
  </form>
  <% } %>



</body>
<script>
  function likeComment(commentId) {
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
      if (xhr.readyState == 4 && xhr.status == 200) {
        location.reload();
      }
    };
    xhr.open("POST", "likeComment.jsp", true);
    xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    xhr.send("comment_id=" + commentId);
  }
  function deleteComment(commentId) {
    fetch('deleteComment.jsp', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: 'comment_id=' + commentId
    })
            //.then(response=>console.log(response))
            .then(response => response.json())
            .then(jsonResponse => {
              if (jsonResponse.status === 'success') {
                var commentRow = document.getElementById("comment-row-" + commentId);
                if (commentRow) {
                  commentRow.parentNode.removeChild(commentRow);
                  var numCommentsElement = document.getElementById("num-comments");
                  var numComments = parseInt(numCommentsElement.innerText) - 1;
                  numCommentsElement.innerText = numComments;
                  if (numComments == 0) {
                    var table = document.getElementsByTagName("table")[0];
                    table.style.display = "none";
                  }
                }
                console.log("Reloading page...");
                location.reload();

              } else {
                console.error("Failed to delete the comment");
              }
            })
            .catch(error => console.error(error));
  }



  function updateNumComments(num) {
    var numCommentsElement = document.getElementById("num-comments-value");
    numCommentsElement.innerText = num;
    if (num === 0) {
      var table = document.getElementsByTagName("table")[0];
      table.style.display = "none";
      var noCommentsMsg = document.createElement("b");
      noCommentsMsg.classList.add("text-danger");
      noCommentsMsg.innerText = "The news either has no comments or the creator disabled them!";
      numCommentsElement.parentNode.replaceChild(noCommentsMsg, numCommentsElement);
    }
  }
</script>
</html>



<%

  if("POST".equals(request.getMethod())) {
    String commentPOST = request.getParameter("comment");

    LocalDateTime datePostedOn = LocalDateTime.now();

    String query = "INSERT INTO comments(content, user_id, news_id, date_posted_on, availability) VALUES ('" + commentPOST + "', " + session.getAttribute("id") + ", " + id + ", '" + datePostedOn + "', 1)";

    Statement stmt = conn.createStatement();

    int count = stmt.executeUpdate(query);

    response.sendRedirect("seeNews.jsp?id=" + id);
  }


%>
