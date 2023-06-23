<%@ page import = "org.json.simple.JSONObject" %>
<%@ page import = "org.json.simple.parser.JSONParser" %>
<%@ page import = "org.json.simple.parser.*" %>
<%@page import="java.io.FileReader"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*"%>
<%@ page import="com.project.entities.DatabaseConnector" %>
<%@ page import="com.mysql.cj.Session" %>


<%

    Connection conn = DatabaseConnector.getConnection();

%>

<!DOCTYPE html>
<html   style="position: relative;
                min-height: 100%;">

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Add, edit or post a draft</title>
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


<div class="container mt-5">
    <p class="h3 my-5 text-center">Write or edit an existing draft</p>
    <%String category=(String)request.getAttribute("category");
        String draftTitle=(String)request.getAttribute("draft_title");
        String draftContent=(String)request.getAttribute("draft_content");

    %>
    <form onsubmit="console.log('Form submitted with: ', this.elements)" action="${pageContext.request.contextPath}/draft" method="post" enctype="multipart/form-data">
        <div class="form-group">
            <label for="exampleFormControlInput12">Write the news title here</label>
            <input name="draft_title" type="text" class="form-control" id="exampleFormControlInput12" value="<%=draftTitle != null ? draftTitle.replace("\"", "&quot;") : ""%>" placeholder="News title" required>
            <%
                if (draftTitle!=null){
            %>
            <script>
                document.getElementById("exampleFormControlInput12").value = "<%=draftTitle%>";
            </script>

            <%}%>
        </div>

        <div class="form-group">
            <label for="exampleFormControlSelect1">Select category</label>
            <select name="category" class="form-control" id="exampleFormControlSelect1">
                <%
                    PreparedStatement categoryName = conn.prepareStatement("SELECT category_name FROM categories WHERE category_availability = 1");
                    ResultSet categoryNameRESULT = categoryName.executeQuery();

                    while(categoryNameRESULT.next()) {
                        String optionValue = categoryNameRESULT.getString("category_name");
                        out.println("<option>" + optionValue + "</option>");
                    }
                %>
            </select>
           <%
               if (category!=null){
               %>
            <script>
                document.getElementById("exampleFormControlSelect1").value = "<%=category%>";
            </script>
           <%}%>

        </div>
        <div class="form-group">
            <label for="exampleFormControlTextarea1">Write the news content here</label>
            <textarea name="draft_content" class="form-control" id="exampleFormControlTextarea1" rows="5" cols="20" placeholder="News content" required><%=draftContent != null ? draftContent.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;") : ""%></textarea>
            <%
                if (draftContent!=null){
            %>
            <script>
                document.getElementById("exampleFormControlTextarea1").value = "<%=draftContent%>";
            </script>
            <%}%>
        </div>
        <div class="form-group">
            <label for="exampleFormControlFile1">Image File</label>
            <input name="image" type="file" class="form-control-file" id="exampleFormControlFile1" accept=".jpg,.jpeg">
        </div>
        <% if(request.getAttribute("draftId")!=null){
            Integer draftId = (Integer) request.getAttribute("draftId");
            System.out.println(draftId);
            if (draftId != null) {
        %>
        <div class="form-group row">
            <div class="col">
                <div class="col" id="imageDiv">
                    <img src="${pageContext.request.contextPath}/imageServlet?draft_id=<%= draftId %>" alt="Current Image" width="100" height="100" id="imageId"/>
</div>

            </div>
        </div>
        <input type="hidden" name="draft_id" value="<%= draftId %>">
        <%  }
        }
        %>

        <div class="text-center mt-5">
            <button type="submit" name="saveDraft" class="btn text-white mx-auto w-50 mb-3" style="background: #FF3131; font-weight: bold;">Save Draft</button>
            <button type="submit" name="postDraft" class="btn text-white mx-auto w-50 mb-3" style="background: #FF3131; font-weight: bold;">Post Draft</button>
            <button type="submit" name="deleteDraft" class="btn text-white mx-auto w-50" style="background: #FF3131; font-weight: bold;">Delete Draft</button>
        </div>

    </form>
    <% if(request.getAttribute("draftId")!=null){
    Integer draftId = (Integer) request.getAttribute("draftId");
    if (draftId != null) {
    %>

    <form action="${pageContext.request.contextPath}/removeImageServlet?draft_id=<%= draftId %>" method="post" id="removeImageForm" style="display: inline-block;">
        <input type="hidden" name="draftId" value="<%= draftId %>">
        <button type="submit" class="btn" style="background-color: #0096FF; color: #FFFFFF; height: auto; width: 100%; text-align: center; font-weight: bold; margin-bottom: 10px">Remove Image</button>
    </form>
    <%  }
        }
    %>
</div>
<a href="#" class="back-to-top"  id="myBtn"><i class="fa fa-chevron-up"></i></a>
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
                    PreparedStatement stmt = conn.prepareStatement("SELECT facebook_url, linkedin_url from authors where surname= ? and name= ?");
                    stmt.setString(1, "Constantin");
                    stmt.setString(2, "Ioan");
                    ResultSet rs = stmt.executeQuery();
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

