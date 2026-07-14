package com.vehicleservice.dao;

import com.vehicleservice.config.DBConnection;
import com.vehicleservice.model.Document;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DocumentDAO {

    public boolean uploadDocument(Document doc) {
        // Delete previous document of same type for the same target to avoid duplicates
        deletePreviousDoc(doc);

        String sql = "INSERT INTO documents (user_id, vehicle_id, document_type, file_name, file_path, file_size, expiry_date) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            if (doc.getUserId() != null) {
                stmt.setInt(1, doc.getUserId());
            } else {
                stmt.setNull(1, Types.INTEGER);
            }
            
            if (doc.getVehicleId() != null) {
                stmt.setInt(2, doc.getVehicleId());
            } else {
                stmt.setNull(2, Types.INTEGER);
            }
            
            stmt.setString(3, doc.getDocumentType());
            stmt.setString(4, doc.getFileName());
            stmt.setString(5, doc.getFilePath());
            stmt.setLong(6, doc.getFileSize());
            stmt.setDate(7, doc.getExpiryDate());
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private void deletePreviousDoc(Document doc) {
        String sql;
        if (doc.getVehicleId() != null) {
            sql = "DELETE FROM documents WHERE vehicle_id = ? AND document_type = ?";
        } else {
            sql = "DELETE FROM documents WHERE user_id = ? AND document_type = ?";
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            if (doc.getVehicleId() != null) {
                stmt.setInt(1, doc.getVehicleId());
            } else {
                stmt.setInt(1, doc.getUserId());
            }
            stmt.setString(2, doc.getDocumentType());
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<Document> getDocumentsByUser(int userId) {
        List<Document> list = new ArrayList<>();
        String sql = "SELECT * FROM documents WHERE user_id = ? ORDER BY id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(extractDocumentFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Document> getDocumentsByVehicle(int vehicleId) {
        List<Document> list = new ArrayList<>();
        String sql = "SELECT * FROM documents WHERE vehicle_id = ? ORDER BY id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, vehicleId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(extractDocumentFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Document getDocumentById(int id) {
        String sql = "SELECT * FROM documents WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return extractDocumentFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public Document getDocumentByTypeAndVehicle(String type, int vehicleId) {
        String sql = "SELECT * FROM documents WHERE vehicle_id = ? AND document_type = ? LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, vehicleId);
            stmt.setString(2, type);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return extractDocumentFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public Document getDocumentByTypeAndUser(String type, int userId) {
        String sql = "SELECT * FROM documents WHERE user_id = ? AND document_type = ? LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            stmt.setString(2, type);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return extractDocumentFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean deleteDocument(int id) {
        String sql = "DELETE FROM documents WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private Document extractDocumentFromResultSet(ResultSet rs) throws SQLException {
        Document doc = new Document();
        doc.setId(rs.getInt("id"));
        int userId = rs.getInt("user_id");
        doc.setUserId(rs.wasNull() ? null : userId);
        int vehicleId = rs.getInt("vehicle_id");
        doc.setVehicleId(rs.wasNull() ? null : vehicleId);
        doc.setDocumentType(rs.getString("document_type"));
        doc.setFileName(rs.getString("file_name"));
        doc.setFilePath(rs.getString("file_path"));
        doc.setFileSize(rs.getLong("file_size"));
        doc.setExpiryDate(rs.getDate("expiry_date"));
        doc.setUploadedAt(rs.getTimestamp("uploaded_at"));
        return doc;
    }
}
