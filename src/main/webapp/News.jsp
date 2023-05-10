<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@page import="java.util.ArrayList"%>
<%@page import="com.project.entities.News"%>
<%@ page import = "org.json.simple.JSONObject" %>
<%@ page import = "org.json.simple.parser.JSONParser" %>
<%@ page import = "org.json.simple.parser.*" %>
<%@page import="java.io.FileReader"%>
<%@ page import = "java.sql.*"%>
<%@ page import="java.util.Comparator" %>
<%@ page import="java.util.Collections" %>
<%@ page import="com.project.entities.DatabaseConnector" %>

<%

    Connection conn = DatabaseConnector.getConnection();

    PreparedStatement ps1 = conn.prepareStatement("SELECT COUNT(*) FROM authors");
%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>News</title>
    <link rel="stylesheet" href="./css/utils.css">
    <link href="https://fonts.googleapis.com/css2?family=Barlow:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh" crossorigin="anonymous">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet">

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.0/dist/js/bootstrap.bundle.min.js"></script>

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
                <a href="login.jsp?from=<%= request.getRequestURI() %>" class="btn btn-warning">Login</a>
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
                            int userId = findUserRESULT.getInt("user_id");
                            session.setAttribute("userId", userId);

                            out.println("<strong>" + findUserRESULT.getString("surname") + " " + findUserRESULT.getString("name") + " - " + session.getAttribute("accountType") + "</strong>");
                        }

                    %>

                    <span class="sr-only">(current)</span></a>
            </li>
            <!-- Add the "Subscribe to our services" element here -->
            <% if(session.getAttribute("accountType") != null && !session.getAttribute("accountType").equals("author")) { %>
            <li class="nav-item">
                <a class="nav-link text-white nav-item-transition" href="#" id="subscribeServicesNavLink" data-bs-toggle="modal" data-bs-target="#subscriptionModal">Subscribe to our services</a>
            </li>
            <li class="nav-item nav-item-transition" id="preferencesNavItem" style="display: none;">
                <a class="nav-link text-white" href="preferences.jsp">Preferences</a>
            </li>
            <% } %>




        </ul>
        <% if(session.getAttribute("accountType") != null){ %>
        <ul class="navbar-nav ml-auto">
            <li class="nav-item">
                <a class="nav-link" href="logout.jsp">Logout <span class="sr-only">(current)</span></a>
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
                You will gain access to save any of your preferred news
                and receive notifications about them. Would you like to subscribe to our newsletter?
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-primary" id="subscribeButton">Subscribe</button>
            </div>
        </div>
    </div>
</div>


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
            Collections.sort(news, new Comparator<News>() {
                @Override
                public int compare(News n1, News n2) {
                    return n2.getNewsPostedOn().compareTo(n1.getNewsPostedOn());
                }
            });

            for (News n : news) {
                PreparedStatement categoryName = conn.prepareStatement("SELECT category_name FROM categories WHERE category_id = " + n.getCategoryId());
                ResultSet categoryNameRESULT = categoryName.executeQuery();
                categoryNameRESULT.next();

                try {
                    out.println(
                            "<tr>" +
                                    "<th><span class='searchable'>" + n.getNewsTitle() + "</span></th>" +
                                    "<th><span class='searchable'>" + n.getNewsPostedOn() + "</span></th>" +
                                    "<th><span class='searchable'>" + categoryNameRESULT.getString(1) + "</span></th>" +
                                    "<th><a href=\"seeNews.jsp?id= " + n.getNewsId() + "\"><button class=\"btn bg-main text-white\">View</button></a></th>" +
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
<a href="#" class="back-to-top" id="myBtn"><i class="fa fa-chevron-up"></i></a>
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
    });



</script>
</body>
</html>
