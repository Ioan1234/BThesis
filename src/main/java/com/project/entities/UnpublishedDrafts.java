package com.project.entities;

import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.Map;

public class UnpublishedDrafts {
    private int authorId;

    public void setAuthorId(int authorId) {
        this.authorId = authorId;
    }

    public int getAuthorId() {
        return authorId;
    }
    public ArrayList<Draft> getUnpublishedDrafts() throws SQLException {
        Connection conn = Connections.getConnection();

        String sql = "SELECT draft.draft_id, draft_title, last_edited_on, category_id " +
                "FROM draft " +
                "JOIN draft_authors ON draft.draft_id = draft_authors.draft_id " +
                "WHERE draft_authors.author_id = ? AND draft.draft_id NOT IN (SELECT news.draft_id FROM news WHERE is_draft = 1)";
        PreparedStatement getUnpublishedDrafts = conn.prepareStatement(sql);
        getUnpublishedDrafts.setInt(1, this.authorId); // Use authorId in your query
        ResultSet getUnpublishedDraftsRESULT = getUnpublishedDrafts.executeQuery();

        ArrayList<Draft> unpublishedDrafts = new ArrayList<Draft>();

        while(getUnpublishedDraftsRESULT.next()){
            int draftId = getUnpublishedDraftsRESULT.getInt("draft_id");
            String draftTitle = getUnpublishedDraftsRESULT.getString("draft_title");
            Timestamp lastEditedOn = getUnpublishedDraftsRESULT.getTimestamp("last_edited_on");
            int categoryId = getUnpublishedDraftsRESULT.getInt("category_id");

            Draft draftObj = new Draft(draftId, draftTitle, categoryId, lastEditedOn, false);
            unpublishedDrafts.add(draftObj);
        }

        return unpublishedDrafts;
    }


    public Map<String, ArrayList<Draft>> getCategorizedUnpublishedDrafts() throws SQLException {
        Connection conn = Connections.getConnection();
        Map<String, ArrayList<Draft>> categorizedUnpublishedDrafts = new LinkedHashMap<>();
        ArrayList<Draft> unpublishedDrafts = this.getUnpublishedDrafts();

        for (Draft draft : unpublishedDrafts) {
            String sql = "SELECT category_name FROM categories WHERE category_availability=1 AND category_id = " + draft.getCategoryId();
            PreparedStatement stmt = conn.prepareStatement(sql);
            ResultSet resultSet = stmt.executeQuery();

            if (resultSet.next()) {
                String category = resultSet.getString(1);
                categorizedUnpublishedDrafts.putIfAbsent(category, new ArrayList<>());
                categorizedUnpublishedDrafts.get(category).add(draft);
            }
        }

        return categorizedUnpublishedDrafts;
    }
    public Map<String, ArrayList<Draft>> getArchivedCategoriesDrafts() throws SQLException {
        Connection conn = Connections.getConnection();
        Map<String, ArrayList<Draft>> archivedCategoriesDrafts = new LinkedHashMap<>();
        ArrayList<Draft> unpublishedDrafts = this.getUnpublishedDrafts();

        for (Draft draft : unpublishedDrafts) {
            String sql = "SELECT category_name FROM categories WHERE category_availability=0 AND category_id = " + draft.getCategoryId();
            PreparedStatement stmt = conn.prepareStatement(sql);
            ResultSet resultSet = stmt.executeQuery();

            if (resultSet.next()) {
                String category = resultSet.getString(1);
                archivedCategoriesDrafts.putIfAbsent(category, new ArrayList<>());
                archivedCategoriesDrafts.get(category).add(draft);
            }
        }

        return archivedCategoriesDrafts;
    }



}
