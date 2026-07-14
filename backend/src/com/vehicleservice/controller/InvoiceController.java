package com.vehicleservice.controller;

import com.vehicleservice.dao.BookingDAO;
import com.vehicleservice.dao.InvoiceDAO;
import com.vehicleservice.dao.SparePartDAO;
import com.vehicleservice.model.Booking;
import com.vehicleservice.model.Invoice;
import com.vehicleservice.model.SparePart;
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
import java.util.ArrayList;
import java.util.List;

@WebServlet("/InvoiceController")
public class InvoiceController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private InvoiceDAO invoiceDAO = new InvoiceDAO();
    private BookingDAO bookingDAO = new BookingDAO();
    private SparePartDAO sparePartDAO = new SparePartDAO();

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
            case "generate":
                handleGenerateInvoice(request, response, currentUser);
                break;
            case "pay":
                handlePayInvoice(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
        }
    }

    private void handleGenerateInvoice(HttpServletRequest request, HttpServletResponse response, User admin) 
            throws IOException {
        if (!"ADMIN".equalsIgnoreCase(admin.getRole())) {
            response.sendRedirect(request.getContextPath() + "/error-404.jsp");
            return;
        }

        int bookingId = Integer.parseInt(request.getParameter("bookingId"));
        Booking booking = bookingDAO.getBookingById(bookingId);
        if (booking == null) {
            response.sendRedirect(request.getContextPath() + "/admin-bookings.jsp?error=Booking not found");
            return;
        }

        double serviceCost = booking.getTotalCost(); // Base package cost
        double partCost = 0.0;

        // Process selected spare parts from form (parts can be submitted as arrays)
        String[] partIds = request.getParameterValues("partIds");
        String[] partQtys = request.getParameterValues("partQtys");

        if (partIds != null && partQtys != null) {
            for (int i = 0; i < partIds.length; i++) {
                if (partIds[i] != null && !partIds[i].isEmpty()) {
                    int partId = Integer.parseInt(partIds[i]);
                    int qty = Integer.parseInt(partQtys[i]);
                    if (qty > 0) {
                        SparePart part = sparePartDAO.getPartById(partId);
                        if (part != null) {
                            boolean stockDeducted = sparePartDAO.addPartToBooking(bookingId, partId, qty);
                            if (stockDeducted) {
                                partCost += (part.getCost() * qty);
                            }
                        }
                    }
                }
            }
        }

        double subtotal = serviceCost + partCost;
        double tax = subtotal * 0.18; // 18% GST
        double totalAmount = subtotal + tax;

        Invoice invoice = new Invoice();
        invoice.setBookingId(bookingId);
        invoice.setIssueDate(new Date(System.currentTimeMillis()));
        invoice.setServiceCost(serviceCost);
        invoice.setPartCost(partCost);
        invoice.setTax(tax);
        invoice.setTotalAmount(totalAmount);
        invoice.setPaymentStatus("UNPAID");

        boolean success = invoiceDAO.generateInvoice(invoice);
        if (success) {
            // Trigger email update simulation
            EmailService.sendInvoiceNotification(booking.getCustomerEmail(), booking.getCustomerName(), 
                    String.valueOf(bookingId), totalAmount);
            
            response.sendRedirect(request.getContextPath() + "/admin-bookings.jsp?msg=Invoice generated successfully for Booking #" + bookingId);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin-bookings.jsp?error=Failed to generate invoice");
        }
    }

    private void handlePayInvoice(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        int invoiceId = Integer.parseInt(request.getParameter("invoiceId"));
        int bookingId = Integer.parseInt(request.getParameter("bookingId"));
        
        boolean success = invoiceDAO.updatePaymentStatus(invoiceId, "PAID");
        if (success) {
            response.sendRedirect(request.getContextPath() + "/invoice.jsp?bookingId=" + bookingId + "&msg=Payment processed successfully!");
        } else {
            response.sendRedirect(request.getContextPath() + "/invoice.jsp?bookingId=" + bookingId + "&error=Failed to process payment");
        }
    }
}
