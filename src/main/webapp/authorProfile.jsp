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
<%@ page import="com.project.entities.News" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.util.stream.Collectors" %>
<%@ page import="java.io.InputStreamReader" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="com.project.entities.NewsArticle" %>


<%
    Connection conn = DatabaseConnector.getConnection();
    PreparedStatement stmt = null;
    ResultSet rs = null;
    String accountType = (String) session.getAttribute("accountType");
    int author_id = Integer.parseInt(request.getParameter("author_id"));
    String sql = "SELECT * FROM authors WHERE author_id = ?";
    stmt = conn.prepareStatement(sql);
    stmt.setInt(1, author_id);
    rs = stmt.executeQuery();
    rs.next();
    int draftCount=0;

    PreparedStatement ps1 = conn.prepareStatement("SELECT COUNT(*) FROM authors");

%>


<!DOCTYPE html>
<html style="position: relative;
    min-height: 100%;">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Authors</title>
    <link rel="stylesheet" href="./css/utils.css">
    <link href="https://fonts.googleapis.com/css2?family=Barlow:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh" crossorigin="anonymous">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" />
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="javascript/jquery.highlight.js"></script>
    <script src="javascript/scrips.js"></script>

</head>
<body style="margin-bottom: 200px;">
<nav class="navbar navbar-expand-lg" style="background: #FF3131">
    <div class="navbar-collapse" id="navbarNav">
        <ul class="navbar-nav align-items-center">
            <li class="nav-item active">
                <a class="navbar-brand" href="News.jsp"><img src="./resources/Logo.jpg" alt="News" class="nav-icon" style="width: 100px; height: 60px;"></a>
            </li>


            <li class="nav-item text-white mx-3">
                    <%
                        if(session.getAttribute("accountType") == null)
                            out.println("<strong>Guest</strong>");

                        if (session.getAttribute("accountType") != null) {

                            String currentEmail = (String) session.getAttribute("email");
                            String displayName = "";
                            String sql1 = "";

                            if (accountType.equals("admin")) {
                                sql1 = "SELECT * FROM authors WHERE email = ?";
                            } else {
                                sql1 = "SELECT * FROM " + accountType + "s WHERE email = ?";
                            }

                            PreparedStatement findUser = conn.prepareStatement(sql1);
                            findUser.setString(1, currentEmail);

                            ResultSet findUserRESULT = findUser.executeQuery();
                            findUserRESULT.next();

                            if(session.getAttribute("accountType").equals("author")) {
                                displayName = findUserRESULT.getString("surname") + " " + findUserRESULT.getString("name") + " - " + accountType;
                                int authorId = findUserRESULT.getInt("author_id");
                                session.setAttribute("authorId", authorId);
                                String sql2 = "SELECT COUNT(*) as draft_count FROM draft_authors WHERE author_id = ?";
                                PreparedStatement stmt1 = conn.prepareStatement(sql2);
                                stmt1.setInt(1, authorId);
                                ResultSet rs1 = stmt1.executeQuery();
                                rs1.next();
                                draftCount = rs1.getInt("draft_count");
                                out.println("<a href='authorProfile.jsp?author_id=" + authorId + "' style='color: white;'><strong>" + displayName + "</strong></a>");

                            } else if(session.getAttribute("accountType").equals("user")) {
                                int userId = findUserRESULT.getInt("user_id");
                                session.setAttribute("userId", userId);
                                displayName = "<strong>" + findUserRESULT.getString("surname") + " " + findUserRESULT.getString("name") + " - " + accountType + "</strong>";
                                out.println(displayName);
                            }else if(session.getAttribute("accountType").equals("admin")) {
                                displayName = "<strong>Admin</strong>";
                                out.println(displayName);
                            }

                        }
                    %>
            </li>

        <% if(session.getAttribute("accountType") != null && session.getAttribute("accountType").equals("admin")){ %>
            <li class="nav-item">
                <a class="text-white nav-item-transition" href="authorRequests.jsp">Author Requests</a>
            </li>
        <% } %>
        </ul>
        <% if(session.getAttribute("accountType") != null){ %>
        <ul class="navbar-nav ml-auto">
            <li class="nav-item">
                <div class="input-group">
                    <span class="input-group-text">
                        <i class="fas fa-search" style="width: fit-content"></i>
                    </span>
                    <input type="text" class="form-control" id="myInput" placeholder="Search">
                </div>
            </li>
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
                You will gain access to save any of your preferred news
                and receive notifications about them. Would you like to subscribe to our newsletter?
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
                By joining our team, you agree to our privacy policy.
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-primary" id="goToFormButton">Take me to the form</button>
            </div>
        </div>
    </div>
</div>
<div class="container">
    <p class="h3 my-5 text-center">Author profile</p>
    <div class="row">
        <div class="col-3 mt-5">
            <img class="profile-image img-fluid" style="max-width:100%; height:auto;" src="<%= request.getContextPath() + "/imageServlet?author_id=" + author_id %>" alt="Author profile picture">
            <h3>
                <%
                    String authorStatus = (rs.getInt("state_of_author") == 0) ? "Retired" : "";
                %>
                <%= rs.getString("name") + " " + rs.getString("surname") + " " + authorStatus %>
            </h3>
            <h4>Socials:</h4>
            <a href="<%= rs.getString("facebook_url") %>" target="_blank"><i class="fab fa-facebook-square fa-2x"></i></a>
            <a href="<%= rs.getString("linkedin_url") %>" target="_blank"><i class="fab fa-linkedin fa-2x"></i></a>
            <canvas id="histogram"></canvas>
            <%
                boolean isAdmin = false;
                int stateOfAuthor = 1; // default to active author

                if(session.getAttribute("isAdmin") != null) {
                    isAdmin = (boolean) session.getAttribute("isAdmin");
                }

                if(session.getAttribute("stateOfAuthor") != null) {
                    stateOfAuthor = (int) session.getAttribute("stateOfAuthor");
                }

                if(session.getAttribute("accountType") != null && session.getAttribute("accountType").equals("author") && !isAdmin) {
                    if(stateOfAuthor == 1) {
            %>
            <div class="container mt-5 text-center">
                <div>
                    <a href="<%=response.encodeURL("add_draft.jsp?newDraft=true")%>" style="background-color: #FF3131;
    color: #FFFFFF;
    display: block;
    width: 100%;
    height: auto;
    text-align: center;
    font-weight: bold;
    margin-bottom: 10px;">Write draft</a>
                </div>
                <% if(draftCount > 0){ %>
                <div>
                    <a href="access_saved_drafts.jsp" style="background-color: #FF3131;
    color: #FFFFFF;
    display: block;
    height: auto;
    width: 100%;
    text-align: center;
    font-weight: bold;
    margin-bottom: 10px;">Access saved drafts</a>
                </div>
                <% } %>
            </div>
            <%
                } else if(stateOfAuthor == 0) {
            %>
            <p>You have been retired, you can no longer write/post news. Contact the administrator for more details.</p>
            <%
                }
                }
            %>
            <% if (session.getAttribute("accountType") != null && session.getAttribute("accountType").equals("admin")) { %>
            <div class="container mt-5 text-center">
                <div>
                    <a href="retireAuthor.jsp?author_id=<%= rs.getInt("author_id") %>" class="btn" style="background-color: #FF3131;
    color: #FFFFFF;
    display: block;
    height: auto;
    width: 100%;
    text-align: center;
    font-weight: bold;
    margin-bottom: 10px;">Retire Author</a>
                </div>
            </div>
            <% } %>
        </div>

        <div class="col-9">
            <div class="mt-5">
                <h2>Curriculum Vitae</h2>
                <hr>
                <p>
                    <a href="${pageContext.request.contextPath}/downloadCv?email=<%= rs.getString("email") %>" target="_blank">View CV</a>
                </p>
            </div>

            <!-- News articles placeholder -->
            <div class="mt-5">
                <h2>News Articles</h2>
                <hr>
                <div class="row">
                    <%
                        sql = "SELECT news.*, categories.category_name, categories.category_availability FROM news " +
                                "INNER JOIN draft_authors ON news.draft_id = draft_authors.draft_id " +
                                "INNER JOIN categories ON news.category_id = categories.category_id " +
                                "WHERE draft_authors.author_id = ? " +
                                "ORDER BY categories.category_name";

                        stmt = conn.prepareStatement(sql);
                        stmt.setInt(1, author_id);

                        ResultSet newsResult = stmt.executeQuery();
                        Map<String, List<NewsArticle>> newsByCategory = new HashMap<>();
                        while (newsResult.next()) {
                            String categoryName = newsResult.getString("category_name");
                            NewsArticle newsArticle = new NewsArticle();
                            newsArticle.setNewsId(newsResult.getInt("news_id"));
                            newsArticle.setNewsTitle(newsResult.getString("news_title"));
                            newsArticle.setNewsAvailability(newsResult.getInt("news_availability"));
                            newsArticle.setNewsPostedOn(newsResult.getTimestamp("news_posted_on"));
                            newsArticle.setCategoryName(categoryName);
                            newsArticle.setCategoryAvailability(newsResult.getInt("category_availability"));

                            newsByCategory.putIfAbsent(categoryName, new ArrayList<>());
                            newsByCategory.get(categoryName).add(newsArticle);
                        }

                        for (Map.Entry<String, List<NewsArticle>> entry : newsByCategory.entrySet()) {
                            String categoryName = entry.getKey();
                            List<NewsArticle> newsList = entry.getValue();
                            int categoryAvailability = newsList.get(0).getCategoryAvailability();
                    %>
                    <div class="col-12 mb-4">
                        <div class="card" style="width: 100%;">
                            <div class="card-header" style="text-align: center; font-size: 1.5em; font-weight: bold;">
                                <%= categoryName %><% if (categoryAvailability == 0) { %> (News category archived)<% } %>
                            </div>
                            <div class="card-body">
                                <% for (NewsArticle news : newsList) { %>
                                <div class="card" style="margin-bottom: 10px; width: 100%">
                                    <div class="card-body">
                                        <h5 class="card-title">
                                            <% if (news.getNewsAvailability() == 1) { %>
                                            <a href="seeNews.jsp?id=<%= news.getNewsId() %>">
                                                <%= news.getNewsTitle() %>
                                            </a>
                                            <% } else { %>
                                            <span><%= news.getNewsTitle() %> (Archived)</span>
                                            <% } %>
                                        </h5>
                                        <div class="row">
                                            <div class="col-6 text-nowrap text-left">
                                                <small>Posted on: <%= news.getNewsPostedOn() %></small>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <% } %>
                            </div>
                        </div>
                    </div>
                    <%
                        }
                    %>
                </div>
            </div>
        </div>
    </div>
</div>
<%
    // Fetch histogram data
    Map<String, Integer> histogramData = new HashMap<>();
    sql = "SELECT categories.category_name, COUNT(news.category_id) AS category_count " +
            "FROM news INNER JOIN categories ON news.category_id = categories.category_id " +
            "INNER JOIN draft_authors ON news.draft_id = draft_authors.draft_id " +
            "WHERE draft_authors.author_id = ? GROUP BY news.category_id";
    stmt = conn.prepareStatement(sql);
    stmt.setInt(1, author_id);
    rs = stmt.executeQuery();
    while (rs.next()) {
        histogramData.put(rs.getString("category_name"), rs.getInt("category_count"));
    }
%>
<a href="#" class="back-to-top" id="myBtn"><i class="fa fa-chevron-up"></i></a>


<script>
    var categories = <%= new Gson().toJson(histogramData.keySet()) %>;
    var counts = <%= new Gson().toJson(histogramData.values()) %>;

    // Create histogram
    var ctx = document.getElementById('histogram').getContext('2d');
    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: categories,
            datasets: [{
                label: 'Author\'s activity on our page',
                data: counts,
                backgroundColor: 'rgba(75, 192, 192, 0.2)',
                borderColor: 'rgba(75, 192, 192, 1)',
                borderWidth: 1
            }]
        },
        options: {
            scales: {
                y: {
                    beginAtZero: true
                }
            }
        }
    });

    document.getElementById('subscriptionModal').addEventListener('hidden.bs.modal', function () {
        document.querySelector('.btn-close').setAttribute('data-bs-dismiss', 'modal');
    });

    async function fetchSubscriptionStatus() {
        const userId = '<%= session.getAttribute("userId") %>';
        const response = await fetch('checkSubscriptionStatus.jsp?user_id=' + userId, { method: 'POST' });

        if (response.ok) {
            const subscriptionStatus = await response.json();
            return subscriptionStatus.isSubscribed;
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
                    updateUIBasedOnSubscriptionStatus();
                    var subscriptionModal = bootstrap.Modal.getInstance(document.getElementById('subscriptionModal'));
                    subscriptionModal.hide();
                }
            } else {
                console.error("Failed to update subscription status");
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
    $(document).ready(function() {
        var matches = [];
        var index = -1;

        function scrollToElement(element) {
            $('html, body').animate({
                scrollTop: $(element).offset().top
            }, 200);
        }

        function highlightMatches(value) {
            // Unhighlight all previously highlighted matches
            $('.card-header').unhighlight();

            // Highlight new matches
            if (value !== '') {
                $('.card-header').highlight(value);
            }
        }

        $("#myInput").on("keyup", function(e) {
            if (e.key === 'Enter') {
                var value = $(this).val().toLowerCase();

                // Clear matches on new search
                matches = [];
                index = -1;

                if (value === '') {
                    // If the input field is cleared, scroll to the top of the page
                    $('html, body').animate({
                        scrollTop: 0
                    }, 500);

                    highlightMatches(value);
                } else {
                    // Search for matches
                    $(".container .row .col-9 .card-header").each(function() {
                        var headerText = $(this).text().toLowerCase();

                        if (headerText.indexOf(value) > -1) {
                            matches.push(this);
                        }
                    });

                    if (matches.length > 0) {
                        index = 0;
                        scrollToElement(matches[index]);
                        highlightMatches(value);
                    } else {
                        // Unhighlight if no matches
                        highlightMatches('');
                    }
                }
            }
        });
    });



</script>
    <footer class="footer" style="position: absolute;
    right: 0;
    bottom: 0;
    left: 0;
    padding: 20px;
    background: #0096FF;
    color: white;
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
                        PreparedStatement s = conn.prepareStatement("SELECT facebook_url, linkedin_url from authors where surname= ? and name= ?");
                        s.setString(1, "Constantin");
                        s.setString(2, "Ioan");
                        rs = s.executeQuery();
                        while(rs.next()) {
                            String facebookUrl = rs.getString("facebook_url");
                            String linkedinUrl = rs.getString("linkedin_url");
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
</body>
</html>

<%
    // Close the result set, statement, and the connection
    if (rs != null) {
        try { rs.close(); } catch (SQLException ignore) {}
    }
    if (stmt != null) {
        try { stmt.close(); } catch (SQLException ignore) {}
    }
    if (conn != null) {
        try { conn.close(); } catch (SQLException ignore) {}
    }
%>