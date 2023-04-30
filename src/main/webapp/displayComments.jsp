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


<%
    Connection conn =DatabaseConnector.getConnection();

    String accountType = (String) session.getAttribute("accountType");
    String id = (String)request.getParameter("id");

    PreparedStatement ps = conn.prepareStatement("SELECT * FROM news WHERE news_id=" + id);
    // Fetch parent comments
    PreparedStatement parentComment = conn.prepareStatement("SELECT c.*, COUNT(cl.user_id) as like_count, GROUP_CONCAT(CASE WHEN u.surname IS NOT NULL THEN CONCAT(u.surname, ' ', u.name) WHEN a.surname IS NOT NULL THEN CONCAT(a.surname, ' ', a.name) END SEPARATOR ', ') as likers FROM comments c LEFT JOIN comment_likes cl ON c.comment_id = cl.comment_id LEFT JOIN users u ON cl.user_id = u.user_id LEFT JOIN authors a ON cl.user_id = a.author_id WHERE c.news_id=" + id + " AND c.availability = 1 AND c.parent_comment_id IS NULL GROUP BY c.comment_id, c.date_posted_on ORDER BY c.date_posted_on DESC");

// Fetch child comments (replies)
    PreparedStatement childComment = conn.prepareStatement("SELECT c.*, COUNT(cl.user_id) as like_count, GROUP_CONCAT(CASE WHEN u.surname IS NOT NULL THEN CONCAT(u.surname, ' ', u.name) WHEN a.surname IS NOT NULL THEN CONCAT(a.surname, ' ', a.name) END SEPARATOR ', ') as likers FROM comments c LEFT JOIN comment_likes cl ON c.comment_id = cl.comment_id LEFT JOIN users u ON cl.user_id = u.user_id LEFT JOIN authors a ON cl.user_id = a.author_id WHERE c.news_id=" + id + " AND c.availability = 1 AND c.parent_comment_id IS NOT NULL GROUP BY c.comment_id, c.date_posted_on ORDER BY c.date_posted_on ASC", ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);




    PreparedStatement totalComments = conn.prepareStatement("SELECT COUNT(*) FROM comments WHERE news_id=" + id + " AND availability = 1");
    ResultSet result = ps.executeQuery();
    ResultSet parentCommentResult = parentComment.executeQuery();
    ResultSet childCommentResult = childComment.executeQuery();
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
    <script src="javascript/scrips.js"></script>
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



    <table class="table">

        <tbody>

        <%
            int currentUserId = -1;
            if (session.getAttribute("id") != null) {
                currentUserId = (int) session.getAttribute("id");
            }
            out.println("<tbody>");

            while (parentCommentResult.next()) {
                int userId = parentCommentResult.getInt("user_id");
                String commentContent = parentCommentResult.getString("content");
                Date commentPostedOn = parentCommentResult.getDate("date_posted_on");
                int likeCount = parentCommentResult.getInt("like_count");
                String likers = parentCommentResult.getString("likers");
                int commentId = parentCommentResult.getInt("comment_id");

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
                out.println("<tr id=\"comment-row-" + parentCommentResult.getInt("comment_id") + "\">");
                String buttonText;
                if (likeCount > 1) {
                    buttonText = "Liked by " + likersArray[0] + " + " + (likeCount - 1);
                } else if (likeCount == 1) {
                    buttonText = "Liked by " + likers;
                } else {
                    buttonText = "Like";
                    likers = ""; // Set likers to an empty string if there are no likers
                }
                out.println(""
                        + "<td width=\"25%\" class=\"text-secondary\">" + userRESULT.getString("surname") + " " + userRESULT.getString("name") + " said </td>"
                        + "<td width=\"55%\" data-parent-comment-text><i>" + commentContent + "</i></td>"
                        + "<td width=\"10%\">" + commentPostedOn + "</td>"
                        + "<td width=\"5%\"><button type=\"button\" class=\"btn btn-primary btn-sm\" onclick=\"likeComment(" + parentCommentResult.getInt("comment_id") + ")\" title=\"" + likers + "\" " + ((accountType == null || accountType.equals("author")) ? "disabled" : "") + ">" + buttonText + "</button></td>"
                );

                if (currentUserId == userId && session.getAttribute("accountType").equals("user")) {
                    out.println("<td width=\"5%\"><button type=\"button\" id=\"remove-" + parentCommentResult.getInt("comment_id") + "\" class=\"btn btn-warning btn-sm\" onclick=\"deleteComment(" + parentCommentResult.getInt("comment_id") + ")\">Remove</button></td>");
                } else {
                    out.println("<td width=\"5%\"><button type=\"button\" class=\"btn btn-info btn-sm\" data-comment-id=\"" + parentCommentResult.getInt("comment_id") + "\" data-parent-comment-id=\"" + parentCommentResult.getInt("comment_id") + "\" onclick=\"replyComment(this)\">Reply</button></td>");




                }
                childCommentResult.beforeFirst(); // Reset the childCommentResult cursor
                while (childCommentResult.next()) {
                    if (childCommentResult.getInt("parent_comment_id") == parentCommentResult.getInt("comment_id")) {
                        int childUserId = childCommentResult.getInt("user_id");
                        String parentCommentContent = parentCommentResult.getString("content");
                        String childCommentContent = childCommentResult.getString("content");
                        Date childCommentPostedOn = childCommentResult.getDate("date_posted_on");
                        int childLikeCount = childCommentResult.getInt("like_count");
                        String childLikers = childCommentResult.getString("likers");
                        int childCommentId = childCommentResult.getInt("comment_id");

                        PreparedStatement childUser = conn.prepareStatement("SELECT surname,name FROM users WHERE user_id=?");
                        childUser.setInt(1, childUserId);

                        ResultSet childUserRESULT = childUser.executeQuery();

                        childUserRESULT.next();

                        String[] childLikersArray;

                        if (childLikers != null) {
                            childLikersArray = childLikers.split(", ");
                        } else {
                            childLikersArray = new String[0];
                        }
                        String childButtonText;
                        if (childLikeCount > 1) {
                            childButtonText = "Liked by " + childLikersArray[0] + " + " + (childLikeCount - 1);
                        } else if (childLikeCount == 1) {
                            childButtonText = "Liked by " + childLikers;
                        } else {
                            childButtonText = "Like";
                            childLikers = ""; // Set childLikers to an empty string if there are no likers
                        }
                        out.println("<tr id=\"comment-row-" + childCommentId + "\" data-parent-comment-id=\"" + parentCommentResult.getInt("comment_id") + "\" data-parent-comment-text=\"" + commentContent +"\" data-user-name=\"" + childUserRESULT.getString("surname") + " " + childUserRESULT.getString("name") + "\">"
                        + "<td width=\"25%\" class=\"text-secondary\" data-reply-header=\"" + parentCommentResult.getInt("comment_id") + "\">" + childUserRESULT.getString("surname") + " " + childUserRESULT.getString("name") + " replied to: <i>" + commentContent + "</i></td>"
                                + "<td width=\"55%\"><i>" + childCommentContent + "</i></td>"
                                + "<td width=\"10%\">" + childCommentPostedOn + "</td>"
                                + "<td width=\"5%\"><button type=\"button\" class=\"btn btn-primary btn-sm\" onclick=\"likeComment(" + childCommentId + ")\" title=\"" + childLikers + "\" " + ((accountType == null || accountType.equals("author")) ? "disabled" : "") + ">" + childButtonText + "</button></td>");

                        if (currentUserId == childUserId && session.getAttribute("accountType").equals("user")) {
                            out.println("<td width=\"5%\"><button type=\"button\" id=\"remove-" + childCommentId + "\" class=\"btn btn-warning btn-sm\" onclick=\"deleteComment(" + childCommentId + ")\">Remove</button></td>");
                        } else {
                            out.println("<td width=\"5%\"><button type=\"button\" class=\"btn btn-info btn-sm\" data-comment-id=\"" + childCommentId + "\" data-parent-comment-id=\"" + childCommentResult.getInt("parent_comment_id") + "\" onclick=\"replyComment(this)\">Reply</button></td>");
                        }
                        out.println("</tr>");
                    }
                }
            }
        %>

        </tbody>
    </table>





</body>

</html>


