<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.vehicleservice.model.User" %>
<%@ page import="com.vehicleservice.model.Booking" %>
<%@ page import="com.vehicleservice.model.Invoice" %>
<%@ page import="com.vehicleservice.dao.BookingDAO" %>
<%@ page import="com.vehicleservice.dao.InvoiceDAO" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    BookingDAO bookingDAO = new BookingDAO();
    InvoiceDAO invoiceDAO = new InvoiceDAO();
    List<Booking> bookings = bookingDAO.getBookingsByCustomer(user.getId());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Service History - VehicleCare</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="css/style.css">
    <style>
        .history-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
            font-size: 13px;
        }
        .history-table th, .history-table td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid var(--border-color);
        }
        .history-table th {
            background: rgba(13, 110, 253, 0.1);
            font-weight: 600;
        }
        .history-table tbody tr:hover {
            background: rgba(255, 255, 255, 0.05);
        }
        .status-badge {
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
        }
        .status-badge.pending { background: rgba(255, 193, 7, 0.2); color: #b7791f; }
        .status-badge.received { background: rgba(13, 110, 253, 0.2); color: #0d6efd; }
        .status-badge.inspection { background: rgba(13, 202, 240, 0.2); color: #0dcaf0; }
        .status-badge.repair_started { background: rgba(255, 99, 132, 0.2); color: #ff5e7e; }
        .status-badge.waiting_parts { background: rgba(108, 117, 125, 0.2); color: #6c757d; }
        .status-badge.quality_check { background: rgba(111, 66, 193, 0.2); color: #6f42c1; }
        .status-badge.ready { background: rgba(25, 135, 84, 0.2); color: #198754; }
        .status-badge.delivered { background: rgba(33, 37, 41, 0.2); color: var(--text-color); }
        .status-badge.cancelled { background: rgba(220, 53, 69, 0.2); color: #dc3545; }
    </style>
</head>
<body>

    <!-- Sticky Header -->
    <header>
        <h1>
            <img src="images/logo.png" alt="Logo" class="logo" onerror="this.src='https://cdn-icons-png.flaticon.com/512/3202/3202926.png'">
            Vehicle Care
        </h1>
        <nav>
            <a href="index.jsp">Home</a>
            <a href="dashboard.jsp">Dashboard</a>
            <a href="myvehicles.jsp">My Vehicles</a>
            <a href="bookservice.jsp">Book Service</a>
            <a href="profile.jsp">My Profile</a>
            <a href="AuthController?action=logout" class="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a>
            <button class="theme-toggle-btn" id="theme-toggle"><i class="fas fa-moon"></i></button>
        </nav>
    </header>

    <div class="glass-container">
        <h2 style="margin-bottom: 25px;"><i class="fas fa-history text-primary"></i> Service Appointment Records</h2>

        <!-- Interactive Search Bar -->
        <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:15px; margin-bottom:20px;">
            <div style="position:relative; width:300px;">
                <input type="text" id="search-input" class="form-control" placeholder="Search by plate, status, model..." onkeyup="filterHistoryTable()" style="padding-left:35px;">
                <i class="fas fa-search" style="position:absolute; left:12px; top:15px; color:var(--text-muted);"></i>
            </div>
            <div style="font-size:13px; color:var(--text-muted);">
                Total Services History: <strong><%= bookings.size() %> entries</strong>
            </div>
        </div>

        <!-- History Table -->
        <div style="overflow-x:auto;">
            <table class="history-table" id="history-table">
                <thead>
                    <tr>
                        <th>Booking ID</th>
                        <th>Vehicle Number</th>
                        <th>Model Name</th>
                        <th>Service Package</th>
                        <th>Appointment Date</th>
                        <th>Assigned Mechanic</th>
                        <th>Bill Cost</th>
                        <th>Status</th>
                        <th>Invoice / Payment</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (bookings.isEmpty()) { %>
                        <tr>
                            <td colspan="9" style="text-align:center; padding: 30px;">
                                <i class="fas fa-calendar-times" style="font-size:36px; color:var(--text-muted); margin-bottom:10px;"></i>
                                <p>No appointment records found.</p>
                            </td>
                        </tr>
                    <% } else { 
                        for (Booking b : bookings) { 
                            Invoice inv = invoiceDAO.getInvoiceByBookingId(b.getId());
                    %>
                            <tr class="history-row">
                                <td><strong>#<%= b.getId() %></strong></td>
                                <td class="search-cell-plate" style="text-transform:uppercase;"><%= b.getVehicleNumber() %></td>
                                <td><%= b.getVehicleBrand() %> <%= b.getVehicleModel() %></td>
                                <td class="search-cell-package"><%= b.getPackageName() %></td>
                                <td><%= b.getBookingDate() %> (<%= b.getPreferredTime().substring(0, 8) %>)</td>
                                <td><%= b.getMechanicName() != null ? b.getMechanicName() : "<span style='color:var(--text-muted);'>Not Assigned</span>" %></td>
                                <td>₹<%= String.format("%,.2f", b.getTotalCost()) %></td>
                                <td class="search-cell-status">
                                    <span class="status-badge <%= b.getStatus().toLowerCase() %>">
                                        <%= b.getStatus().replace("_", " ") %>
                                    </span>
                                </td>
                                <td>
                                    <% if (inv != null) { %>
                                        <a href="invoice.jsp?bookingId=<%= b.getId() %>" class="btn-ripple" style="padding: 5px 12px; font-size:11px; margin-top:0; display:inline-flex; align-items:center; gap:5px; background: <%= "PAID".equalsIgnoreCase(inv.getPaymentStatus()) ? "var(--success)" : "var(--danger)" %>; color:#white;">
                                            <% if ("PAID".equalsIgnoreCase(inv.getPaymentStatus())) { %>
                                                <i class="fas fa-file-pdf"></i> Paid Invoice
                                            <% } else { %>
                                                <i class="fas fa-wallet"></i> Pay ₹<%= String.format("%,.2f", inv.getTotalAmount()) %>
                                            <% } %>
                                        </a>
                                    <% } else { %>
                                        <span style="font-size:11px; color:var(--text-muted); font-style:italic;"><i class="fas fa-hourglass-half"></i> Awaiting completion</span>
                                    <% } %>
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
        <p>© 2026 Vehicle Care. History Portal.</p>
    </footer>

    <script src="js/notifications.js"></script>
    <script src="js/script.js"></script>
    <script>
        function filterHistoryTable() {
            const input = document.getElementById("search-input");
            const filter = input.value.toUpperCase();
            const table = document.getElementById("history-table");
            const rows = table.getElementsByClassName("history-row");

            for (let i = 0; i < rows.length; i++) {
                const plate = rows[i].getElementsByClassName("search-cell-plate")[0].innerText;
                const pkg = rows[i].getElementsByClassName("search-cell-package")[0].innerText;
                const status = rows[i].getElementsByClassName("search-cell-status")[0].innerText;
                
                if (plate.toUpperCase().indexOf(filter) > -1 || 
                    pkg.toUpperCase().indexOf(filter) > -1 || 
                    status.toUpperCase().indexOf(filter) > -1) {
                    rows[i].style.display = "";
                } else {
                    rows[i].style.display = "none";
                }
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
