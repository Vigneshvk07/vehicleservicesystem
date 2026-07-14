package com.vehicleservice.controller;

import com.vehicleservice.config.DBConnection;
import com.vehicleservice.dao.BookingDAO;
import com.vehicleservice.dao.FeedbackDAO;
import com.vehicleservice.dao.PaymentDAO;
import com.vehicleservice.model.Feedback;
import com.vehicleservice.model.Payment;
import com.vehicleservice.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/CustomerActionController")
public class CustomerActionController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private PaymentDAO paymentDAO = new PaymentDAO();
    private FeedbackDAO feedbackDAO = new FeedbackDAO();
    private BookingDAO bookingDAO = new BookingDAO();

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
            case "payment":
                handlePayment(request, response, currentUser);
                break;
            case "feedback":
                handleFeedback(request, response, currentUser);
                break;
            case "wishlist-toggle":
                handleWishlistToggle(request, response, currentUser);
                break;
            case "apply-coupon":
                handleApplyCoupon(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
        }
    }

    private void handlePayment(HttpServletRequest request, HttpServletResponse response, User user) 
            throws IOException {
        int invoiceId = Integer.parseInt(request.getParameter("invoiceId"));
        int bookingId = Integer.parseInt(request.getParameter("bookingId"));
        double amount = Double.parseDouble(request.getParameter("amount"));
        String method = request.getParameter("paymentMethod"); // 'UPI', 'CARD', 'NET_BANKING'
        String transactionId = request.getParameter("transactionId").trim();

        if (transactionId.isEmpty()) {
            transactionId = "TXN-" + System.currentTimeMillis();
        }

        Payment p = new Payment();
        p.setInvoiceId(invoiceId);
        p.setPaymentMethod(method);
        p.setPaymentStatus("PAID");
        p.setTransactionId(transactionId);
        p.setPaymentAmount(amount);

        boolean success = paymentDAO.addPayment(p);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/invoice.jsp?bookingId=" + bookingId + "&msg=Payment processed successfully! Transaction ID: " + transactionId);
        } else {
            response.sendRedirect(request.getContextPath() + "/invoice.jsp?bookingId=" + bookingId + "&error=Failed to process payment transaction");
        }
    }

    private void handleFeedback(HttpServletRequest request, HttpServletResponse response, User user) 
            throws IOException {
        String type = request.getParameter("type"); // 'FEEDBACK', 'COMPLAINT', 'REVIEW'
        String message = request.getParameter("message").trim();
        String ratingStr = request.getParameter("rating");
        String bookingIdStr = request.getParameter("bookingId");

        Integer rating = (ratingStr != null && !ratingStr.isEmpty()) ? Integer.parseInt(ratingStr) : null;
        Integer bookingId = (bookingIdStr != null && !bookingIdStr.isEmpty()) ? Integer.parseInt(bookingIdStr) : null;

        if (message.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/dashboard.jsp?error=Message cannot be empty");
            return;
        }

        Feedback fb = new Feedback();
        fb.setUserId(user.getId());
        fb.setBookingId(bookingId);
        fb.setType(type);
        fb.setMessage(message);
        fb.setRating(rating);
        fb.setStatus("OPEN");

        boolean success = feedbackDAO.addFeedback(fb);
        if (success) {
            bookingDAO.addActivity(user.getId(), "Submitted a new " + type.toLowerCase() + " request");
            response.sendRedirect(request.getContextPath() + "/dashboard.jsp?msg=" + type + " submitted successfully!");
        } else {
            response.sendRedirect(request.getContextPath() + "/dashboard.jsp?error=Failed to submit feedback");
        }
    }

    private void handleWishlistToggle(HttpServletRequest request, HttpServletResponse response, User user) 
            throws IOException {
        int packageId = Integer.parseInt(request.getParameter("packageId"));
        String status = request.getParameter("status"); // 'add', 'remove'

        String sql;
        if ("add".equalsIgnoreCase(status)) {
            sql = "INSERT IGNORE INTO wishlist (user_id, package_id) VALUES (?, ?)";
        } else {
            sql = "DELETE FROM wishlist WHERE user_id = ? AND package_id = ?";
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, user.getId());
            stmt.setInt(2, packageId);
            stmt.executeUpdate();
            
            response.sendRedirect(request.getContextPath() + "/bookservice.jsp?msg=Wishlist updated!");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/bookservice.jsp?error=Failed to update wishlist");
        }
    }

    private void handleApplyCoupon(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        String code = request.getParameter("couponCode").trim().toUpperCase();
        
        String sql = "SELECT discount_percent FROM coupons WHERE code = ? AND active = TRUE AND expiry_date >= CURDATE()";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, code);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    double percent = rs.getDouble("discount_percent");
                    // Save in session for booking application
                    request.getSession().setAttribute("appliedCoupon", code);
                    request.getSession().setAttribute("couponDiscountPercent", percent);
                    response.sendRedirect(request.getContextPath() + "/bookservice.jsp?msg=Coupon applied! " + percent + "% discount added");
                } else {
                    response.sendRedirect(request.getContextPath() + "/bookservice.jsp?error=Invalid or expired coupon code");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/bookservice.jsp?error=Error applying coupon");
        }
    }
}
