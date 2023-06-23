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

<!DOCTYPE html>
<html style="position: relative;
                min-height: 100%;">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>News Preferences</title>
    <link href="https://fonts.googleapis.com/css2?family=Barlow:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh" crossorigin="anonymous">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.4/jquery.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.0/dist/js/bootstrap.bundle.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" />
    <script src="javascript/jquery.min.js"></script>
    <script src="javascript/jquery.highlight.js"></script>

    <script src="javascript/scrips.js"></script>
</head>
<body style="margin-bottom: 200px; ">


<%
    Connection conn = DatabaseConnector.getConnection();
    Statement stmt = conn.createStatement();
    ResultSet rs = stmt.executeQuery("SELECT * FROM news WHERE is_draft = 0");
%>

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
                        String accountType = (String) session.getAttribute("accountType");
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



<div class="container" style="padding: 20px">
    <div class="row">
        <% while(rs.next()) { %>
        <div class="col-md-4 mb-4">
            <div class="card">
                <div class="card-body">
                    <h5 class="card-title">
                        <a href="seeOtherNews.jsp?news_id=<%= rs.getInt("news_id") %>"><%= rs.getString("news_title") %></a>
                    </h5>
                </div>
            </div>
        </div>
        <% } %>
    </div>
</div>

<% rs.close(); stmt.close(); %>

<a href="#" class="back-to-top" id="myBtn" onmouseover="this.style.background='#0096FF';" onmouseout="this.style.background='#FF3131';" style="position: fixed; display: none; width: 44px; height: 44px; text-align: center; line-height: 1; font-size: 22px; right: 15px; bottom: 15px; transition: .5s; background: #FF3131; border-radius: 44px; z-index: 9;"><i class="fa fa-chevron-up" style="color: #ffffff; padding-top: 10px;"></i></a>

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
</body>
</html>