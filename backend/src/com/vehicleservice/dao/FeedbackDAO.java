package com.vehicleservice.dao;

import com.vehicleservice.config.DBConnection;
import com.vehicleservice.model.Feedback;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class FeedbackDAO {

    public boolean addFeedback(Feedback fb) {
        String sql = "INSERT INTO feedback_complaints (user_id, booking_id, type, message, rating, status) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, fb.getUserId());
            if (fb.getBookingId() != null) {
                stmt.setInt(2, fb.getBookingId());
            } else {
                stmt.setNull(2, Types.INTEGER);
            }
            stmt.setString(3, fb.getType());
            stmt.setString(4, fb.getMessage());
            if (fb.getRating() != null) {
                stmt.setInt(5, fb.getRating());
            } else {
                stmt.setNull(5, Types.INTEGER);
            }
            stmt.setString(6, fb.getStatus() == null ? "OPEN" : fb.getStatus());
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Feedback> getFeedbackByUser(int userId) {
        List<Feedback> list = new ArrayList<>();
        String sql = "SELECT fb.*, sp.name as pkg_name FROM feedback_complaints fb " +
                     "LEFT JOIN bookings b ON fb.booking_id = b.id " +
                     "LEFT JOIN service_packages sp ON b.package_id = sp.id " +
                     "WHERE fb.user_id = ? ORDER BY fb.id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(extractFeedbackFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Feedback> getAllFeedback() {
        List<Feedback> list = new ArrayList<>();
        String sql = "SELECT fb.*, u.name as cust_name, sp.name as pkg_name FROM feedback_complaints fb " +
                     "JOIN users u ON fb.user_id = u.id " +
                     "LEFT JOIN bookings b ON fb.booking_id = b.id " +
                     "LEFT JOIN service_packages sp ON b.package_id = sp.id " +
                     "ORDER BY fb.id DESC";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Feedback fb = extractFeedbackFromResultSet(rs);
                fb.setCustomerName(rs.getString("cust_name"));
                list.add(fb);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateStatus(int id, String status) {
        String sql = "UPDATE feedback_complaints SET status = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, status);
            stmt.setInt(2, id);
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteFeedback(int id) {
        String sql = "DELETE FROM feedback_complaints WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private Feedback extractFeedbackFromResultSet(ResultSet rs) throws SQLException {
        Feedback fb = new Feedback();
        fb.setId(rs.getInt("id"));
        fb.setUserId(rs.getInt("user_id"));
        int bookingId = rs.getInt("booking_id");
        fb.setBookingId(rs.wasNull() ? null : bookingId);
        fb.setType(rs.getString("type"));
        fb.setMessage(rs.getString("message"));
        int rating = rs.getInt("rating");
        fb.setRating(rs.wasNull() ? null : rating);
        fb.setStatus(rs.getString("status"));
        fb.setCreatedAt(rs.getTimestamp("created_at"));
        
        // Join field
        fb.setPackageName(rs.getString("pkg_name"));
        return fb;
    }
}
