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
<%@ page import="com.project.summariser.SummaryTool" %>


<%

    String accountType = (String) session.getAttribute("accountType");
    String draftId = null;
    PreparedStatement ps1 = conn.prepareStatement("SELECT draft_id FROM news WHERE news_id = ?");
    ps1.setString(1, id);
    ResultSet rs = ps1.executeQuery();

    if(rs.next()){
        draftId = rs.getString("draft_id");
    }

    PreparedStatement ps = conn.prepareStatement("SELECT * FROM news WHERE news_id = ? AND news_availability != 0");
    ps.setString(1, id);
    ResultSet result = ps.executeQuery();

    // Fetch parent comments
    PreparedStatement parentComment = conn.prepareStatement("SELECT c.*, COUNT(cl.user_id) as like_count, GROUP_CONCAT(CASE WHEN u.surname IS NOT NULL THEN CONCAT(u.surname, ' ', u.name) WHEN a.surname IS NOT NULL THEN CONCAT(a.surname, ' ', a.name) END SEPARATOR ', ') as likers FROM comments c LEFT JOIN comment_likes cl ON c.comment_id = cl.comment_id LEFT JOIN users u ON cl.user_id = u.user_id LEFT JOIN authors a ON cl.user_id = a.author_id WHERE c.news_id=" + id + " AND c.availability = 1 AND c.parent_comment_id IS NULL GROUP BY c.comment_id, c.date_posted_on ORDER BY c.date_posted_on DESC");

    // Fetch child comments (replies)
    PreparedStatement childComment = conn.prepareStatement("SELECT c.*, COUNT(cl.user_id) as like_count, GROUP_CONCAT(CASE WHEN u.surname IS NOT NULL THEN CONCAT(u.surname, ' ', u.name) WHEN a.surname IS NOT NULL THEN CONCAT(a.surname, ' ', a.name) END SEPARATOR ', ') as likers FROM comments c LEFT JOIN comment_likes cl ON c.comment_id = cl.comment_id LEFT JOIN users u ON cl.user_id = u.user_id LEFT JOIN authors a ON cl.user_id = a.author_id WHERE c.news_id=" + id + " AND c.availability = 1 AND c.parent_comment_id IS NOT NULL GROUP BY c.comment_id, c.date_posted_on ORDER BY c.date_posted_on ASC", ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);

    PreparedStatement totalComments = conn.prepareStatement("SELECT COUNT(*) FROM comments WHERE news_id=" + id + " AND availability = 1");
    ResultSet parentCommentResult = parentComment.executeQuery();
    ResultSet childCommentResult = childComment.executeQuery();
    ResultSet totalCommentsRESULT = totalComments.executeQuery();

    int noComments = 0;
    String newsTitle = "";
    String newsContent = "";
    String summarizedContent = "";
    Date postedOn = null;
    int categoryId = 0; // Declare the categoryId variable here

    if(result.next() && totalCommentsRESULT.next()) {
        noComments = totalCommentsRESULT.getInt(1);
        newsTitle = result.getString("news_title");
        newsContent = result.getString("news_content");
        postedOn = result.getDate("news_posted_on");
        categoryId = result.getInt("category_id"); // Fetch the category_id from the news table

        // Now, use the SummaryTool class to summarize the news content:
        SummaryTool summary = new SummaryTool();
        summary.init();
        summary.setContent(newsContent);
        summary.extractSentenceFromContext();
        summary.groupSentencesIntoParagraphs();
        summary.createIntersectionMatrix();
        summary.createDictionary();
        summary.createSummary();

        summarizedContent = summary.summaryToString();
    }
%>




<!DOCTYPE html>
<html   style="position: relative;
                min-height: 100%;">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>News</title>
    <link rel="stylesheet" href="./css/utils.css">
    <link href="https://fonts.googleapis.com/css2?family=Barlow:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh" crossorigin="anonymous">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.4/jquery.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.0/dist/js/bootstrap.bundle.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" />
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css">
    <!-- assuming you have the javascript files in a js folder -->
    <script src="javascript/jquery.min.js"></script>
    <script src="javascript/jquery.highlight.js"></script>

    <script src="javascript/scrips.js"></script>

</head>
<body style="margin-bottom: 200px; ">


<nav class="navbar navbar-expand-lg" style="background: #FF3131">
    <div class="navbar-collapse" id="navbarNav">
        <ul class="navbar-nav align-items-center">
            <li class="nav-item active">
                <a class="navbar-brand" href="News.jsp"><img src="./resources/Logo.jpg" alt="News" class="nav-icon" style="width: 100px; height: 60px;"></a>
            </li>

            <% if(session.getAttribute("accountType") == null){ %>
            <li class="nav-item text-white mx-3">
                <a href="login.jsp?from=<%= request.getRequestURI() %>" class="btn btn-outline-white">
                    <i class="far fa-user-circle"></i> Login
                </a>
            </li>
            <% } %>
            <li class="nav-item text-white mx-3">
                <%
                    if(session.getAttribute("accountType") == null)
                        out.println("<strong>Guest</strong>");

                    if (session.getAttribute("accountType") != null) {

                        String currentEmail = (String) session.getAttribute("email");
                        String displayName = "";
                        String sql = "";

                        if (accountType.equals("admin")) {
                            sql = "SELECT * FROM authors WHERE email = ?";
                        } else {
                            sql = "SELECT * FROM " + accountType + "s WHERE email = ?";
                        }

                        PreparedStatement findUser = conn.prepareStatement(sql);
                        findUser.setString(1, currentEmail);

                        ResultSet findUserRESULT = findUser.executeQuery();
                        findUserRESULT.next();

                        if (accountType.equals("author")) {
                            displayName = findUserRESULT.getString("surname") + " " + findUserRESULT.getString("name") + " - " + accountType;
                            int authorId = findUserRESULT.getInt("author_id");
                            session.setAttribute("authorId", authorId);
                            out.println("<a href='authorProfile.jsp?author_id=" + authorId + "' style='color: white;'><strong>" + displayName + "</strong></a>");

                        }
                        else if(accountType.equals("user")) {
                            int userId = findUserRESULT.getInt("user_id");
                            session.setAttribute("userId", userId);
                            displayName = "<strong>" + findUserRESULT.getString("surname") + " " + findUserRESULT.getString("name") + " - " + accountType + "</strong>";
                            out.println(displayName);
                        } else if(accountType.equals("admin")) {
                            displayName = "<strong>Admin</strong>";
                            out.println(displayName);
                        }
                    }
                %>
            </li>

            <% if(session.getAttribute("accountType") != null &&
                    session.getAttribute("accountType").equals("admin")){ %>
            <li class="nav-item">
                <a class="text-white nav-item-transition" href="authorRequests.jsp">Author Requests</a>
            </li>
            <% } %>
        </ul>
        <% if(session.getAttribute("accountType") != null){ %>
        <ul class="navbar-nav ml-auto">
            <li class="nav-item ml-2">
                <a class="nav-link text-white" href="logout.jsp">Logout <span class="sr-only">(current)</span></a>
            </li>
        </ul>
        <% } %>
    </div>
</nav>
<div class="modal fade" id="subscriptionModal" tabindex="-1" aria-labelledby="subscriptionModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="subscriptionModalLabel">Subscribe to our newsletter</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"><i class="fas fa-times"></i></button>
            </div>
            <div class="modal-body">
                By clicking subscribe,
                you confirm
                that you agree to our <a href="#" data-bs-dismiss="modal" data-bs-toggle="modal" data-bs-target="#privacyPolicyModal">Privacy Policy</a>.
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-primary" id="subscribeButton">Subscribe</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="joinTeamModal" tabindex="-1" aria-labelledby="joinTeamModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="joinTeamModalLabel">Join our team</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"><i class="fas fa-times"></i></button>
            </div>
            <div class="modal-body">
                Before proceeding with the recruitment process,
                make sure to read our <a href="#" data-bs-dismiss="modal" data-bs-toggle="modal" data-bs-target="#privacyPolicyModal">Privacy Policy</a>.
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-primary" id="goToFormButton">Take me to the form</button>
            </div>
        </div>
    </div>
</div>

<div class="container m-5 p-2" style="max-width: 80%;">
    <div class="row">
        <div class="col-lg-9 overflow-auto">
            <p class="h2 news-title" style=" font-family: 'Barlow', sans-serif; font-weight: bold"><%=newsTitle %></p>
            <p class="h5 mt-2 p-4 news-content" style=" font-family: 'Barlow', sans-serif;"><%=newsContent%></p>
            <img src="${pageContext.request.contextPath}/imageServlet?draft_id=<%= draftId %>" alt="Draft Image" width="700" height="450" />



            <br><br>

            <em class="mt-1"><%=postedOn%>, posted by <%

                PreparedStatement noAuthors = conn.prepareStatement("SELECT COUNT(*) FROM draft_authors WHERE draft_id =" + draftId);
                ResultSet noAuthorsRESULT = noAuthors.executeQuery();
                noAuthorsRESULT.next();

                PreparedStatement idAuthors = conn.prepareStatement("SELECT author_id FROM draft_authors WHERE draft_id=" + draftId);
                ResultSet idAuthorsRESULT = idAuthors.executeQuery();

                String r = "";

                int authors = noAuthorsRESULT.getInt(1);
                int originalAuthors = authors;
                while(idAuthorsRESULT.next() && authors != 0)
                {
                    PreparedStatement authorName = conn.prepareStatement("SELECT surname,name FROM authors WHERE author_id=" + idAuthorsRESULT.getInt(1));
                    ResultSet authorNameRESULT = authorName.executeQuery();
                    if (authorNameRESULT.next()) {
                        if(authors != 1) r += authorNameRESULT.getString("surname") + " " + authorNameRESULT.getString("name") +", ";
                        else r += authorNameRESULT.getString("surname") + " " + authorNameRESULT.getString("name");
                    } else {
                        System.out.println("No name found for author_id=" + idAuthorsRESULT.getInt(1));
                    }

                    authors--;
                }

                out.println(r);

                if(originalAuthors > 1) out.println(" (" + originalAuthors + " authors)");
                else out.println("(one author)");

            %></em><br><br>



            <p class="lead" id="num-comments">
                <% if (noComments > 0 && session.getAttribute("accountType") != null) { %>
                Comments (<span id="num-comments-value"><%= noComments %></span>)
                <% } else if(session.getAttribute("accountType") != null && session.getAttribute("accountType").equals("user")){ %>
                <b style=" font-family: 'Barlow', sans-serif;">There are no comments on this news yet. Be the first one to comment!</b>
                <% } else { %>
                <b style=" font-family: 'Barlow', sans-serif;">Please log in as a user to be able to comment</b>
                <% } %>
            </p>


            <% if(session.getAttribute("accountType") == "user"){ %>
            <form action="#" method="post" class="row">
                <div class="col-9">
                    <input type="text" placeholder="Type comment" name="comment" class="w-100" required title="Please fill out this field.">
                </div>
                <div class="col-3">
                    <button type="submit" name="submit" class="btn btn-warning">Post</button>

                </div>
            </form>
            <% } %>
        </div>

        <div class="col-lg-3">
            <div class="card" style="width: 100%;">
                <div class="card-header">
                    Summary
                </div>
                <div class="card-body">
                    <%= summarizedContent %>
                </div>
            </div>
                    <% if (session.getAttribute("accountType") != null && session.getAttribute("accountType").equals("user")) { %>
                    <%
                        Integer userId = (Integer) session.getAttribute("userId");
                        ps = conn.prepareStatement("SELECT subscribed FROM users WHERE user_id = ?");
                        ps.setInt(1, userId);
                        rs = ps.executeQuery();
                        boolean isSubscribed = false;
                        if (rs.next()) {
                            isSubscribed = rs.getBoolean("subscribed");
                        }
                        if (isSubscribed) {
                    %>
                    <div class="right-side" style=" text-align: right;">
                        <button id="addToPrefBtn"
                                class="btn btn-primary space-below"
                                style="margin-bottom: 10px;"
                                data-user-id="<%=session.getAttribute("userId")%>"
                                data-news-id="<%=id%>"
                                data-category-id="<%=categoryId%>">
                            <i class="fas fa-bookmark"></i> Add to preferences
                        </button>
                        <%
                            }
                            boolean userHasReported = false;
                            ps = conn.prepareStatement("SELECT * FROM UserReports WHERE user_id = ? AND news_id = ?");
                            ps.setInt(1, userId);
                            ps.setString(2, id);
                            rs = ps.executeQuery();
                            if (rs.next()) {
                                userHasReported = true;
                            }
                        %>

                        <form id="reportFakeNewsForm" method="POST" action="ReportFakeNewsServlet" class="space-below">
                            <input type="hidden" name="userId" value="<%=session.getAttribute("userId")%>" />
                            <input type="hidden" name="draftId" value="<%=draftId%>" />
                            <input type="hidden" name="newsId" value="<%=id%>" />
                            <%
                                if (userHasReported) {
                            %>
                            <button type="submit" class="btn btn-danger" disabled>
                                <i class="fas fa-exclamation-triangle"></i> Report Fake News
                            </button>
                            <%
                            } else {
                            %>
                            <button type="submit" class="btn btn-danger">
                                <i class="fas fa-exclamation-triangle"></i> Report Fake News
                            </button>
                            <%
                                }
                            %>

                        </form>
                    </div>
                    <% } %>
                </div>


            </div>
        </div>
<%
    String newsId = request.getParameter("news_id"); // Assuming you're passing the news ID in the request
    ps = conn.prepareStatement("SELECT draft_id FROM news WHERE news_id = ?");
    ps.setString(1, newsId);
    rs = ps.executeQuery();

    if (rs.next()) {
        draftId = String.valueOf(rs.getInt("draft_id"));
    }
    System.out.println("Draft ID: " + draftId);
%>
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
                out.println("<td width=\"25%\" class=\"text-secondary\">" + userRESULT.getString("surname") + " " + userRESULT.getString("name")  + " said </td>"
                        + "<td width=\"55%\" data-parent-comment-text><i>" + commentContent + "</i></td>"
                        + "<td width=\"10%\">" + commentPostedOn + "</td>"
                        + "<td width=\"5%\"><button type=\"button\" id=\"like-" + commentId + "\" class=\"btn btn-primary btn-sm\" onclick=\"likeComment(" + commentId + ")\" title=\"" + likers + "\" " + ((accountType == null || accountType.equals("author")) ? "disabled" : "") + ">" + buttonText + "</button></td>"
                );


                if (currentUserId == userId && session.getAttribute("accountType").equals("user")) {
                    out.println("<td width=\"5%\"><button type=\"button\" id=\"edit-" + commentId + "\" class=\"btn btn-secondary btn-sm\" data-edit-button onclick=\"editComment(" + commentId + ")\">Edit</button></td>");
                    out.println("<td width=\"5%\"><button type=\"button\" id=\"remove-" + commentId + "\" class=\"btn btn-warning btn-sm\" data-remove-button onclick=\"deleteComment(" + commentId + ")\">Remove</button></td>");
                } else {
                    if (accountType != null && accountType.equals("user")) {
                        out.println("<td width=\"5%\"><button type=\"button\" class=\"btn btn-info btn-sm\" data-comment-id=\"" + commentId + "\" data-parent-comment-id=\"" + commentId + "\" onclick=\"replyComment(this)\">Reply</button></td>");
                    }
                    out.println("<td></td>"); // Add an empty cell to keep the table structure
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
                                + "<td width=\"25%\" class=\"text-secondary\" data-reply-header=\"" + parentCommentResult.getInt("comment_id") + "\">" + childUserRESULT.getString("surname") + " " + childUserRESULT.getString("name")  + " replied to: <i>" + commentContent + "</i></td>"
                                + "<td width=\"55%\"><i>" + childCommentContent + "</i></td>"
                                + "<td width=\"10%\">" + childCommentPostedOn + "</td>"
                                + "<td width=\"5%\"><button type=\"button\" id=\"like-" + childCommentId + "\" class=\"btn btn-primary btn-sm\" onclick=\"likeComment(" + childCommentId + ")\" title=\"" + childLikers + "\" " + ((accountType == null || accountType.equals("author")) ? "disabled" : "") + ">" + childButtonText + "</button></td>");

                        if (currentUserId == childUserId && session.getAttribute("accountType").equals("user")) {
                            out.println("<td width=\"5%\"><button type=\"button\" id=\"edit-" + childCommentId + "\" class=\"btn btn-secondary btn-sm\" data-edit-button onclick=\"editComment(" + childCommentId + ")\">Edit</button></td>");
                            out.println("<td width=\"5%\"><button type=\"button\" id=\"remove-" + childCommentId + "\" class=\"btn btn-warning btn-sm\" data-remove-button onclick=\"deleteComment(" + childCommentId + ")\">Remove</button></td>");
                        } else {
                            if (accountType != null && accountType.equals("user")) {
                                out.println("<td width=\"5%\"><button type=\"button\" class=\"btn btn-info btn-sm\" data-comment-id=\"" + childCommentId + "\" data-parent-comment-id=\"" + childCommentResult.getInt("parent_comment_id") + "\" onclick=\"replyComment(this)\">Reply</button></td>");
                            }
                            out.println("<td></td>"); // Add an empty cell to keep the table structure
                        }

                    }
                }
            }
        %>

        </tbody>
    </table>

    <a href="#" class="back-to-top"  id="myBtn"><i class="fa fa-chevron-up"></i></a>
    <script>
        document.getElementById('subscriptionModal').addEventListener('hidden.bs.modal', function () {
            document.querySelector('.btn-close').setAttribute('data-bs-dismiss', 'modal');
        });
        async function fetchSubscriptionStatus() {
            const userId = '<%= session.getAttribute("userId") %>';
            const response = await fetch('checkSubscriptionStatus.jsp?user_id=' + userId, { method: 'POST' });

            if (response.ok) {
                return response.json();
            } else {
                console.error("Error fetching subscription status:", response.statusText);
                throw new Error(response.statusText);
            }
        }
        subscribeButton.addEventListener('click', async function () {
            console.log("Subscribe button clicked");
            try {
                const userId = '<%= session.getAttribute("userId") %>';
                const response = await fetch('subscribeUser.jsp?user_id=' + userId, { method: 'POST' });

                if (response.ok) {
                    const updateResult = await response.json();
                    console.log("Update result:", updateResult);

                    if (updateResult.result === 'success') {
                        // Hide the "Subscribe to our services" nav item
                        var subscribeServicesLink = document.getElementById('subscribeServicesNavLink');
                        if (subscribeServicesLink) {
                            subscribeServicesLink.style.display = 'none';
                        }
                        // Show the "Preferences" nav item
                        var preferencesNavItem = document.getElementById('preferencesNavItem');
                        if (preferencesNavItem) {
                            preferencesNavItem.style.display = 'block';
                        }

                        var subscriptionModal = bootstrap.Modal.getInstance(document.getElementById('subscriptionModal'));
                        subscriptionModal.hide();
                    }
                } else {
                    console.error("Failed to update subscription status");
                }
            } catch (error) {
                console.error("Error:", error.message);
            }
        });
        document.addEventListener('DOMContentLoaded', async function() {
            // Check if the user is already subscribed
            try {
                const subscriptionStatus = await fetchSubscriptionStatus();
                console.log("Subscription status:", subscriptionStatus);

                if (subscriptionStatus.isSubscribed) {
                    // Hide the "Subscribe to our services" link
                    var subscribeServicesLink = document.getElementById('subscribeServicesNavLink');
                    if (subscribeServicesLink) {
                        subscribeServicesLink.style.display = 'none';
                    }
                    // Show the "Preferences" nav item
                    var preferencesNavItem = document.getElementById('preferencesNavItem');
                    if (preferencesNavItem) {
                        preferencesNavItem.style.display = 'block';
                    }
                } else {
                    // Show the "Subscribe to our services" nav item
                    var subscribeServicesLink = document.getElementById('subscribeServicesNavLink');
                    if (subscribeServicesLink) {
                        subscribeServicesLink.style.display = 'block';
                    }
                    // Hide the "Preferences" nav item
                    var preferencesNavItem = document.getElementById('preferencesNavItem');
                    if (preferencesNavItem) {
                        preferencesNavItem.style.display = 'none';
                    }
                }
            } catch (error) {
                console.error("Error:", error.message);
            }
            const goToFormButton = document.getElementById('goToFormButton');
            if (goToFormButton) {
                goToFormButton.addEventListener('click', function() {
                    window.location.href = 'authorForm.jsp';
                });
            }
        });
        async function addToPreferences(userId, newsId, categoryId) {
            try {
                console.log(`userId: ${userId}, newsId: ${newsId}, categoryId: ${categoryId}`);
                const response = await fetch('addPreference.jsp', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded'
                    },
                    body: new URLSearchParams({
                        user_id: userId,
                        news_id: newsId,
                        category_id: categoryId
                    })
                });

                if (response.ok) {
                    const result = await response.json();

                    if (result.status === 'success') {
                        displaySuccessMessage(document.body, 'Successfully added to preferences');
                    } else {
                        displayErrorMessage(document.body, result.message);
                    }
                } else {
                    displayErrorMessage(document.body, 'Failed to add preference. Please try again.');
                }
            } catch (error) {
                displayErrorMessage(document.body, error.message);
            }
        }
        document.addEventListener('DOMContentLoaded', function() {
            // Find the button
            const addToPrefBtn = document.getElementById('addToPrefBtn');

            // Check if button is null
            if(addToPrefBtn === null) {
                console.log("Button is null");
            } else {
                console.log("Button is not null");

                // Add a click event listener
                addToPrefBtn.addEventListener('click', function() {
                    console.log("Button is clicked!");
                    // Get the user id, news id, and category id
                    const userId = this.getAttribute('data-user-id');
                    const newsId = this.getAttribute('data-news-id');
                    const categoryId = this.getAttribute('data-category-id');

                    // Call the addToPreferences function
                    addToPreferences(userId, newsId, categoryId);
                });
            }
        });


    </script>
    <footer class="footer" style="background: #0096FF ; color: white; padding: 20px; position: absolute;
                right: 0;
                bottom: 0;
                left: 0;
                ">
        <div class="container">
            <div class="row justify-content-between">
                <div class="col-lg-4">
                    <h5>Links</h5>
                    <ul class="list-unstyled">
                        <% if(session.getAttribute("accountType") != null && !session.getAttribute("accountType").equals("author")
                                &&!session.getAttribute("accountType").equals("admin")) { %>
                        <a class="text-white footer-item-transition" href="#" id="subscribeServicesNavLink" data-bs-toggle="modal" data-bs-target="#subscriptionModal">Subscribe to our services</a>
                        <li id="preferencesNavItem" style="display: none;">
                            <a class="text-white" href="preferences.jsp">Preferences</a>
                        </li>
                        <% } %>
                        <% if(session.getAttribute("accountType") != null && !session.getAttribute("accountType").equals("author")
                                &&!session.getAttribute("accountType").equals("admin")){ %>
                        <li>
                            <a class="text-white" href="#" data-bs-toggle="modal" data-bs-target="#joinTeamModal">Want to join our team?</a>
                        </li>
                        <%} %>
                        <% if(session.getAttribute("accountType") != null &&
                                (!session.getAttribute("accountType").equals("author") || session.getAttribute("accountType").equals("admin"))){ %>
                        <li>
                            <a class="text-white" href="seeAuthors.jsp">See the contributors to the site</a>
                        </li>
                        <%} %>
                        <li>
                            <a class="text-white" href="#" data-bs-toggle="modal" data-bs-target="#privacyPolicyModal">Privacy Policy</a>
                        </li>
                    </ul>
                </div>
                <div class="col-lg-4">
                    <h5>Make sure you don't miss</h5>
                    <ul class="list-unstyled">
                        <li>
                            <a class="text-white" href="otherNews.jsp">News from Around the Web</a>
                        </li>
                    </ul>
                </div>
                <div class="col-lg-4">
                    <h5>Editorial</h5>
                    <p>Stay connected with us:</p>
                    <%
                        PreparedStatement stmt1 = conn.prepareStatement("SELECT facebook_url, linkedin_url from authors where surname= ? and name= ?");
                        stmt1.setString(1, "Constantin");
                        stmt1.setString(2, "Ioan");
                        ResultSet rs1 = stmt1.executeQuery();
                        while(rs1.next()) {
                            String facebookUrl = rs1.getString("facebook_url");
                            String linkedinUrl = rs1.getString("linkedin_url");
                    %>
                    <a href="<%=facebookUrl%>" target="_blank"><i class="fab fa-facebook-square fa-2x text-white"></i></a>
                    <a href="<%=linkedinUrl%>" target="_blank"><i class="fab fa-linkedin fa-2x text-white"></i></a>
                    <%
                        }
                    %>
                </div>
            </div>
        </div>
    </footer>

    <!-- Privacy Policy Modal -->
    <div class="modal fade" id="privacyPolicyModal" tabindex="-1" aria-labelledby="privacyPolicyModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-scrollable">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="privacyPolicyModalLabel">Privacy Policy</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"><i class="fas fa-times"></i></button>
                </div>
                <div class="modal-body">
                    <h2 class="text-bold">Special News Website Newsletter Subscription Privacy Policy</h2>

                    This privacy policy governs the use of personal data collected during the process of subscription to the newsletter service and author application of the Special News website (the "Service"). The Service is provided by Special News (hereinafter referred to as "we", "us", or "our"). By subscribing to our newsletter and/or applying to be an author, you agree to this privacy policy.

                    <h3><strong>1. Information Collection and Use</strong></h3>

                    In order to provide you with our newsletter, we will request your name and email address. For those applying to be an author, we may also collect your photo, curriculum vitae (CV), and your Facebook and LinkedIn profiles. We will use your personal data to send you the newsletters that you have requested, to review your author application, and, if accepted as an author, to display your author profile to other users. We may occasionally send you updates about changes to our services, policies, or other administrative information.

                    <h3><strong>2. Sharing of Personal Data</strong></h3>

                    We respect your privacy and will not sell, trade, or lease your personal information to any third parties unless we have your explicit permission, or are required to do so by law. However, we may share your information with service providers who assist us in delivering the newsletter and maintaining the author profiles, such as email service providers and web hosting services. These companies are authorized to use your personal data only as necessary to provide these services to us.

                    <h3><strong>3. Data Protection</strong></h3>

                    We employ appropriate technical and organizational security measures to protect your information from unauthorized access, use, disclosure, alteration, or destruction. However, as no method of transmission over the internet or electronic storage is completely secure, we cannot guarantee its absolute security.

                    <h3><strong>4. Your Rights</strong></h3>

                    You have the right to access, update, or delete your personal information at any time. If you are an author, you may also request to have your profile removed or information updated. You may opt-out of receiving our newsletter at any time by clicking the "unsubscribe" link at the bottom of each newsletter, or by contacting us directly.

                    <h3><strong>5. Changes to This Privacy Policy</strong></h3>

                    We may update this privacy policy from time to time in response to changing legal, technical, or business developments. When we update our privacy policy, we will take appropriate measures to inform you, consistent with the significance of the changes we make.

                    <h3><strong>6. Contact Us</strong></h3>

                    If you have any questions about this privacy policy, or if you would like to exercise any of your rights, please feel free to contact us at <a href="mailto:constantinioan20@stud.ase.ro">constantinioan20@stud.ase.ro</a>.

                    Your use of the Service following these changes means that you accept the revised privacy policy. This policy is effective as of 01.06.2023.

                    Please remember that your use of the Special News website and its services is also subject to our general Terms and Conditions.
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
