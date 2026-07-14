package com.vehicleservice.dao;

import com.vehicleservice.config.DBConnection;
import com.vehicleservice.model.ServicePackage;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ServiceDAO {

    public List<ServicePackage> getAllPackages() {
        List<ServicePackage> list = new ArrayList<>();
        String sql = "SELECT * FROM service_packages ORDER BY cost ASC";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                list.add(extractPackageFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public ServicePackage getPackageById(int id) {
        String sql = "SELECT * FROM service_packages WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return extractPackageFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean addPackage(ServicePackage pkg) {
        String sql = "INSERT INTO service_packages (name, description, cost, duration_hours) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, pkg.getName());
            stmt.setString(2, pkg.getDescription());
            stmt.setDouble(3, pkg.getCost());
            stmt.setInt(4, pkg.getDurationHours());
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updatePackage(ServicePackage pkg) {
        String sql = "UPDATE service_packages SET name = ?, description = ?, cost = ?, duration_hours = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, pkg.getName());
            stmt.setString(2, pkg.getDescription());
            stmt.setDouble(3, pkg.getCost());
            stmt.setInt(4, pkg.getDurationHours());
            stmt.setInt(5, pkg.getId());
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deletePackage(int id) {
        String sql = "DELETE FROM service_packages WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private ServicePackage extractPackageFromResultSet(ResultSet rs) throws SQLException {
        ServicePackage pkg = new ServicePackage();
        pkg.setId(rs.getInt("id"));
        pkg.setName(rs.getString("name"));
        pkg.setDescription(rs.getString("description"));
        pkg.setCost(rs.getDouble("cost"));
        pkg.setDurationHours(rs.getInt("duration_hours"));
        return pkg;
    }
}
