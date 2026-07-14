package com.vehicleservice.controller;

import com.vehicleservice.dao.BookingDAO;
import com.vehicleservice.dao.ServiceDAO;
import com.vehicleservice.dao.UserDAO;
import com.vehicleservice.model.Booking;
import com.vehicleservice.model.ServicePackage;
import com.vehicleservice.model.User;
import com.vehicleservice.util.EmailService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Date;

@WebServlet("/BookingController")
public class BookingController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private BookingDAO bookingDAO = new BookingDAO();
    private ServiceDAO serviceDAO = new ServiceDAO();

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
            response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
            return;
        }

        switch (action) {
            case "book":
                handleBookService(request, response, currentUser);
                break;
            case "update-status":
                handleUpdateStatus(request, response, currentUser);
                break;
            case "assign-mechanic":
                handleAssignMechanic(request, response, currentUser);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
        }
    }

    private void handleBookService(HttpServletRequest request, HttpServletResponse response, User user) 
            throws IOException {
        int vehicleId = Integer.parseInt(request.getParameter("vehicleId"));
        int packageId = Integer.parseInt(request.getParameter("packageId"));
        String bookingDateStr = request.getParameter("bookingDate");
        String preferredTime = request.getParameter("preferredTime");
        String notes = request.getParameter("notes");

        if (bookingDateStr.isEmpty() || preferredTime.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/bookservice.jsp?error=Date and time are required");
            return;
        }

        ServicePackage pkg = serviceDAO.getPackageById(packageId);
        if (pkg == null) {
            response.sendRedirect(request.getContextPath() + "/bookservice.jsp?error=Invalid service package");
            return;
        }

        Booking booking = new Booking();
        booking.setCustomerId(user.getId());
        booking.setVehicleId(vehicleId);
        booking.setPackageId(packageId);
        booking.setBookingDate(Date.valueOf(bookingDateStr));
        booking.setPreferredTime(preferredTime);
        booking.setNotes(notes);
        booking.setStatus("PENDING");
        booking.setTotalCost(pkg.getCost()); // Default base cost

        boolean success = bookingDAO.addBooking(booking);
        if (success) {
            // Trigger structure-only email notification
            EmailService.sendBookingConfirmation(user.getEmail(), user.getName(), 
                    String.valueOf(booking.getId()), bookingDateStr, preferredTime);
            
            response.sendRedirect(request.getContextPath() + "/history.jsp?msg=Service booked successfully!");
        } else {
            response.sendRedirect(request.getContextPath() + "/bookservice.jsp?error=Failed to process service booking");
        }
    }

    private void handleUpdateStatus(HttpServletRequest request, HttpServletResponse response, User user) 
            throws IOException {
        // Only Admin or Employee can update status
        if (!"ADMIN".equalsIgnoreCase(user.getRole()) && !"EMPLOYEE".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/error-404.jsp");
            return;
        }

        int bookingId = Integer.parseInt(request.getParameter("bookingId"));
        String status = request.getParameter("status");

        Booking booking = bookingDAO.getBookingById(bookingId);
        if (booking == null) {
            response.sendRedirect(request.getContextPath() + "/admin-bookings.jsp?error=Booking not found");
            return;
        }

        String oldStatus = booking.getStatus();
        boolean success = bookingDAO.updateStatus(bookingId, status);
        if (success) {
            // Send email notification structure
            User customer = new UserDAO().getUserById(booking.getCustomerId());
            if (customer != null) {
                EmailService.sendStatusUpdate(customer.getEmail(), customer.getName(), 
                        String.valueOf(bookingId), oldStatus, status);
            }
            response.sendRedirect(request.getContextPath() + "/admin-bookings.jsp?msg=Status updated successfully!");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin-bookings.jsp?error=Failed to update booking status");
        }
    }

    private void handleAssignMechanic(HttpServletRequest request, HttpServletResponse response, User user) 
            throws IOException {
        if (!"ADMIN".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/error-404.jsp");
            return;
        }

        int bookingId = Integer.parseInt(request.getParameter("bookingId"));
        int mechanicId = Integer.parseInt(request.getParameter("mechanicId"));

        boolean success = bookingDAO.assignMechanic(bookingId, mechanicId);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin-bookings.jsp?msg=Mechanic assigned successfully! Booking Approved");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin-bookings.jsp?error=Failed to assign mechanic");
        }
    }
}
