<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.vehicleservice.model.User" %>
<%@ page import="com.vehicleservice.dao.UserDAO" %>
<%@ page import="java.util.List" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null || !"ADMIN".equalsIgnoreCase(sessionUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/error-404.jsp");
        return;
    }

    UserDAO userDAO = new UserDAO();
    List<User> customers = userDAO.getAllCustomers();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Customers - VSS Admin</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="css/style.css">
    <style>
        .admin-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
        }
        .admin-table th, .admin-table td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid var(--border-color);
        }
        .admin-table th {
            background: rgba(13, 110, 253, 0.1);
            font-weight: 600;
        }
        .admin-table tbody tr:hover {
            background: rgba(255, 255, 255, 0.05);
        }
    </style>
</head>
<body>

    <!-- Sticky Header -->
    <header>
        <h1>
            <img src="images/logo.png" alt="Logo" class="logo" onerror="this.src='https://cdn-icons-png.flaticon.com/512/3202/3202926.png'">
            VSS Admin Console
        </h1>
        <nav>
            <a href="admin-dashboard.jsp">Overview</a>
            <a href="admin-bookings.jsp">Approve Bookings</a>
            <a href="admin-customers.jsp" class="active">Customers</a>
            <a href="admin-parts.jsp">Parts Inventory</a>
            <a href="admin-mechanics.jsp">Mechanics</a>
            <a href="admin-reports.jsp">Analytics & Reports</a>
            <a href="AuthController?action=logout" class="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a>
            <button class="theme-toggle-btn" id="theme-toggle"><i class="fas fa-moon"></i></button>
        </nav>
    </header>

    <div class="glass-container">
        <h2><i class="fas fa-users text-primary"></i> Customer Management</h2>
        <p style="color:var(--text-muted); font-size:14px; margin-bottom:20px;">View registered customer details, their loyalty points, and remove inactive accounts.</p>

        <!-- Search Bar -->
        <div style="margin-bottom: 20px; position:relative; width:300px;">
            <input type="text" id="search-input" class="form-control" placeholder="Search by name, email, phone..." onkeyup="filterAdminTable()" style="padding-left:35px;">
            <i class="fas fa-search" style="position:absolute; left:12px; top:15px; color:var(--text-muted);"></i>
        </div>

        <div style="overflow-x:auto;">
            <table class="admin-table" id="admin-table">
                <thead>
                    <tr>
                        <th>Customer ID</th>
                        <th>Name</th>
                        <th>Email Address</th>
                        <th>Phone Number</th>
                        <th>Loyalty Points</th>
                        <th>Registration Date</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (customers.isEmpty()) { %>
                        <tr>
                            <td colspan="7" style="text-align:center; padding:30px;">
                                <i class="fas fa-user-slash" style="font-size:36px; color:var(--text-muted); margin-bottom:10px;"></i>
                                <p>No customers found.</p>
                            </td>
                        </tr>
                    <% } else { 
                        for (User c : customers) { 
                    %>
                            <tr class="admin-row">
                                <td><strong>#USR-<%= c.getId() %></strong></td>
                                <td><%= c.getName() %></td>
                                <td><%= c.getEmail() %></td>
                                <td><%= c.getPhone() != null ? c.getPhone() : "N/A" %></td>
                                <td><span class="badge" style="background:var(--success); color:#white; padding:2px 8px; border-radius:4px;"><%= c.getLoyaltyPoints() %> pts</span></td>
                                <td><%= c.getCreatedAt() != null ? c.getCreatedAt().toString().substring(0, 10) : "N/A" %></td>
                                <td>
                                    <form action="AdminController" method="POST" onsubmit="return confirm('WARNING: Deleting a customer will also delete their vehicles, bookings, and invoices. Proceed?');" style="margin:0;">
                                        <input type="hidden" name="action" value="delete-customer">
                                        <input type="hidden" name="customerId" value="<%= c.getId() %>">
                                        <button type="submit" class="btn-ripple" style="padding:4px 10px; font-size:11px; margin-top:0; background:var(--danger); color:#white;"><i class="fas fa-trash-alt"></i> Delete</button>
                                    </form>
                                </td>
                            </tr>
                    <% 
                        } 
                    } 
                    %>
                </tbody>
            </table>
        </div>
    </div>

    <footer style="background:var(--footer-bg); color:#white; text-align:center; padding: 20px; margin-top:40px;">
        <p>© 2026 Vehicle Care. Admin Center.</p>
    </footer>

    <script src="js/notifications.js"></script>
    <script src="js/script.js"></script>
    <script>
        function filterAdminTable() {
            const input = document.getElementById("search-input");
            const filter = input.value.toUpperCase();
            const table = document.getElementById("admin-table");
            const rows = table.getElementsByClassName("admin-row");

            for (let i = 0; i < rows.length; i++) {
                const cells = rows[i].getElementsByTagName("td");
                let matched = false;
                for (let j = 0; j < cells.length; j++) {
                    if (cells[j].innerText.toUpperCase().indexOf(filter) > -1) {
                        matched = true;
                        break;
                    }
                }
                rows[i].style.display = matched ? "" : "none";
            }
        }

        document.addEventListener("DOMContentLoaded", () => {
            <% if (request.getParameter("error") != null) { %>
                window.Toast.show("<%= request.getParameter("error") %>", "error");
            <% } %>
            <% if (request.getParameter("msg") != null) { %>
                window.Toast.show("<%= request.getParameter("msg") %>", "success");
            <% } %>
        });
    </script>
</body>
</html>
