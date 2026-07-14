package com.vehicleservice.dao;

import com.vehicleservice.config.DBConnection;
import com.vehicleservice.model.VehicleHealth;

import java.sql.*;

public class VehicleHealthDAO {

    public VehicleHealth getHealthByVehicle(int vehicleId) {
        String sql = "SELECT * FROM vehicle_health WHERE vehicle_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, vehicleId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return extractHealthFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        // Fallback: Initialize and return a new mock health report
        initializeHealth(vehicleId);
        return getHealthByVehicle(vehicleId);
    }

    public boolean initializeHealth(int vehicleId) {
        // Generate pseudo-random realistic health metrics for the dashboard
        int battery = 80 + (int)(Math.random() * 20);
        int engine = 75 + (int)(Math.random() * 25);
        int brake = 70 + (int)(Math.random() * 30);
        int oil = 85 + (int)(Math.random() * 15);
        int tyre = 65 + (int)(Math.random() * 35);
        int coolant = 80 + (int)(Math.random() * 20);
        int overall = (battery + engine + brake + oil + tyre + coolant) / 6;

        String sql = "INSERT IGNORE INTO vehicle_health (vehicle_id, battery_health, engine_condition, brake_status, oil_level, tyre_condition, coolant_level, overall_health) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, vehicleId);
            stmt.setInt(2, battery);
            stmt.setInt(3, engine);
            stmt.setInt(4, brake);
            stmt.setInt(5, oil);
            stmt.setInt(6, tyre);
            stmt.setInt(7, coolant);
            stmt.setInt(8, overall);
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateHealth(VehicleHealth health) {
        String sql = "UPDATE vehicle_health SET battery_health = ?, engine_condition = ?, brake_status = ?, oil_level = ?, tyre_condition = ?, coolant_level = ?, overall_health = ? WHERE vehicle_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, health.getBatteryHealth());
            stmt.setInt(2, health.getEngineCondition());
            stmt.setInt(3, health.getBrakeStatus());
            stmt.setInt(4, health.getOilLevel());
            stmt.setInt(5, health.getTyreCondition());
            stmt.setInt(6, health.getCoolantLevel());
            stmt.setInt(7, health.getOverallHealth());
            stmt.setInt(8, health.getVehicleId());
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private VehicleHealth extractHealthFromResultSet(ResultSet rs) throws SQLException {
        VehicleHealth h = new VehicleHealth();
        h.setId(rs.getInt("id"));
        h.setVehicleId(rs.getInt("vehicle_id"));
        h.setBatteryHealth(rs.getInt("battery_health"));
        h.setEngineCondition(rs.getInt("engine_condition"));
        h.setBrakeStatus(rs.getInt("brake_status"));
        h.setOilLevel(rs.getInt("oil_level"));
        h.setTyreCondition(rs.getInt("tyre_condition"));
        h.setCoolantLevel(rs.getInt("coolant_level"));
        h.setOverallHealth(rs.getInt("overall_health"));
        return h;
    }
}
