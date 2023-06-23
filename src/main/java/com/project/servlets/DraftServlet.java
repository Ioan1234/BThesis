package com.project.servlets;

import com.project.entities.DatabaseConnector;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.InputStream;
import java.sql.*;

@WebServlet("/draft")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 50, // 2MB
        maxFileSize = 1024 * 1024 * 50,      // 10MB
        maxRequestSize = 1024 * 1024 * 500)   // 50MB
public class DraftServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        // Fetch the session from the request
        HttpSession session = request.getSession();
        String draftIdParam = request.getParameter("draft_id");

        if ("GET".equalsIgnoreCase(request.getMethod()) && draftIdParam != null) {
            int draftId = Integer.parseInt(draftIdParam);
            System.out.println("Draft ID: " + draftId);
            // Use try-with-resources to automatically close resources
            try (Connection conn = DatabaseConnector.getConnection()) {
                String title = "";
                String category = "";
                String content = "";

                PreparedStatement draftStmt = conn.prepareStatement(
                        "SELECT draft_title, category_id, draft_content " +
                                "FROM draft " +
                                "WHERE draft_id = ?"
                );
                draftStmt.setInt(1, draftId);

                // Use try-with-resources to automatically close ResultSet
                try (ResultSet draftRs = draftStmt.executeQuery()) {
                    if (draftRs.next()) {
                        title = draftRs.getString("draft_title");
                        content = draftRs.getString("draft_content");

                        int categoryId = draftRs.getInt("category_id");
                        PreparedStatement categoryStmt = conn.prepareStatement(
                                "SELECT category_name " +
                                        "FROM categories " +
                                        "WHERE category_id = ?"
                        );
                        categoryStmt.setInt(1, categoryId);

                        // Use try-with-resources to automatically close ResultSet
                        try (ResultSet categoryRs = categoryStmt.executeQuery()) {
                            if (categoryRs.next()) {
                                category = categoryRs.getString("category_name");
                            }
                        }
                    }
                    request.setAttribute("draftId", draftId);
                    // Store data in request attributes
                    request.setAttribute("category", category);
                    request.setAttribute("draft_title", title);
                    request.setAttribute("draft_content", content);

                    request.getRequestDispatcher("/add_draft.jsp").forward(request, response);
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
                throw new ServletException("Error accessing database", ex);
            }
        }
    }


    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Fetch the session from the request
        HttpSession session = request.getSession();

        // Fetch the database connection
        Connection conn = DatabaseConnector.getConnection();

        // Other parameters
        String title = request.getParameter("draft_title");
        String category = request.getParameter("category");
        String content = request.getParameter("draft_content");
        System.out.println("Draft id: " + request.getParameter("draft_id"));


        // URL parameter is assumed to be the local path of the image
        Part filePart = request.getPart("image"); // Retrieves <input type="file" name="url">

        InputStream inputStream = null;
        if (filePart != null) {
            // Gets the input stream of the upload file
            inputStream = filePart.getInputStream();
        }

        // Start transaction
        try {
            conn.setAutoCommit(false);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        System.out.println("Auto-commit set to false"); // Debug line

        PreparedStatement idcategory = null;
        try {
            idcategory = conn.prepareStatement("SELECT category_id FROM categories WHERE category_name = ?");
            if(idcategory != null){
                System.out.println("PreparedStatement idcategory created successfully"); // Debug line
            } else {
                System.out.println("PreparedStatement idcategory is null"); // Debug line
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }


        try {
            idcategory.setString(1, category);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }


        ResultSet idcategoryRESULT = null;
        try {
            idcategoryRESULT = idcategory.executeQuery();
            if(idcategoryRESULT != null){
                System.out.println("ResultSet idcategoryRESULT created successfully"); // Debug line
            } else {
                System.out.println("ResultSet idcategoryRESULT is null"); // Debug line
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }


        try {
            if (idcategoryRESULT.isBeforeFirst()) {
                idcategoryRESULT.next();
                int idCat = idcategoryRESULT.getInt(1);
                System.out.println("Fetched category id: " + idCat); // Debug line

                if (title != null) {
                        // Add image to dmultimedia table
                    int idMultimediaNecessary = 0;

                        if (filePart.getSize()==0) {
                            //PreparedStatement addImage = conn.prepareStatement("INSERT INTO dmultimedia(dmm, dtype) VALUES (?, 'image')");
                            // Store binary stream in dmm column
                            //addImage.setBinaryStream(1, inputStream, (int) filePart.getSize());
                            //int addImageRESULT = addImage.executeUpdate();
                            PreparedStatement idMultimedia = conn.prepareStatement("SELECT dmultimedia_id FROM dmultimedia ORDER BY dmultimedia_id DESC LIMIT 1");
                            ResultSet idMultimediaRESULT = idMultimedia.executeQuery();
                            idMultimediaRESULT.next();
                            idMultimediaNecessary = idMultimediaRESULT.getInt(1);
                            conn.commit();
                        }
                        int draftId=0;

                    boolean isNewDraft = false;
                        PreparedStatement insertOrUpdateDraft=null;
                    if (request.getParameter("draft_id")!= null) {
                        System.out.println("Draft is being updated");
                        String dd= request.getParameter("draft_id");
                       draftId = Integer.parseInt(dd);
                       try {
                           insertOrUpdateDraft = conn.prepareStatement(
                                   "UPDATE draft SET draft_title = ?, category_id = ?, draft_content = ?, last_edited_on = ? WHERE draft_id = ?"
                           );
                           insertOrUpdateDraft.setString(1, title);
                           insertOrUpdateDraft.setInt(2, idCat);
                           insertOrUpdateDraft.setString(3, content);
                           insertOrUpdateDraft.setTimestamp(4, new java.sql.Timestamp(System.currentTimeMillis()));
                           insertOrUpdateDraft.setInt(5, draftId);
                           int affectedRows = insertOrUpdateDraft.executeUpdate();
                           conn.commit();

                           if (affectedRows == 0) {
                               throw new SQLException("Updating draft failed, no rows affected.");
                           }
                       } catch (SQLException e) {
                           e.printStackTrace();
                           System.out.println("Error in update draft");
                       }
                    } else {
                        // A new draft is being created, insert it
                        isNewDraft = true;
                        System.out.println("New draft is being created");

                        insertOrUpdateDraft = conn.prepareStatement(
                                "INSERT INTO draft(draft_title, category_id, draft_content, last_edited_on) VALUES (?, ?, ?, ?)",
                                Statement.RETURN_GENERATED_KEYS
                        );

                        insertOrUpdateDraft.setString(1, title);
                        insertOrUpdateDraft.setInt(2, idCat);
                        insertOrUpdateDraft.setString(3, content);
                        insertOrUpdateDraft.setTimestamp(4, new java.sql.Timestamp(System.currentTimeMillis()));

                        int affectedRows = insertOrUpdateDraft.executeUpdate();
                        conn.commit();

                        if (affectedRows == 0) {
                            throw new SQLException("Creating draft failed, no rows affected.");
                        }

                    }

                    // Get the auto-generated draft_id value only for new draft
                    if (isNewDraft) {
                        ResultSet generatedKeys = insertOrUpdateDraft.getGeneratedKeys();
                        if (generatedKeys.next()) {
                            draftId = generatedKeys.getInt(1);
                            session.setAttribute("draft_id", draftId);
                            System.out.println("Draft ID: " + draftId); // Debug line
                            System.out.println("inputStream is: " + (inputStream == null ? "null" : "not null"));
                            // If an image is uploaded, add the image and its relationship


                            // Add relationship to draft_authors table
                            try {
                                int authorId = (Integer) session.getAttribute("id");
                                PreparedStatement author_draft = conn.prepareStatement("INSERT INTO draft_authors(author_id, draft_id) VALUES (?, ?)");
                                author_draft.setInt(1, authorId);
                                author_draft.setInt(2, draftId);
                                int author_draftRESULT = author_draft.executeUpdate();
                                conn.commit();
                            } catch (SQLException e) {
                                e.printStackTrace();
                                System.out.println("Error in adding draft_authors");
                            }
                        } else {
                            throw new SQLException("Creating draft failed, no ID obtained.");
                        }
                    }

                    if (draftId != 0) {
                            System.out.println("Draft ID:    " + draftId); // Debug line
                            System.out.println("Save Draft button value: " + request.getParameter("saveDraft"));
                            System.out.println("Publish Draft button value: " + request.getParameter("postDraft"));
                            System.out.println("Delete Draft button value: " + request.getParameter("deleteDraft"));
                            //System.out.println("Remove Image button value: " + request.getParameter("removeImage"));

                            if (request.getParameter("deleteDraft") != null) {
                                // Fetch the draftId from session or from the request
                                draftId = request.getParameter("draft_id") != null ?
                                        Integer.parseInt(request.getParameter("draft_id")) :
                                        (Integer) session.getAttribute("draft_id");

                                // Delete all image relationships associated with this draft
                                try (PreparedStatement deleteDraftMultimedia = conn.prepareStatement(
                                        "DELETE FROM draft_dmultimedia WHERE draft_id = ?")) {
                                    deleteDraftMultimedia.setInt(1, draftId);
                                    deleteDraftMultimedia.executeUpdate();
                                    conn.commit();
                                } catch (SQLException e) {
                                    e.printStackTrace();
                                    System.out.println("Error in deleting draft_dmultimedia relationship");
                                }
                                // Delete draft action
                                PreparedStatement deleteDraftMultimedia = conn.prepareStatement("DELETE FROM draft_dmultimedia WHERE draft_id = ?");
                                deleteDraftMultimedia.setInt(1, draftId);
                                deleteDraftMultimedia.executeUpdate();
                                conn.commit();

                                PreparedStatement deleteDraftAuthors = conn.prepareStatement("DELETE FROM draft_authors WHERE draft_id = ?");
                                deleteDraftAuthors.setInt(1, draftId);
                                deleteDraftAuthors.executeUpdate();
                                conn.commit();

                                PreparedStatement deleteDraft = conn.prepareStatement("DELETE FROM draft WHERE draft_id = ?");
                                deleteDraft.setInt(1, draftId);
                                deleteDraft.executeUpdate();
                                conn.commit();

                                int authorId = (Integer) session.getAttribute("id");
                                response.sendRedirect("authorProfile.jsp?author_id=" + authorId);
                                return;
                            } else if (request.getParameter("saveDraft") != null) {
                                if(request.getParameter("draft_id") != null) {
                                    String dd = request.getParameter("draft_id");
                                    draftId = Integer.parseInt(dd);
                                } else {
                                    draftId = (Integer) session.getAttribute("draft_id");
                                }

                                System.out.println("saveDraft");
                                // Save draft action, save as draft and don't publish
                                int authorId = (Integer) session.getAttribute("id");
                                // Check if the relationship already exists
                                PreparedStatement checkAuthorDraft = conn.prepareStatement("SELECT * FROM draft_authors WHERE author_id = ? AND draft_id = ?");
                                checkAuthorDraft.setInt(1, authorId);
                                checkAuthorDraft.setInt(2, draftId);
                                ResultSet checkAuthorDraftResult = checkAuthorDraft.executeQuery();
                                conn.commit();

                                // Only add relationship to draft_authors table if it doesn't exist
                                if (!checkAuthorDraftResult.next()) {
                                    PreparedStatement author_draft = conn.prepareStatement("INSERT INTO draft_authors(author_id, draft_id) VALUES (?, ?)");
                                    author_draft.setInt(1, authorId);
                                    author_draft.setInt(2, draftId);
                                    int author_draftRESULT = author_draft.executeUpdate();
                                    conn.commit();
                                }
                                if (inputStream != null&&filePart.getSize()!=0) {
                                    // Add new image to dmultimedia
                                    try {
                                        PreparedStatement addImage = conn.prepareStatement(
                                                "INSERT INTO dmultimedia(dmm) VALUES (?)", Statement.RETURN_GENERATED_KEYS);
                                        addImage.setBinaryStream(1, inputStream, (int) filePart.getSize());
                                        addImage.executeUpdate();

                                        try (ResultSet imageKeys = addImage.getGeneratedKeys()) {
                                            if (imageKeys.next()) {
                                                idMultimediaNecessary = imageKeys.getInt(1);
                                            } else {
                                                throw new SQLException("Creating image failed, no ID obtained.");
                                            }
                                        }
                                        conn.commit();
                                    } catch (SQLException e) {
                                        e.printStackTrace();
                                        System.out.println("Error in adding new image to dmultimedia");
                                    }

                                    // Delete the old image relationship
                                    try (PreparedStatement deleteOldImage = conn.prepareStatement(
                                            "DELETE FROM draft_dmultimedia WHERE draft_id = ?")) {
                                        deleteOldImage.setInt(1, draftId);
                                        deleteOldImage.executeUpdate();
                                        conn.commit();
                                    } catch (SQLException e) {
                                        e.printStackTrace();
                                        System.out.println("Error in deleting old image relationship");
                                    }

                                    // Add new image relationship
                                    try {
                                        PreparedStatement addImageRelationship = conn.prepareStatement(
                                                "INSERT INTO draft_dmultimedia(draft_id, dmultimedia_id) VALUES (?, ?)");
                                        addImageRelationship.setInt(1, draftId);
                                        addImageRelationship.setInt(2, idMultimediaNecessary);
                                        addImageRelationship.executeUpdate();
                                        conn.commit();
                                    } catch (SQLException e) {
                                        e.printStackTrace();
                                        System.out.println("Error in adding new image relationship");
                                    }
                                }
                                response.sendRedirect("authorProfile.jsp?author_id=" + authorId);
                                return;
                            }

                            // Redirect to the same page to continue editing the draft
                            else if (request.getParameter("postDraft") != null) {
                                if(request.getParameter("draft_id") != null) {
                                    String dd = request.getParameter("draft_id");
                                    draftId = Integer.parseInt(dd);
                                } else {
                                    draftId = (Integer) session.getAttribute("draft_id");
                                }

                                System.out.println("postDraft");
                                if (filePart.getSize()!=0) {
                                    // Add new image to dmultimedia
                                    try {
                                        PreparedStatement addImage = conn.prepareStatement(
                                                "INSERT INTO dmultimedia(dmm) VALUES (?)", Statement.RETURN_GENERATED_KEYS);
                                        addImage.setBinaryStream(1, inputStream, (int) filePart.getSize());
                                        addImage.executeUpdate();

                                        try (ResultSet imageKeys = addImage.getGeneratedKeys()) {
                                            if (imageKeys.next()) {
                                                idMultimediaNecessary = imageKeys.getInt(1);
                                            } else {
                                                throw new SQLException("Creating image failed, no ID obtained.");
                                            }
                                        }
                                        conn.commit();
                                    } catch (SQLException e) {
                                        e.printStackTrace();
                                        System.out.println("Error in adding new image to dmultimedia");
                                    }

                                    // Delete the old image relationship
                                    try (PreparedStatement deleteOldImage = conn.prepareStatement(
                                            "DELETE FROM draft_dmultimedia WHERE draft_id = ?")) {
                                        deleteOldImage.setInt(1, draftId);
                                        deleteOldImage.executeUpdate();
                                        conn.commit();
                                    } catch (SQLException e) {
                                        e.printStackTrace();
                                        System.out.println("Error in deleting old image relationship");
                                    }

                                    // Add new image relationship
                                    try {
                                        PreparedStatement addImageRelationship = conn.prepareStatement(
                                                "INSERT INTO draft_dmultimedia(draft_id, dmultimedia_id) VALUES (?, ?)");
                                        addImageRelationship.setInt(1, draftId);
                                        addImageRelationship.setInt(2, idMultimediaNecessary);
                                        addImageRelationship.executeUpdate();
                                        conn.commit();
                                    } catch (SQLException e) {
                                        e.printStackTrace();
                                        System.out.println("Error in adding new image relationship");
                                    }
                                }


                                try {
                                    PreparedStatement updateSubmissionDate = conn.prepareStatement("UPDATE draft SET date_of_submission = ? WHERE draft_id = ?");
                                    updateSubmissionDate.setTimestamp(1, new java.sql.Timestamp(System.currentTimeMillis()));
                                    updateSubmissionDate.setInt(2,draftId);
                                    updateSubmissionDate.executeUpdate();
                                    conn.commit();
                                } catch (SQLException e) {
                                    e.printStackTrace();
                                    System.out.println("Error in updating date_of_submission");
                                }

                                // Reset the draft_id session attribute as it's now published


                                try {
                                    PreparedStatement addNews = conn.prepareStatement("INSERT INTO news(draft_id, news_title, category_id, news_content, news_posted_on, news_availability, is_draft) VALUES(?, ?, ?, ?, ?, 1, 1)");

                                    addNews.setInt(1, draftId);
                                    addNews.setString(2, title);
                                    addNews.setInt(3, idCat);
                                    addNews.setString(4, content);
                                    addNews.setTimestamp(5, new java.sql.Timestamp(System.currentTimeMillis()));

                                    int addNewsRESULT = addNews.executeUpdate();
                                    conn.commit();
                                }catch (SQLException e) {
                                    e.printStackTrace();
                                    System.out.println("Error in adding news");
                                }

                                try {
                                    // Get last inserted news ID
                                    PreparedStatement newsId = conn.prepareStatement("SELECT news_id FROM news ORDER BY news_id DESC LIMIT 1");
                                    ResultSet newsIdRESULT = newsId.executeQuery();
                                    newsIdRESULT.next();
                                    int newsIdNecessary = newsIdRESULT.getInt(1);
                                    conn.commit();
                                } catch (SQLException e) {
                                    e.printStackTrace();
                                    System.out.println("Error in getting news_id");
                                }
                                try {
                                    // Assuming you have the author_id available in the session
                                    int authorId = (Integer) session.getAttribute("id");

                                    // Check if the relationship already exists
                                    PreparedStatement checkAuthorDraft = conn.prepareStatement("SELECT * FROM draft_authors WHERE author_id = ? AND draft_id = ?");
                                    checkAuthorDraft.setInt(1, authorId);
                                    checkAuthorDraft.setInt(2, draftId);
                                    ResultSet checkAuthorDraftResult = checkAuthorDraft.executeQuery();
                                    if (!checkAuthorDraftResult.next()) {
                                        PreparedStatement author_draft = conn.prepareStatement("INSERT INTO draft_authors(author_id, draft_id) VALUES (?, ?)");
                                        author_draft.setInt(1, authorId);
                                        author_draft.setInt(2, draftId);
                                        int author_draftRESULT = author_draft.executeUpdate();
                                        conn.commit();
                                    }
                                } catch (SQLException e) {
                                    e.printStackTrace();
                                    System.out.println("Error in adding author_draft");
                                }
                                // Only add relationship to draft_authors table if it doesn't exist

                                session.removeAttribute("draft_id");
                                response.sendRedirect("News.jsp");
                                return;
                            }
                        }

                } else {
                            System.out.println("Draft was not inserted or updated correctly!");
                        }
                        conn.commit();
                    }

                    } catch (SQLException ex) {
            ex.printStackTrace();
        }
    }
    }

