package com.vehicleservice.dao;

import com.vehicleservice.config.DBConnection;
import com.vehicleservice.model.Booking;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BookingDAO {

    public boolean addBooking(Booking booking) {
        String sql = "INSERT INTO bookings (customer_id, vehicle_id, package_id, booking_date, preferred_time, status, notes, total_cost) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setInt(1, booking.getCustomerId());
            stmt.setInt(2, booking.getVehicleId());
            stmt.setInt(3, booking.getPackageId());
            stmt.setDate(4, booking.getBookingDate());
            stmt.setString(5, booking.getPreferredTime());
            stmt.setString(6, booking.getStatus() == null ? "PENDING" : booking.getStatus());
            stmt.setString(7, booking.getNotes());
            stmt.setDouble(8, booking.getTotalCost());
            
            int rows = stmt.executeUpdate();
            if (rows > 0) {
                try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        booking.setId(generatedKeys.getInt(1));
                        // Log activity
                        addActivity(booking.getCustomerId(), "Booked a new service appointment (ID: #" + booking.getId() + ")");
                        return true;
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Booking> getBookingsByCustomer(int customerId) {
        List<Booking> list = new ArrayList<>();
        String sql = "SELECT b.*, v.vehicle_number, v.brand, v.model, sp.name as pkg_name, m.name as mech_name " +
                     "FROM bookings b " +
                     "JOIN vehicles v ON b.vehicle_id = v.id " +
                     "JOIN service_packages sp ON b.package_id = sp.id " +
                     "LEFT JOIN mechanics m ON b.mechanic_id = m.id " +
                     "WHERE b.customer_id = ? ORDER BY b.id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, customerId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(extractBookingFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Booking getBookingById(int id) {
        String sql = "SELECT b.*, v.vehicle_number, v.brand, v.model, sp.name as pkg_name, m.name as mech_name, " +
                     "u.name as cust_name, u.email as cust_email, u.phone as cust_phone " +
                     "FROM bookings b " +
                     "JOIN users u ON b.customer_id = u.id " +
                     "JOIN vehicles v ON b.vehicle_id = v.id " +
                     "JOIN service_packages sp ON b.package_id = sp.id " +
                     "LEFT JOIN mechanics m ON b.mechanic_id = m.id " +
                     "WHERE b.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Booking booking = extractBookingFromResultSet(rs);
                    booking.setCustomerName(rs.getString("cust_name"));
                    booking.setCustomerEmail(rs.getString("cust_email"));
                    booking.setCustomerPhone(rs.getString("cust_phone"));
                    return booking;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Booking> getAllBookings() {
        List<Booking> list = new ArrayList<>();
        String sql = "SELECT b.*, v.vehicle_number, v.brand, v.model, sp.name as pkg_name, m.name as mech_name, " +
                     "u.name as cust_name, u.email as cust_email, u.phone as cust_phone " +
                     "FROM bookings b " +
                     "JOIN users u ON b.customer_id = u.id " +
                     "JOIN vehicles v ON b.vehicle_id = v.id " +
                     "JOIN service_packages sp ON b.package_id = sp.id " +
                     "LEFT JOIN mechanics m ON b.mechanic_id = m.id " +
                     "ORDER BY b.id DESC";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Booking booking = extractBookingFromResultSet(rs);
                booking.setCustomerName(rs.getString("cust_name"));
                booking.setCustomerEmail(rs.getString("cust_email"));
                booking.setCustomerPhone(rs.getString("cust_phone"));
                list.add(booking);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateStatus(int bookingId, String status) {
        String sql = "UPDATE bookings SET status = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, status);
            stmt.setInt(2, bookingId);
            
            boolean updated = stmt.executeUpdate() > 0;
            if (updated) {
                // Log activity
                addActivity(null, "Updated booking #" + bookingId + " status to " + status);
            }
            return updated;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean assignMechanic(int bookingId, int mechanicId) {
        String sql = "UPDATE bookings SET mechanic_id = ?, status = 'APPROVED' WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, mechanicId);
            stmt.setInt(2, bookingId);
            
            boolean assigned = stmt.executeUpdate() > 0;
            if (assigned) {
                // Make mechanic busy
                try (PreparedStatement uMech = conn.prepareStatement("UPDATE mechanics SET status = 'BUSY' WHERE id = ?")) {
                    uMech.setInt(1, mechanicId);
                    uMech.executeUpdate();
                }
                addActivity(null, "Assigned Mechanic ID: " + mechanicId + " to booking #" + bookingId);
            }
            return assigned;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateCost(int bookingId, double totalCost) {
        String sql = "UPDATE bookings SET total_cost = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setDouble(1, totalCost);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteBooking(int id) {
        String sql = "DELETE FROM bookings WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Dashboard Statistics Methods
    public int getTodayBookingsCount() {
        String sql = "SELECT COUNT(*) FROM bookings WHERE booking_date = CURDATE()";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int getCompletedServicesCount() {
        String sql = "SELECT COUNT(*) FROM bookings WHERE status = 'COMPLETED'";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int getPendingServicesCount() {
        String sql = "SELECT COUNT(*) FROM bookings WHERE status = 'PENDING'";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public double getRevenue() {
        String sql = "SELECT SUM(total_amount) FROM invoices WHERE payment_status = 'PAID'";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) return rs.getDouble(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }

    // Recent Activities Logs
    public void addActivity(Integer userId, String description) {
        String sql = "INSERT INTO recent_activities (user_id, description) VALUES (?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            if (userId != null) {
                stmt.setInt(1, userId);
            } else {
                stmt.setNull(1, Types.INTEGER);
            }
            stmt.setString(2, description);
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<String> getRecentActivities() {
        List<String> list = new ArrayList<>();
        String sql = "SELECT description, created_at FROM recent_activities ORDER BY id DESC LIMIT 8";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                list.add(rs.getString("description") + " (" + rs.getTimestamp("created_at") + ")");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private Booking extractBookingFromResultSet(ResultSet rs) throws SQLException {
        Booking booking = new Booking();
        booking.setId(rs.getInt("id"));
        booking.setCustomerId(rs.getInt("customer_id"));
        booking.setVehicleId(rs.getInt("vehicle_id"));
        booking.setPackageId(rs.getInt("package_id"));
        booking.setBookingDate(rs.getDate("booking_date"));
        booking.setPreferredTime(rs.getString("preferred_time"));
        booking.setStatus(rs.getString("status"));
        booking.setNotes(rs.getString("notes"));
        int mechId = rs.getInt("mechanic_id");
        booking.setMechanicId(rs.wasNull() ? null : mechId);
        booking.setTotalCost(rs.getDouble("total_cost"));
        booking.setCreatedAt(rs.getTimestamp("created_at"));

        // Join fields
        booking.setVehicleNumber(rs.getString("vehicle_number"));
        booking.setVehicleBrand(rs.getString("brand"));
        booking.setVehicleModel(rs.getString("model"));
        booking.setPackageName(rs.getString("pkg_name"));
        booking.setMechanicName(rs.getString("mech_name"));
        return booking;
    }
}
