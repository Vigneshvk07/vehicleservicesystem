<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.vehicleservice.model.User" %>
<%@ page import="com.vehicleservice.dao.UserDAO" %>
<%@ page import="com.vehicleservice.dao.VehicleDAO" %>
<%@ page import="com.vehicleservice.dao.BookingDAO" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"ADMIN".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/error-404.jsp");
        return;
    }

    UserDAO userDAO = new UserDAO();
    VehicleDAO vehicleDAO = new VehicleDAO();
    BookingDAO bookingDAO = new BookingDAO();

    int totalCustomers = userDAO.getCustomerCount();
    int totalVehicles = vehicleDAO.getVehicleCount();
    int todayBookings = bookingDAO.getTodayBookingsCount();
    int completedServices = bookingDAO.getCompletedServicesCount();
    int pendingServices = bookingDAO.getPendingServicesCount();
    double revenue = bookingDAO.getRevenue();

    // Query active status counts for the doughnut chart
    List<com.vehicleservice.model.Booking> allBookings = bookingDAO.getAllBookings();
    int pending = 0, approved = 0, inProgress = 0, completed = 0;
    for (com.vehicleservice.model.Booking b : allBookings) {
        if ("PENDING".equalsIgnoreCase(b.getStatus())) pending++;
        else if ("APPROVED".equalsIgnoreCase(b.getStatus()) || "RECEIVED".equalsIgnoreCase(b.getStatus()) || "INSPECTION".equalsIgnoreCase(b.getStatus())) approved++;
        else if ("IN_PROGRESS".equalsIgnoreCase(b.getStatus()) || "REPAIR_STARTED".equalsIgnoreCase(b.getStatus()) || "WAITING_PARTS".equalsIgnoreCase(b.getStatus()) || "QUALITY_CHECK".equalsIgnoreCase(b.getStatus())) inProgress++;
        else if ("COMPLETED".equalsIgnoreCase(b.getStatus()) || "DELIVERED".equalsIgnoreCase(b.getStatus())) completed++;
    }

    List<String> activities = bookingDAO.getRecentActivities();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Administrator Dashboard - VehicleCare</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="css/style.css">
    <!-- ChartJS Import -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        .chart-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 12px;
            padding: 20px;
            height: 320px;
            position: relative;
        }
        .admin-quick-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 15px;
            margin-top: 15px;
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
            <a href="admin-dashboard.jsp" class="active">Overview</a>
            <a href="admin-bookings.jsp">Approve Bookings</a>
            <a href="admin-customers.jsp">Customers</a>
            <a href="admin-parts.jsp">Parts Inventory</a>
            <a href="admin-mechanics.jsp">Mechanics</a>
            <a href="admin-reports.jsp">Analytics & Reports</a>
            <a href="AuthController?action=logout" class="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a>
            <button class="theme-toggle-btn" id="theme-toggle"><i class="fas fa-moon"></i></button>
        </nav>
    </header>

    <div class="glass-container">
        <h2 style="margin-bottom: 25px;"><i class="fas fa-chart-line text-primary"></i> Analytical Overview Panel</h2>

        <!-- Statistical Cards Grid -->
        <div class="dashboard-grid" style="grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));">
            
            <div class="card">
                <div class="card-header-vss">
                    <span style="font-size:13px; font-weight:600; color:var(--text-muted);">Total Customers</span>
                    <div class="card-icon"><i class="fas fa-users" style="color:var(--primary);"></i></div>
                </div>
                <div class="card-value"><%= totalCustomers %> Users</div>
            </div>

            <div class="card">
                <div class="card-header-vss">
                    <span style="font-size:13px; font-weight:600; color:var(--text-muted);">Vehicles Registered</span>
                    <div class="card-icon"><i class="fas fa-car" style="color:var(--info);"></i></div>
                </div>
                <div class="card-value"><%= totalVehicles %> Vehicles</div>
            </div>

            <div class="card">
                <div class="card-header-vss">
                    <span style="font-size:13px; font-weight:600; color:var(--text-muted);">Today's Bookings</span>
                    <div class="card-icon"><i class="fas fa-calendar-day" style="color:var(--warning);"></i></div>
                </div>
                <div class="card-value"><%= todayBookings %> Booked</div>
            </div>

            <div class="card">
                <div class="card-header-vss">
                    <span style="font-size:13px; font-weight:600; color:var(--text-muted);">Total Revenue Check</span>
                    <div class="card-icon"><i class="fas fa-indian-rupee-sign" style="color:var(--success);"></i></div>
                </div>
                <div class="card-value">₹<%= String.format("%,.2f", revenue) %></div>
            </div>

        </div>

        <!-- Charts Grid Section -->
        <div class="dashboard-grid" style="grid-template-columns: 1.2fr 1.8fr; gap:25px; margin-top:20px;">
            <!-- Doughnut: Status -->
            <div class="chart-card">
                <h4 style="margin-bottom:15px; font-size:14px;"><i class="fas fa-chart-pie"></i> Appointment Status Division</h4>
                <div style="height:230px; position:relative;">
                    <!-- Embedded parameters for charts.js -->
                    <canvas id="statusChart" 
                            data-pending="<%= pending %>" 
                            data-approved="<%= approved %>" 
                            data-in-progress="<%= inProgress %>" 
                            data-completed="<%= completed %>"></canvas>
                </div>
            </div>

            <!-- Line: Revenue -->
            <div class="chart-card">
                <h4 style="margin-bottom:15px; font-size:14px;"><i class="fas fa-chart-area"></i> Revenue Operations (Line Plot)</h4>
                <div style="height:230px; position:relative;">
                    <canvas id="revenueChart" data-monthly="[18000, 32000, 22000, <%= revenue %>, 0, 0, 0]"></canvas>
                </div>
            </div>
        </div>

        <!-- Quick Administration Actions & Activities Timeline -->
        <div style="display:grid; grid-template-columns: 1fr 1fr; gap:30px; margin-top:30px; align-items:start;">
            <!-- Quick Actions -->
            <div>
                <h3>Admin Shortcut Keys</h3>
                <div class="admin-quick-grid">
                    <a href="admin-bookings.jsp" class="btn-ripple" style="width:100%;"><i class="fas fa-tasks"></i> Pending Bookings</a>
                    <a href="admin-parts.jsp" class="btn-ripple" style="width:100%; background:var(--warning); color:#333;"><i class="fas fa-box-open"></i> Spare Parts</a>
                    <a href="admin-mechanics.jsp" class="btn-ripple" style="width:100%; background:var(--info); color:#white;"><i class="fas fa-user-cog"></i> Mechanics Setup</a>
                    <a href="admin-reports.jsp" class="btn-ripple" style="width:100%; background:var(--success); color:#white;"><i class="fas fa-file-excel"></i> CSV Reports</a>
                </div>
            </div>

            <!-- Activities -->
            <div>
                <h3>System Transaction Activities</h3>
                <div class="card" style="margin-top:15px; padding: 20px;">
                    <% if (activities.isEmpty()) { %>
                        <p style="font-size:12px; color:var(--text-muted); text-align:center;">No activities logged yet.</p>
                    <% } else { %>
                        <ul style="width:100%; margin:0; padding:0; display:flex; flex-direction:column; gap:12px;">
                            <% for (String act : activities) { %>
                                <li style="font-size:11px; border-bottom:1px solid var(--border-color); padding-bottom:6px; display:flex; gap:10px; align-items:start;">
                                    <i class="fas fa-cog fa-spin" style="color:var(--primary); margin-top:2px;"></i>
                                    <div><%= act %></div>
                                </li>
                            <% } %>
                        </ul>
                    <% } %>
                </div>
            </div>
        </div>

    </div>

    <footer style="background:var(--footer-bg); color:#white; text-align:center; padding: 20px; margin-top:40px;">
        <p>© 2026 Vehicle Care. Administrative Center.</p>
    </footer>

    <!-- Chart rendering triggers -->
    <script src="js/notifications.js"></script>
    <script src="js/script.js"></script>
    <script src="js/charts.js"></script>
</body>
</html>
