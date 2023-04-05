<%@ page import = "org.json.simple.JSONObject" %>
<%@ page import = "org.json.simple.parser.JSONParser" %>
<%@ page import = "org.json.simple.parser.*" %>
<%@page import="java.io.FileReader"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
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




<!DOCTYPE html>

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css" integrity="sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh" crossorigin="anonymous">
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
            <li class="nav-item">

                <a class="nav-link" href="index.jsp">Home <span class="sr-only">(current)</span></a>

            </li>

            <li class="nav-item">
                <a class="nav-link" href="News.jsp">News <span class="sr-only">(current)</span></a>
            </li>

            <li class="nav-item active">
                <a class="nav-link" href="#">Add draft<span class="sr-only">(current)</span></a>
            </li>

            <li class="nav-item mx-5">
                <a class="nav-link text-warning" href="#">

                    <%

                        if(session.getAttribute("accountType") == null || session.getAttribute("accountType") == "user")
                            response.sendRedirect("login_author.jsp");


                        if(session.getAttribute("accountType") == "user")
                        {

                            String currentEmail = (String)session.getAttribute("email");

                            String sql = "SELECT * FROM users WHERE email = " + " '"+currentEmail+"'  ";

                            PreparedStatement findUser = conn.prepareStatement(sql);


                            ResultSet findUserRESULT = findUser.executeQuery();
                            findUserRESULT.next();

                            out.println("<strong>" + findUserRESULT.getString("nume") + " " + findUserRESULT.getString("prenume") + " - " + session.getAttribute("accountType") + "</strong>");
                        }

                        if(session.getAttribute("accountType") == "author")
                        {

                            String currentEmail = (String)session.getAttribute("email");

                            String sql = "SELECT * FROM authors WHERE email = " + " '"+currentEmail+"'  ";

                            PreparedStatement findAuthor = conn.prepareStatement(sql);


                            ResultSet findAuthorRESULT = findAuthor.executeQuery();
                            findAuthorRESULT.next();

                            out.println("<strong>" + findAuthorRESULT.getString("surname") + " " + findAuthorRESULT.getString("name") + " - " + session.getAttribute("accountType") + "</strong>");
                        }





                    %>

                    <span class="sr-only">(current)</span></a>
            </li>


            <% if(session.getAttribute("accountType") == "author"){ %>
            <li class="nav-item mx-3">
                <a class="nav-link" href="logout.jsp">Logout <span class="sr-only">(current)</span></a>
            </li>
            <% } %>
        </ul>
    </div>
</nav>



<div class="container mt-5">

    <p class="h3 my-5 text-center">Add draft</p>

    <form action="add_draft.jsp" method="post">
        <div class="form-group">

            <input name="title" type="text" class="form-control" id="exampleFormControlInput12" placeholder="News title" required>
        </div>
        <div class="form-group">
            <label for="exampleFormControlSelect1">Select category</label>
            <select name="category" class="form-control" id="exampleFormControlSelect1">

                <%

                    PreparedStatement categoryName = conn.prepareStatement("SELECT category_name FROM categories WHERE category_availability = 1");
                    ResultSet categoryNameRESULT = categoryName.executeQuery();

                    while(categoryNameRESULT.next())
                    {
                        out.println("<option>" + categoryNameRESULT.getString("category_name") + "</option>");
                    }


                %>

            </select>
        </div>

        <div class="form-group">

            <textarea name="content" class="form-control" id="exampleFormControlTextarea1" rows="5" cols="20" placeholder="News content" required></textarea>
        </div>

        <div class="form-group">

            <input name="url" type="text" class="form-control" id="exampleFormControlInput1" placeholder="Image URL">
        </div>

        <div class="text-center mt-5">
            <button type="submit" name = "submit" class="btn bg-main text-white mx-auto w-50">Post draft</button>
        </div>
    </form>

</div>

</body>
</html>


<%
    if("POST".equals(request.getMethod())) {

        conn.setAutoCommit(true);

        String title = request.getParameter("title");
        String category = request.getParameter("category");
        String content = request.getParameter("content");
        String url = request.getParameter("url");

        // Get category ID
        PreparedStatement idcategory = conn.prepareStatement("SELECT category_id FROM categories WHERE category_name = ?");
        idcategory.setString(1, category);
        ResultSet idcategoryRESULT = idcategory.executeQuery();
        if (idcategoryRESULT.isBeforeFirst()) {
            idcategoryRESULT.next();
            int idCat = idcategoryRESULT.getInt(1);
            if (title != null) {
                // Add image to dmultimedia table
                PreparedStatement addImage = conn.prepareStatement("INSERT INTO dmultimedia(durl, dtype) VALUES (?, 'image')");
                addImage.setString(1, url);
                int addImageRESULT = addImage.executeUpdate();

                // Get last inserted image ID
                PreparedStatement idMultimedia = conn.prepareStatement("SELECT dmultimedia_id FROM dmultimedia ORDER BY dmultimedia_id DESC LIMIT 1");
                ResultSet idMultimediaRESULT = idMultimedia.executeQuery();
                idMultimediaRESULT.next();
                int idMultimediaNecessary = idMultimediaRESULT.getInt(1);

// Insert a new draft
                PreparedStatement insertDraft = conn.prepareStatement("INSERT INTO draft(draft_title, category_id, draft_content, last_edited_on, date_of_submission) VALUES (?, ?, ?, ?, ?)", Statement.RETURN_GENERATED_KEYS);
                insertDraft.setString(1, title);
                insertDraft.setInt(2, idCat);
                insertDraft.setString(3, content);
                insertDraft.setTimestamp(4, new java.sql.Timestamp(System.currentTimeMillis()));
                insertDraft.setTimestamp(5, new java.sql.Timestamp(System.currentTimeMillis()));
                insertDraft.executeUpdate();

// Get the auto-generated draft_id value
                ResultSet generatedKeys = insertDraft.getGeneratedKeys();
                int draftId = 0;
                if (generatedKeys.next()) {
                    draftId = generatedKeys.getInt(1);
                }

// Add news
                PreparedStatement addNews = conn.prepareStatement("INSERT INTO news(draft_id, news_title, category_id, news_content, news_posted_on, news_availability, is_draft) VALUES(?, ?, ?, ?, ?, 1, 1)");

                addNews.setInt(1, draftId);
                addNews.setString(2, title);
                addNews.setInt(3, idCat);
                addNews.setString(4, content);
                addNews.setTimestamp(5, new java.sql.Timestamp(System.currentTimeMillis()));

                int addNewsRESULT = addNews.executeUpdate();


                // Get last inserted news ID
                PreparedStatement newsId = conn.prepareStatement("SELECT news_id FROM news ORDER BY news_id DESC LIMIT 1");
                ResultSet newsIdRESULT = newsId.executeQuery();
                newsIdRESULT.next();
                int newsIdNecessary = newsIdRESULT.getInt(1);

                PreparedStatement multimedia_news = conn.prepareStatement("INSERT INTO draft_dmultimedia(draft_id, dmultimedia_id) VALUES(?, ?)");
                multimedia_news.setInt(1, draftId); // Use draftId instead of newsIdNecessary
                multimedia_news.setInt(2, idMultimediaNecessary);

                int multimedia_newsRESULT = multimedia_news.executeUpdate();

                // Assuming you have the author_id available in the session
                int authorId = (Integer) session.getAttribute("id");

                // Add relationship to draft_authors table
                PreparedStatement author_news = conn.prepareStatement("INSERT INTO draft_authors(author_id, draft_id, contribution_level, access_key) VALUES (?, ?, ?, ?)");
                author_news.setInt(1, authorId);
                author_news.setInt(2, draftId); // Use draftId instead of newsIdNecessary
                author_news.setString(3, "Full"); // Assuming full contribution level
                author_news.setString(4, "some_access_key"); // Assuming you have some access key

                int author_newsRESULT = author_news.executeUpdate();

                response.sendRedirect("News.jsp");
            }
        }
    }

%>
