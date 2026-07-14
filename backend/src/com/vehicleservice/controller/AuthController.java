package com.vehicleservice.controller;

import com.vehicleservice.dao.UserDAO;
import com.vehicleservice.model.User;
import com.vehicleservice.util.PasswordHasher;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/AuthController")
public class AuthController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO = new UserDAO();

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        switch (action) {
            case "login":
                handleLogin(request, response);
                break;
            case "register":
                handleRegister(request, response);
                break;
            case "forgot-password":
                handleForgotPassword(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/login.jsp");
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("logout".equalsIgnoreCase(action)) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.invalidate();
            }
            response.sendRedirect(request.getContextPath() + "/login.jsp?msg=Logged out successfully");
        } else {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
        }
    }

    private void handleLogin(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        String email = request.getParameter("email").trim();
        String password = request.getParameter("password").trim();

        if (email.isEmpty() || password.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=Please fill all credentials");
            return;
        }

        User user = userDAO.validateUser(email, password);
        if (user != null) {
            HttpSession session = request.getSession(true);
            session.setAttribute("user", user);

            if ("ADMIN".equalsIgnoreCase(user.getRole())) {
                response.sendRedirect(request.getContextPath() + "/admin-dashboard.jsp");
            } else {
                response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=Invalid email or password");
        }
    }

    private void handleRegister(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        String name = request.getParameter("name").trim();
        String email = request.getParameter("email").trim();
        String phone = request.getParameter("phone").trim();
        String password = request.getParameter("password").trim();
        String confirmPassword = request.getParameter("confirmPassword").trim();

        if (name.isEmpty() || email.isEmpty() || phone.isEmpty() || password.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/register.jsp?error=All fields are required");
            return;
        }

        if (!password.equals(confirmPassword)) {
            response.sendRedirect(request.getContextPath() + "/register.jsp?error=Passwords do not match");
            return;
        }

        User user = new User();
        user.setName(name);
        user.setEmail(email);
        user.setPhone(phone);
        user.setPasswordHash(password); // Raw password, registerUser will hash it
        user.setRole("CUSTOMER");

        boolean success = userDAO.registerUser(user);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?msg=Account created successfully! Please login");
        } else {
            response.sendRedirect(request.getContextPath() + "/register.jsp?error=Email address already registered");
        }
    }

    private void handleForgotPassword(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        String email = request.getParameter("email").trim();
        String newPassword = request.getParameter("newPassword").trim();
        String confirmPassword = request.getParameter("confirmPassword").trim();

        if (email.isEmpty() || newPassword.isEmpty() || confirmPassword.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/forgot-password.jsp?error=All fields are required");
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            response.sendRedirect(request.getContextPath() + "/forgot-password.jsp?error=Passwords do not match");
            return;
        }

        // Verify if user exists
        User user = new UserDAO().getAllCustomers().stream()
                .filter(u -> u.getEmail().equalsIgnoreCase(email))
                .findFirst().orElse(null);

        // Also check admin
        if (user == null && "admin@vss.com".equalsIgnoreCase(email)) {
            user = new User();
            user.setEmail(email);
        }

        if (user != null) {
            boolean success = userDAO.resetPassword(email, newPassword);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/login.jsp?msg=Password reset successful! Please login");
            } else {
                response.sendRedirect(request.getContextPath() + "/forgot-password.jsp?error=Failed to reset password");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/forgot-password.jsp?error=Email address not found");
        }
    }
}
