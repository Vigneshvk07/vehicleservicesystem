package com.vehicleservice.controller;

import com.vehicleservice.dao.VehicleDAO;
import com.vehicleservice.model.User;
import com.vehicleservice.model.Vehicle;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/VehicleController")
public class VehicleController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private VehicleDAO vehicleDAO = new VehicleDAO();

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/myvehicles.jsp");
            return;
        }

        switch (action) {
            case "add":
                handleAddVehicle(request, response, currentUser.getId());
                break;
            case "update":
                handleUpdateVehicle(request, response, currentUser.getId());
                break;
            case "delete":
                handleDeleteVehicle(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/myvehicles.jsp");
        }
    }

    private void handleAddVehicle(HttpServletRequest request, HttpServletResponse response, int customerId) 
            throws IOException {
        String vehicleNumber = request.getParameter("vehicleNumber").trim();
        String type = request.getParameter("type");
        String brand = request.getParameter("brand").trim();
        String model = request.getParameter("model").trim();
        int year = Integer.parseInt(request.getParameter("year").trim());

        if (vehicleNumber.isEmpty() || brand.isEmpty() || model.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/myvehicles.jsp?error=All fields are required");
            return;
        }

        Vehicle vehicle = new Vehicle();
        vehicle.setCustomerId(customerId);
        vehicle.setVehicleNumber(vehicleNumber);
        vehicle.setType(type);
        vehicle.setBrand(brand);
        vehicle.setModel(model);
        vehicle.setYear(year);

        boolean success = vehicleDAO.addVehicle(vehicle);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/myvehicles.jsp?msg=Vehicle registered successfully!");
        } else {
            response.sendRedirect(request.getContextPath() + "/myvehicles.jsp?error=Vehicle number already registered");
        }
    }

    private void handleUpdateVehicle(HttpServletRequest request, HttpServletResponse response, int customerId) 
            throws IOException {
        int vehicleId = Integer.parseInt(request.getParameter("vehicleId"));
        String vehicleNumber = request.getParameter("vehicleNumber").trim();
        String type = request.getParameter("type");
        String brand = request.getParameter("brand").trim();
        String model = request.getParameter("model").trim();
        int year = Integer.parseInt(request.getParameter("year").trim());

        Vehicle vehicle = vehicleDAO.getVehicleById(vehicleId);
        if (vehicle == null || vehicle.getCustomerId() != customerId) {
            response.sendRedirect(request.getContextPath() + "/myvehicles.jsp?error=Unauthorized vehicle edit");
            return;
        }

        vehicle.setVehicleNumber(vehicleNumber);
        vehicle.setType(type);
        vehicle.setBrand(brand);
        vehicle.setModel(model);
        vehicle.setYear(year);

        boolean success = vehicleDAO.updateVehicle(vehicle);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/myvehicles.jsp?msg=Vehicle updated successfully!");
        } else {
            response.sendRedirect(request.getContextPath() + "/myvehicles.jsp?error=Failed to update vehicle details");
        }
    }

    private void handleDeleteVehicle(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        int vehicleId = Integer.parseInt(request.getParameter("vehicleId"));
        
        boolean success = vehicleDAO.deleteVehicle(vehicleId);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/myvehicles.jsp?msg=Vehicle removed successfully!");
        } else {
            response.sendRedirect(request.getContextPath() + "/myvehicles.jsp?error=Failed to remove vehicle");
        }
    }
}
