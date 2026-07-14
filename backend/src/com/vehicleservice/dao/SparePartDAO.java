package com.vehicleservice.dao;

import com.vehicleservice.config.DBConnection;
import com.vehicleservice.model.SparePart;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SparePartDAO {

    public List<SparePart> getAllParts() {
        List<SparePart> list = new ArrayList<>();
        String sql = "SELECT * FROM spare_parts ORDER BY id DESC";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                list.add(extractPartFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public SparePart getPartById(int id) {
        String sql = "SELECT * FROM spare_parts WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return extractPartFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean addPart(SparePart part) {
        String sql = "INSERT INTO spare_parts (name, cost, quantity) VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, part.getName());
            stmt.setDouble(2, part.getCost());
            stmt.setInt(3, part.getQuantity());
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updatePart(SparePart part) {
        String sql = "UPDATE spare_parts SET name = ?, cost = ?, quantity = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, part.getName());
            stmt.setDouble(2, part.getCost());
            stmt.setInt(3, part.getQuantity());
            stmt.setInt(4, part.getId());
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deletePart(int id) {
        String sql = "DELETE FROM spare_parts WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Associates a spare part with a booking and updates spare parts stock in a single transaction.
     */
    public boolean addPartToBooking(int bookingId, int partId, int quantity) {
        String insertSql = "INSERT INTO booking_parts (booking_id, part_id, quantity) VALUES (?, ?, ?) " +
                           "ON DUPLICATE KEY UPDATE quantity = quantity + ?";
        String updateStockSql = "UPDATE spare_parts SET quantity = quantity - ? WHERE id = ? AND quantity >= ?";
        
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Begin Transaction

            // 1. Deduct Stock
            try (PreparedStatement updateStmt = conn.prepareStatement(updateStockSql)) {
                updateStmt.setInt(1, quantity);
                updateStmt.setInt(2, partId);
                updateStmt.setInt(3, quantity);
                int stockRows = updateStmt.executeUpdate();
                if (stockRows == 0) {
                    conn.rollback();
                    return false; // Insufficient stock
                }
            }

            // 2. Associate with booking
            try (PreparedStatement insertStmt = conn.prepareStatement(insertSql)) {
                insertStmt.setInt(1, bookingId);
                insertStmt.setInt(2, partId);
                insertStmt.setInt(3, quantity);
                insertStmt.setInt(4, quantity);
                insertStmt.executeUpdate();
            }

            conn.commit(); // Commit Transaction
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
        return false;
    }

    /**
     * Gets a list of spare parts used in a specific booking.
     */
    public List<SparePart> getPartsForBooking(int bookingId) {
        List<SparePart> list = new ArrayList<>();
        String sql = "SELECT sp.*, bp.quantity as used_qty FROM spare_parts sp " +
                     "JOIN booking_parts bp ON sp.id = bp.part_id WHERE bp.booking_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, bookingId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    SparePart part = new SparePart();
                    part.setId(rs.getInt("id"));
                    part.setName(rs.getString("name"));
                    part.setCost(rs.getDouble("cost"));
                    part.setQuantity(rs.getInt("used_qty")); // Hijacking quantity field to return amount used
                    list.add(part);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private SparePart extractPartFromResultSet(ResultSet rs) throws SQLException {
        SparePart part = new SparePart();
        part.setId(rs.getInt("id"));
        part.setName(rs.getString("name"));
        part.setCost(rs.getDouble("cost"));
        part.setQuantity(rs.getInt("quantity"));
        return part;
    }
}
