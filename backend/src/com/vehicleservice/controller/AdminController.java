package com.vehicleservice.controller;

import com.vehicleservice.dao.MechanicDAO;
import com.vehicleservice.dao.ServiceDAO;
import com.vehicleservice.dao.SparePartDAO;
import com.vehicleservice.dao.UserDAO;
import com.vehicleservice.model.Mechanic;
import com.vehicleservice.model.ServicePackage;
import com.vehicleservice.model.SparePart;
import com.vehicleservice.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/AdminController")
public class AdminController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private MechanicDAO mechanicDAO = new MechanicDAO();
    private SparePartDAO sparePartDAO = new SparePartDAO();
    private ServiceDAO serviceDAO = new ServiceDAO();
    private UserDAO userDAO = new UserDAO();

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        User adminUser = (User) session.getAttribute("user");
        if (!"ADMIN".equalsIgnoreCase(adminUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/error-404.jsp");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/admin-dashboard.jsp");
            return;
        }

        switch (action) {
            // Mechanic management
            case "addMechanic":
                handleAddMechanic(request, response);
                break;
            case "updateMechanic":
                handleUpdateMechanic(request, response);
                break;
            case "deleteMechanic":
                handleDeleteMechanic(request, response);
                break;

            // Spare parts management
            case "addPart":
                handleAddPart(request, response);
                break;
            case "updatePart":
                handleUpdatePart(request, response);
                break;
            case "deletePart":
                handleDeletePart(request, response);
                break;

            // Service package management
            case "addPackage":
                handleAddPackage(request, response);
                break;
            case "updatePackage":
                handleUpdatePackage(request, response);
                break;
            case "deletePackage":
                handleDeletePackage(request, response);
                break;

            // Customer management
            case "deleteCustomer":
                handleDeleteCustomer(request, response);
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/admin-dashboard.jsp");
        }
    }

    private void handleAddMechanic(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        String name = request.getParameter("name").trim();
        String phone = request.getParameter("phone").trim();
        String specialization = request.getParameter("specialization").trim();
        String status = request.getParameter("status");

        Mechanic mechanic = new Mechanic();
        mechanic.setName(name);
        mechanic.setPhone(phone);
        mechanic.setSpecialization(specialization);
        mechanic.setStatus(status);

        boolean success = mechanicDAO.addMechanic(mechanic);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin-mechanics.jsp?msg=Mechanic added successfully!");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin-mechanics.jsp?error=Failed to add mechanic");
        }
    }

    private void handleUpdateMechanic(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        int id = Integer.parseInt(request.getParameter("mechanicId"));
        String name = request.getParameter("name").trim();
        String phone = request.getParameter("phone").trim();
        String specialization = request.getParameter("specialization").trim();
        String status = request.getParameter("status");

        Mechanic mechanic = new Mechanic(id, name, phone, specialization, status);
        boolean success = mechanicDAO.updateMechanic(mechanic);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin-mechanics.jsp?msg=Mechanic updated successfully!");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin-mechanics.jsp?error=Failed to update mechanic");
        }
    }

    private void handleDeleteMechanic(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        int id = Integer.parseInt(request.getParameter("mechanicId"));
        boolean success = mechanicDAO.deleteMechanic(id);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin-mechanics.jsp?msg=Mechanic removed successfully!");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin-mechanics.jsp?error=Failed to remove mechanic");
        }
    }

    private void handleAddPart(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        String name = request.getParameter("name").trim();
        double cost = Double.parseDouble(request.getParameter("cost").trim());
        int quantity = Integer.parseInt(request.getParameter("quantity").trim());

        SparePart part = new SparePart();
        part.setName(name);
        part.setCost(cost);
        part.setQuantity(quantity);

        boolean success = sparePartDAO.addPart(part);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin-parts.jsp?msg=Spare part added to inventory!");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin-parts.jsp?error=Failed to add spare part");
        }
    }

    private void handleUpdatePart(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        int id = Integer.parseInt(request.getParameter("partId"));
        String name = request.getParameter("name").trim();
        double cost = Double.parseDouble(request.getParameter("cost").trim());
        int quantity = Integer.parseInt(request.getParameter("quantity").trim());

        SparePart part = new SparePart(id, name, cost, quantity);
        boolean success = sparePartDAO.updatePart(part);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin-parts.jsp?msg=Inventory updated successfully!");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin-parts.jsp?error=Failed to update spare part details");
        }
    }

    private void handleDeletePart(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        int id = Integer.parseInt(request.getParameter("partId"));
        boolean success = sparePartDAO.deletePart(id);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin-parts.jsp?msg=Spare part removed from inventory!");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin-parts.jsp?error=Failed to remove spare part");
        }
    }

    private void handleAddPackage(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        String name = request.getParameter("name").trim();
        String description = request.getParameter("description").trim();
        double cost = Double.parseDouble(request.getParameter("cost").trim());
        int duration = Integer.parseInt(request.getParameter("durationHours").trim());

        ServicePackage pkg = new ServicePackage(0, name, description, cost, duration);
        boolean success = serviceDAO.addPackage(pkg);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin-reports.jsp?msg=Service package added successfully!");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin-reports.jsp?error=Failed to add service package");
        }
    }

    private void handleUpdatePackage(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        int id = Integer.parseInt(request.getParameter("packageId"));
        String name = request.getParameter("name").trim();
        String description = request.getParameter("description").trim();
        double cost = Double.parseDouble(request.getParameter("cost").trim());
        int duration = Integer.parseInt(request.getParameter("durationHours").trim());

        ServicePackage pkg = new ServicePackage(id, name, description, cost, duration);
        boolean success = serviceDAO.updatePackage(pkg);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin-reports.jsp?msg=Service package updated successfully!");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin-reports.jsp?error=Failed to update service package");
        }
    }

    private void handleDeletePackage(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        int id = Integer.parseInt(request.getParameter("packageId"));
        boolean success = serviceDAO.deletePackage(id);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin-reports.jsp?msg=Service package deleted successfully!");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin-reports.jsp?error=Failed to delete service package");
        }
    }

    private void handleDeleteCustomer(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        int customerId = Integer.parseInt(request.getParameter("customerId"));
        boolean success = userDAO.deleteUser(customerId);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin-customers.jsp?msg=Customer profile deleted successfully!");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin-customers.jsp?error=Failed to delete customer");
        }
    }
}
