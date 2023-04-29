<%@include file="displayComments.jsp"%>





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
