package com.vehicleservice.dao;

import com.vehicleservice.config.DBConnection;
import com.vehicleservice.model.Mechanic;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MechanicDAO {

    public List<Mechanic> getAllMechanics() {
        List<Mechanic> list = new ArrayList<>();
        String sql = "SELECT * FROM mechanics ORDER BY id DESC";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                list.add(extractMechanicFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Mechanic> getAvailableMechanics() {
        List<Mechanic> list = new ArrayList<>();
        String sql = "SELECT * FROM mechanics WHERE status = 'AVAILABLE' ORDER BY name ASC";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                list.add(extractMechanicFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Mechanic getMechanicById(int id) {
        String sql = "SELECT * FROM mechanics WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return extractMechanicFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean addMechanic(Mechanic mechanic) {
        String sql = "INSERT INTO mechanics (name, phone, specialization, status) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, mechanic.getName());
            stmt.setString(2, mechanic.getPhone());
            stmt.setString(3, mechanic.getSpecialization());
            stmt.setString(4, mechanic.getStatus() == null ? "AVAILABLE" : mechanic.getStatus());
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateMechanic(Mechanic mechanic) {
        String sql = "UPDATE mechanics SET name = ?, phone = ?, specialization = ?, status = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, mechanic.getName());
            stmt.setString(2, mechanic.getPhone());
            stmt.setString(3, mechanic.getSpecialization());
            stmt.setString(4, mechanic.getStatus());
            stmt.setInt(5, mechanic.getId());
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateStatus(int mechanicId, String status) {
        String sql = "UPDATE mechanics SET status = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, status);
            stmt.setInt(2, mechanicId);
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteMechanic(int id) {
        String sql = "DELETE FROM mechanics WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private Mechanic extractMechanicFromResultSet(ResultSet rs) throws SQLException {
        Mechanic mechanic = new Mechanic();
        mechanic.setId(rs.getInt("id"));
        mechanic.setName(rs.getString("name"));
        mechanic.setPhone(rs.getString("phone"));
        mechanic.setSpecialization(rs.getString("specialization"));
        mechanic.setStatus(rs.getString("status"));
        return mechanic;
    }
}
