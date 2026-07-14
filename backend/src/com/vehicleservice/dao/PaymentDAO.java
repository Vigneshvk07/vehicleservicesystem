package com.vehicleservice.dao;

import com.vehicleservice.config.DBConnection;
import com.vehicleservice.model.Payment;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PaymentDAO {

    public boolean addPayment(Payment payment) {
        String sql = "INSERT INTO payments (invoice_id, payment_method, payment_status, transaction_id, payment_amount) VALUES (?, ?, ?, ?, ?)";
        
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Begin Transaction

            // 1. Insert payment record
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, payment.getInvoiceId());
                stmt.setString(2, payment.getPaymentMethod());
                stmt.setString(3, payment.getPaymentStatus());
                stmt.setString(4, payment.getTransactionId());
                stmt.setDouble(5, payment.getPaymentAmount());
                stmt.executeUpdate();
            }

            // 2. If payment is successful, mark invoice as PAID
            if ("PAID".equalsIgnoreCase(payment.getPaymentStatus())) {
                String updateInvoiceSql = "UPDATE invoices SET payment_status = 'PAID' WHERE id = ?";
                try (PreparedStatement uStmt = conn.prepareStatement(updateInvoiceSql)) {
                    uStmt.setInt(1, payment.getInvoiceId());
                    uStmt.executeUpdate();
                }

                // Award loyalty points to customer (10% of total amount as points)
                String findUserSql = "SELECT customer_id FROM bookings b JOIN invoices i ON b.id = i.booking_id WHERE i.id = ?";
                int customerId = 0;
                try (PreparedStatement fStmt = conn.prepareStatement(findUserSql)) {
                    fStmt.setInt(1, payment.getInvoiceId());
                    try (ResultSet rs = fStmt.executeQuery()) {
                        if (rs.next()) customerId = rs.getInt(1);
                    }
                }
                if (customerId > 0) {
                    int pointsEarned = (int) (payment.getPaymentAmount() * 0.1);
                    String awardPointsSql = "UPDATE users SET loyalty_points = loyalty_points + ? WHERE id = ?";
                    try (PreparedStatement pointsStmt = conn.prepareStatement(awardPointsSql)) {
                        pointsStmt.setInt(1, pointsEarned);
                        pointsStmt.setInt(2, customerId);
                        pointsStmt.executeUpdate();
                    }
                    // Log activity
                    new BookingDAO().addActivity(customerId, "Made online payment of ₹" + payment.getPaymentAmount() + " (Earned " + pointsEarned + " loyalty points)");
                }
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

    public List<Payment> getPaymentHistoryByUser(int userId) {
        List<Payment> list = new ArrayList<>();
        String sql = "SELECT p.* FROM payments p " +
                     "JOIN invoices i ON p.invoice_id = i.id " +
                     "JOIN bookings b ON i.booking_id = b.id " +
                     "WHERE b.customer_id = ? ORDER BY p.id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(extractPaymentFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Payment> getAllPayments() {
        List<Payment> list = new ArrayList<>();
        String sql = "SELECT * FROM payments ORDER BY id DESC";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                list.add(extractPaymentFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private Payment extractPaymentFromResultSet(ResultSet rs) throws SQLException {
        Payment p = new Payment();
        p.setId(rs.getInt("id"));
        p.setInvoiceId(rs.getInt("invoice_id"));
        p.setPaymentMethod(rs.getString("payment_method"));
        p.setPaymentStatus(rs.getString("payment_status"));
        p.setTransactionId(rs.getString("transaction_id"));
        p.setPaymentAmount(rs.getDouble("payment_amount"));
        p.setPaymentDate(rs.getTimestamp("payment_date"));
        return p;
    }
}
