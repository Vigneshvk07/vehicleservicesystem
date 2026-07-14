package com.vehicleservice.filter;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Initialization code if needed
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);
        
        String requestURI = httpRequest.getRequestURI();
        
        // Allow public pages and assets
        boolean isPublicPage = requestURI.endsWith("login.jsp") || 
                               requestURI.endsWith("register.jsp") || 
                               requestURI.endsWith("forgot-password.jsp") || 
                               requestURI.endsWith("index.jsp") || 
                               requestURI.endsWith("contact.jsp") || 
                               requestURI.contains("/css/") || 
                               requestURI.contains("/js/") || 
                               requestURI.contains("/images/") ||
                               requestURI.contains("AuthController");

        boolean isLoggedIn = (session != null && session.getAttribute("user") != null);

        if (isLoggedIn) {
            com.vehicleservice.model.User currentUser = (com.vehicleservice.model.User) session.getAttribute("user");
            String role = currentUser.getRole();

            // Prevent general users from accessing admin pages
            if (requestURI.contains("admin-") && !"ADMIN".equalsIgnoreCase(role)) {
                httpResponse.sendRedirect(httpRequest.getContextPath() + "/error-404.jsp");
                return;
            }
            
            // If logged in user tries to visit login/register, redirect them to dashboard
            if (requestURI.endsWith("login.jsp") || requestURI.endsWith("register.jsp")) {
                if ("ADMIN".equalsIgnoreCase(role)) {
                    httpResponse.sendRedirect(httpRequest.getContextPath() + "/admin-dashboard.jsp");
                } else {
                    httpResponse.sendRedirect(httpRequest.getContextPath() + "/dashboard.jsp");
                }
                return;
            }
            
            chain.doFilter(request, response);
        } else {
            if (isPublicPage || requestURI.endsWith("/") || requestURI.endsWith(httpRequest.getContextPath())) {
                chain.doFilter(request, response);
            } else {
                // Not logged in and trying to access restricted page
                httpResponse.sendRedirect(httpRequest.getContextPath() + "/login.jsp?error=Please login to access this page");
            }
        }
    }

    @Override
    public void destroy() {
        // Cleanup code
    }
}
