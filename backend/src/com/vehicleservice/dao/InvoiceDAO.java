package com.vehicleservice.dao;

import com.vehicleservice.config.DBConnection;
import com.vehicleservice.model.Invoice;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class InvoiceDAO {

    public boolean generateInvoice(Invoice invoice) {
        String sql = "INSERT INTO invoices (booking_id, invoice_number, issue_date, service_cost, part_cost, tax, total_amount, payment_status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Transaction start

            // 1. Generate unique invoice number
            String invoiceNumber = "INV-" + System.currentTimeMillis() / 1000 + "-" + invoice.getBookingId();
            invoice.setInvoiceNumber(invoiceNumber);

            try (PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                stmt.setInt(1, invoice.getBookingId());
                stmt.setString(2, invoice.getInvoiceNumber());
                stmt.setDate(3, invoice.getIssueDate() == null ? new Date(System.currentTimeMillis()) : invoice.getIssueDate());
                stmt.setDouble(4, invoice.getServiceCost());
                stmt.setDouble(5, invoice.getPartCost());
                stmt.setDouble(6, invoice.getTax());
                stmt.setDouble(7, invoice.getTotalAmount());
                stmt.setString(8, invoice.getPaymentStatus() == null ? "UNPAID" : invoice.getPaymentStatus());

                int rows = stmt.executeUpdate();
                if (rows > 0) {
                    try (ResultSet rs = stmt.getGeneratedKeys()) {
                        if (rs.next()) {
                            invoice.setId(rs.getInt(1));
                        }
                    }
                }
            }

            // 2. Set booking status to COMPLETED
            String updateBookingSql = "UPDATE bookings SET status = 'COMPLETED', total_cost = ? WHERE id = ?";
            try (PreparedStatement uStmt = conn.prepareStatement(updateBookingSql)) {
                uStmt.setDouble(1, invoice.getTotalAmount());
                uStmt.setInt(2, invoice.getBookingId());
                uStmt.executeUpdate();
            }

            // 3. Free up mechanic if assigned
            String findMechSql = "SELECT mechanic_id FROM bookings WHERE id = ?";
            Integer mechanicId = null;
            try (PreparedStatement fStmt = conn.prepareStatement(findMechSql)) {
                fStmt.setInt(1, invoice.getBookingId());
                try (ResultSet rs = fStmt.executeQuery()) {
                    if (rs.next()) {
                        int id = rs.getInt("mechanic_id");
                        if (!rs.wasNull()) mechanicId = id;
                    }
                }
            }
            if (mechanicId != null) {
                String freeMechSql = "UPDATE mechanics SET status = 'AVAILABLE' WHERE id = ?";
                try (PreparedStatement freeStmt = conn.prepareStatement(freeMechSql)) {
                    freeStmt.setInt(1, mechanicId);
                    freeStmt.executeUpdate();
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

    public Invoice getInvoiceByBookingId(int bookingId) {
        String sql = "SELECT i.*, b.booking_date, sp.name as pkg_name, u.name as cust_name, u.email as cust_email, " +
                     "u.phone as cust_phone, v.brand, v.model, v.vehicle_number " +
                     "FROM invoices i " +
                     "JOIN bookings b ON i.booking_id = b.id " +
                     "JOIN users u ON b.customer_id = u.id " +
                     "JOIN vehicles v ON b.vehicle_id = v.id " +
                     "JOIN service_packages sp ON b.package_id = sp.id " +
                     "WHERE i.booking_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, bookingId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return extractInvoiceFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Invoice> getAllInvoices() {
        List<Invoice> list = new ArrayList<>();
        String sql = "SELECT i.*, b.booking_date, sp.name as pkg_name, u.name as cust_name, u.email as cust_email, " +
                     "u.phone as cust_phone, v.brand, v.model, v.vehicle_number " +
                     "FROM invoices i " +
                     "JOIN bookings b ON i.booking_id = b.id " +
                     "JOIN users u ON b.customer_id = u.id " +
                     "JOIN vehicles v ON b.vehicle_id = v.id " +
                     "JOIN service_packages sp ON b.package_id = sp.id " +
                     "ORDER BY i.id DESC";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                list.add(extractInvoiceFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updatePaymentStatus(int invoiceId, String status) {
        String sql = "UPDATE invoices SET payment_status = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, status);
            stmt.setInt(2, invoiceId);
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private Invoice extractInvoiceFromResultSet(ResultSet rs) throws SQLException {
        Invoice invoice = new Invoice();
        invoice.setId(rs.getInt("id"));
        invoice.setBookingId(rs.getInt("booking_id"));
        invoice.setInvoiceNumber(rs.getString("invoice_number"));
        invoice.setIssueDate(rs.getDate("issue_date"));
        invoice.setServiceCost(rs.getDouble("service_cost"));
        invoice.setPartCost(rs.getDouble("part_cost"));
        invoice.setTax(rs.getDouble("tax"));
        invoice.setTotalAmount(rs.getDouble("total_amount"));
        invoice.setPaymentStatus(rs.getString("payment_status"));

        // Join fields
        invoice.setCustomerName(rs.getString("cust_name"));
        invoice.setCustomerEmail(rs.getString("cust_email"));
        invoice.setCustomerPhone(rs.getString("cust_phone"));
        invoice.setVehicleBrand(rs.getString("brand"));
        invoice.setVehicleModel(rs.getString("model"));
        invoice.setVehicleNumber(rs.getString("vehicle_number"));
        invoice.setPackageName(rs.getString("pkg_name"));
        invoice.setBookingDate(rs.getDate("booking_date"));
        return invoice;
    }
}
