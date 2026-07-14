<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.vehicleservice.model.User" %>
<%@ page import="com.vehicleservice.model.Vehicle" %>
<%@ page import="com.vehicleservice.model.Booking" %>
<%@ page import="com.vehicleservice.model.Document" %>
<%@ page import="com.vehicleservice.model.VehicleHealth" %>
<%@ page import="com.vehicleservice.dao.VehicleDAO" %>
<%@ page import="com.vehicleservice.dao.BookingDAO" %>
<%@ page import="com.vehicleservice.dao.DocumentDAO" %>
<%@ page import="com.vehicleservice.dao.VehicleHealthDAO" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    VehicleDAO vehicleDAO = new VehicleDAO();
    BookingDAO bookingDAO = new BookingDAO();
    DocumentDAO documentDAO = new DocumentDAO();
    VehicleHealthDAO healthDAO = new VehicleHealthDAO();

    List<Vehicle> vehicles = vehicleDAO.getVehiclesByCustomer(user.getId());
    List<Booking> bookings = bookingDAO.getBookingsByCustomer(user.getId());
    List<Document> userDocs = documentDAO.getDocumentsByUser(user.getId());

    // Calculate Profile Completion
    int profilePct = 0;
    if (user.getName() != null && !user.getName().isEmpty()) profilePct += 20;
    if (user.getPhone() != null && !user.getPhone().isEmpty()) profilePct += 20;
    if (user.getEmail() != null && !user.getEmail().isEmpty()) profilePct += 20;
    if (user.getProfilePic() != null && !user.getProfilePic().isEmpty()) profilePct += 10;
    
    // Check DL and Aadhar
    boolean hasDL = false;
    boolean hasAadhar = false;
    for (Document d : userDocs) {
        if ("DL".equalsIgnoreCase(d.getDocumentType())) { hasDL = true; profilePct += 15; }
        if ("AADHAR".equalsIgnoreCase(d.getDocumentType())) { hasAadhar = true; profilePct += 15; }
    }

    // Latest Active Booking
    Booking activeBooking = null;
    for (Booking b : bookings) {
        if (!"DELIVERED".equalsIgnoreCase(b.getStatus()) && !"CANCELLED".equalsIgnoreCase(b.getStatus())) {
            activeBooking = b;
            break;
        }
    }

    // Count statistics
    int vehicleCount = vehicles.size();
    int pendingPaymentsCount = 0;
    
    // Check pending invoices
    for (Booking b : bookings) {
        if ("COMPLETED".equalsIgnoreCase(b.getStatus())) {
            com.vehicleservice.model.Invoice invoice = new com.vehicleservice.dao.InvoiceDAO().getInvoiceByBookingId(b.getId());
            if (invoice != null && "UNPAID".equalsIgnoreCase(invoice.getPaymentStatus())) {
                pendingPaymentsCount++;
            }
        }
    }

    List<String> activities = bookingDAO.getRecentActivities();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Dashboard - VehicleCare</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="css/style.css">
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
            <a href="dashboard.jsp" class="active">Dashboard</a>
            <a href="myvehicles.jsp">My Vehicles</a>
            <a href="bookservice.jsp">Book Service</a>
            <a href="profile.jsp">My Profile</a>
            <a href="AuthController?action=logout" class="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a>
            <button class="theme-toggle-btn" id="theme-toggle"><i class="fas fa-moon"></i></button>
        </nav>
    </header>

    <div class="glass-container">
        <!-- Dashboard Header Summary -->
        <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:15px; margin-bottom:30px;">
            <div>
                <h2>Welcome Back, <%= user.getName() %>!</h2>
                <p style="color:var(--text-muted); font-size:14px;">Here is the current diagnostic health status of your garage.</p>
            </div>
            <!-- Profile completion progress wheel -->
            <div style="display:flex; align-items:center; gap:12px; background:var(--card-bg); border:1px solid var(--card-border); padding:10px 20px; border-radius:12px; box-shadow:var(--glass-shadow);">
                <div style="text-align:right;">
                    <div style="font-size:11px; font-weight:600; color:var(--text-muted);">Profile Completion</div>
                    <div style="font-size:16px; font-weight:700; color:var(--primary);"><%= profilePct %>% Complete</div>
                </div>
                <div style="width:50px; height:50px; border-radius:50%; background:conic-gradient(var(--primary) <%= profilePct * 3.6 %>deg, var(--border-color) 0deg); display:flex; align-items:center; justify-content:center; position:relative;">
                    <div style="width:40px; height:40px; border-radius:50%; background:var(--bg-gradient); position:absolute; z-index:1;"></div>
                    <span style="font-size:11px; font-weight:700; position:relative; z-index:2;"><%= profilePct %>%</span>
                </div>
            </div>
        </div>

        <!-- 4 Count Counters -->
        <div class="dashboard-grid">
            <div class="card">
                <div class="card-header-vss">
                    <span style="font-size:14px; font-weight:600; color:var(--text-muted);">Loyalty Points Balance</span>
                    <div class="card-icon"><i class="fas fa-trophy" style="color:var(--secondary);"></i></div>
                </div>
                <div class="card-value"><%= user.getLoyaltyPoints() %> pts</div>
                <div style="font-size:11px; color:var(--text-muted); margin-top:8px;">Earn 10% points on online invoice checkouts.</div>
            </div>
            <div class="card">
                <div class="card-header-vss">
                    <span style="font-size:14px; font-weight:600; color:var(--text-muted);">Registered Vehicles</span>
                    <div class="card-icon"><i class="fas fa-car" style="color:var(--primary);"></i></div>
                </div>
                <div class="card-value"><%= vehicleCount %> Vehicles</div>
                <div style="font-size:11px; color:var(--text-muted); margin-top:8px;"><a href="myvehicles.jsp" style="color:var(--primary); text-decoration:none; font-weight:600;">Manage Garage <i class="fas fa-chevron-right"></i></a></div>
            </div>
            <div class="card">
                <div class="card-header-vss">
                    <span style="font-size:14px; font-weight:600; color:var(--text-muted);">Pending Payments</span>
                    <div class="card-icon"><i class="fas fa-wallet" style="color:var(--danger);"></i></div>
                </div>
                <div class="card-value" style="color: <%= pendingPaymentsCount > 0 ? "var(--danger)" : "var(--text-color)" %>"><%= pendingPaymentsCount %> Unpaid</div>
                <div style="font-size:11px; color:var(--text-muted); margin-top:8px;"><a href="history.jsp" style="color:var(--primary); text-decoration:none; font-weight:600;">View invoices <i class="fas fa-chevron-right"></i></a></div>
            </div>
        </div>

        <!-- Active Service Tracker Timeline (if exists) -->
        <% if (activeBooking != null) { 
            String status = activeBooking.getStatus();
            int currentStep = 1;
            if ("RECEIVED".equalsIgnoreCase(status)) currentStep = 2;
            if ("INSPECTION".equalsIgnoreCase(status)) currentStep = 3;
            if ("REPAIR_STARTED".equalsIgnoreCase(status)) currentStep = 4;
            if ("WAITING_PARTS".equalsIgnoreCase(status)) currentStep = 5;
            if ("QUALITY_CHECK".equalsIgnoreCase(status)) currentStep = 6;
            if ("READY".equalsIgnoreCase(status)) currentStep = 7;
            if ("DELIVERED".equalsIgnoreCase(status)) currentStep = 8;
        %>
            <div class="card" style="margin-bottom:30px;">
                <h3><i class="fas fa-route text-primary"></i> Active Job Card Tracker: Booking #<%= activeBooking.getId() %></h3>
                <div style="font-size:13px; margin-top:5px; color:var(--text-muted);">
                    Vehicle: <strong><%= activeBooking.getVehicleBrand() %> <%= activeBooking.getVehicleModel() %></strong> (<%= activeBooking.getVehicleNumber() %>) | Package: <strong><%= activeBooking.getPackageName() %></strong>
                </div>

                <!-- Animated tracker line -->
                <div class="timeline">
                    <div class="timeline-progress" style="width: <%= ((currentStep - 1) / 7.0) * 100 %>%"></div>
                    
                    <div class="timeline-step <%= currentStep >= 1 ? "completed" : "" %> <%= currentStep == 1 ? "active" : "" %>">
                        <div class="step-icon"><i class="fas fa-calendar-check"></i></div>
                        <span class="step-label">Booked</span>
                    </div>
                    <div class="timeline-step <%= currentStep >= 2 ? "completed" : "" %> <%= currentStep == 2 ? "active" : "" %>">
                        <div class="step-icon"><i class="fas fa-key"></i></div>
                        <span class="step-label">Received</span>
                    </div>
                    <div class="timeline-step <%= currentStep >= 3 ? "completed" : "" %> <%= currentStep == 3 ? "active" : "" %>">
                        <div class="step-icon"><i class="fas fa-search"></i></div>
                        <span class="step-label">Inspection</span>
                    </div>
                    <div class="timeline-step <%= currentStep >= 4 ? "completed" : "" %> <%= currentStep == 4 ? "active" : "" %>">
                        <div class="step-icon"><i class="fas fa-wrench"></i></div>
                        <span class="step-label">Repair</span>
                    </div>
                    <div class="timeline-step <%= currentStep >= 5 ? "completed" : "" %> <%= currentStep == 5 ? "active" : "" %>">
                        <div class="step-icon"><i class="fas fa-hourglass-half"></i></div>
                        <span class="step-label">Parts Delay</span>
                    </div>
                    <div class="timeline-step <%= currentStep >= 6 ? "completed" : "" %> <%= currentStep == 6 ? "active" : "" %>">
                        <div class="step-icon"><i class="fas fa-shield-alt"></i></div>
                        <span class="step-label">QC Check</span>
                    </div>
                    <div class="timeline-step <%= currentStep >= 7 ? "completed" : "" %> <%= currentStep == 7 ? "active" : "" %>">
                        <div class="step-icon"><i class="fas fa-star"></i></div>
                        <span class="step-label">Ready</span>
                    </div>
                </div>

                <div style="text-align:center; font-size:14px; font-weight:600; color:var(--primary);">
                    <% if ("WAITING_PARTS".equalsIgnoreCase(status)) { %>
                        <i class="fas fa-exclamation-circle text-warning"></i> Service is temporarily delayed waiting for stock replacement.
                    <% } else if ("READY".equalsIgnoreCase(status)) { %>
                        <i class="fas fa-check-circle text-success"></i> Your vehicle is sparkling and polished! Click below to pay or retrieve it.
                    <% } else { %>
                        <i class="fas fa-spinner fa-spin"></i> Our mechanics are currently working on your vehicle status: <span style="text-transform: uppercase;"><%= status.replace("_", " ") %></span>
                    <% } %>
                </div>
            </div>
        <% } %>

        <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 30px; align-items: start;">
            <!-- Left Panel: Diagnostics and Reminders -->
            <div>
                <!-- Vehicle Health Report -->
                <h3><i class="fas fa-stethoscope text-primary"></i> Vehicle Diagnostics Health Report</h3>
                <% if (vehicles.isEmpty()) { %>
                    <div class="card" style="margin-top:15px; padding: 25px; text-align:center;">
                        <p style="color:var(--text-muted);">Please register a vehicle to generate health diagnostic metrics.</p>
                    </div>
                <% } else { 
                    Vehicle first = vehicles.get(0);
                    VehicleHealth health = healthDAO.getHealthByVehicle(first.getId());
                %>
                    <div class="card" style="margin-top: 15px;">
                        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px;">
                            <h4><%= first.getBrand() %> <%= first.getModel() %> (<%= first.getVehicleNumber() %>)</h4>
                            <span class="badge" style="background: var(--success); color:#fff; padding: 4px 10px; border-radius: 4px; font-weight:600;">Overall Health: <%= health.getOverallHealth() %>%</span>
                        </div>
                        <div style="display:grid; grid-template-columns:1fr 1fr; gap:20px;">
                            
                            <!-- Battery -->
                            <div class="health-meter">
                                <div class="health-label-row">
                                    <span>Battery Charge</span>
                                    <span><%= health.getBatteryHealth() %>%</span>
                                </div>
                                <div class="progress-bar-vss">
                                    <div class="progress-fill <%= health.getBatteryHealth() > 80 ? "green" : (health.getBatteryHealth() > 50 ? "yellow" : "red") %>" style="width: <%= health.getBatteryHealth() %>%"></div>
                                </div>
                            </div>
                            
                            <!-- Engine -->
                            <div class="health-meter">
                                <div class="health-label-row">
                                    <span>Engine Condition</span>
                                    <span><%= health.getEngineCondition() %>%</span>
                                </div>
                                <div class="progress-bar-vss">
                                    <div class="progress-fill <%= health.getEngineCondition() > 80 ? "green" : (health.getEngineCondition() > 50 ? "yellow" : "red") %>" style="width: <%= health.getEngineCondition() %>%"></div>
                                </div>
                            </div>

                            <!-- Brakes -->
                            <div class="health-meter">
                                <div class="health-label-row">
                                    <span>Brake Pad Status</span>
                                    <span><%= health.getBrakeStatus() %>%</span>
                                </div>
                                <div class="progress-bar-vss">
                                    <div class="progress-fill <%= health.getBrakeStatus() > 70 ? "green" : (health.getBrakeStatus() > 40 ? "yellow" : "red") %>" style="width: <%= health.getBrakeStatus() %>%"></div>
                                </div>
                            </div>

                            <!-- Oil -->
                            <div class="health-meter">
                                <div class="health-label-row">
                                    <span>Engine Oil Level</span>
                                    <span><%= health.getOilLevel() %>%</span>
                                </div>
                                <div class="progress-bar-vss">
                                    <div class="progress-fill <%= health.getOilLevel() > 80 ? "green" : (health.getOilLevel() > 50 ? "yellow" : "red") %>" style="width: <%= health.getOilLevel() %>%"></div>
                                </div>
                            </div>

                            <!-- Tyre -->
                            <div class="health-meter">
                                <div class="health-label-row">
                                    <span>Tyre Tread Condition</span>
                                    <span><%= health.getTyreCondition() %>%</span>
                                </div>
                                <div class="progress-bar-vss">
                                    <div class="progress-fill <%= health.getTyreCondition() > 75 ? "green" : (health.getTyreCondition() > 45 ? "yellow" : "red") %>" style="width: <%= health.getTyreCondition() %>%"></div>
                                </div>
                            </div>

                            <!-- Coolant -->
                            <div class="health-meter">
                                <div class="health-label-row">
                                    <span>Coolant Level</span>
                                    <span><%= health.getCoolantLevel() %>%</span>
                                </div>
                                <div class="progress-bar-vss">
                                    <div class="progress-fill <%= health.getCoolantLevel() > 80 ? "green" : (health.getCoolantLevel() > 50 ? "yellow" : "red") %>" style="width: <%= health.getCoolantLevel() %>%"></div>
                                </div>
                            </div>

                        </div>
                    </div>
                <% } %>

                <!-- Document Expiry Reminders -->
                <h3 style="margin-top:30px;"><i class="fas fa-bell text-primary"></i> Service Document Warnings</h3>
                <div style="margin-top:15px; display:flex; flex-direction:column; gap:10px;">
                    <%
                        boolean hasAlerts = false;
                        // Expiry checks for user DL
                        for (Document d : userDocs) {
                            if (!d.isValid()) {
                                hasAlerts = true;
                    %>
                                <div class="card" style="border-left: 5px solid var(--danger); padding: 12px 20px; display:flex; justify-content:space-between; align-items:center;">
                                    <span><i class="fas fa-exclamation-circle text-danger"></i> Your Document <strong><%= d.getDocumentType() %></strong> (File: <%= d.getFileName() %>) Expired on <strong><%= d.getExpiryDate() %></strong>!</span>
                                    <a href="profile.jsp" class="btn-ripple" style="padding:4px 10px; font-size:11px; margin-top:0; background:var(--danger); color:#white;">Replace</a>
                                </div>
                    <%
                            }
                        }

                        // Check vehicle documents
                        for (Vehicle v : vehicles) {
                            List<Document> vDocs = documentDAO.getDocumentsByVehicle(v.getId());
                            boolean hasRC = false;
                            for (Document vd : vDocs) {
                                if ("RC".equalsIgnoreCase(vd.getDocumentType())) hasRC = true;
                                if (!vd.isValid()) {
                                    hasAlerts = true;
                    %>
                                    <div class="card" style="border-left: 5px solid var(--danger); padding: 12px 20px; display:flex; justify-content:space-between; align-items:center;">
                                        <span><i class="fas fa-exclamation-circle text-danger"></i> Vehicle <%= v.getVehicleNumber() %> <strong><%= vd.getDocumentType() %></strong> expired on <strong><%= vd.getExpiryDate() %></strong>!</span>
                                        <a href="myvehicles.jsp" class="btn-ripple" style="padding:4px 10px; font-size:11px; margin-top:0; background:var(--danger); color:#white;">Replace</a>
                                    </div>
                    <%
                                }
                            }
                            if (!hasRC) {
                                hasAlerts = true;
                    %>
                                <div class="card" style="border-left: 5px solid var(--warning); padding: 12px 20px; display:flex; justify-content:space-between; align-items:center;">
                                    <span><i class="fas fa-exclamation-triangle text-warning"></i> Vehicle Registration Certificate (RC) document is missing for <%= v.getVehicleNumber() %>!</span>
                                    <a href="myvehicles.jsp" class="btn-ripple" style="padding:4px 10px; font-size:11px; margin-top:0; background:var(--warning); color:#white;">Upload</a>
                                </div>
                    <%
                            }
                        }

                        if (!hasAlerts) {
                    %>
                            <div class="card" style="padding:15px; border-left: 5px solid var(--success); color: var(--success); font-weight:600; font-size:13px;">
                                <i class="fas fa-check-double"></i> Excellent! All registration certificates, driving licenses, and PUC documents are active and valid.
                            </div>
                    <% } %>
                </div>
            </div>

            <!-- Right Panel: Activity Timeline & Quick Actions -->
            <div>
                <!-- Quick Actions -->
                <h3>Quick Shortcuts</h3>
                <div class="card" style="margin-top: 15px; display:flex; flex-direction:column; gap:12px;">
                    <a href="bookservice.jsp" class="btn-ripple" style="width:100%;"><i class="fas fa-calendar-plus"></i> Book Service</a>
                    <a href="myvehicles.jsp" class="btn-ripple" style="width:100%; background:var(--info); color:#white;"><i class="fas fa-car"></i> Manage Garage</a>
                    <a href="history.jsp" class="btn-ripple" style="width:100%; background:var(--success); color:#white;"><i class="fas fa-receipt"></i> Billing & History</a>
                </div>

                <!-- Recent Activities Timeline -->
                <h3 style="margin-top:30px;"><i class="fas fa-history text-primary"></i> Recent Activities</h3>
                <div class="card" style="margin-top:15px; padding: 20px;">
                    <% if (activities.isEmpty()) { %>
                        <p style="font-size:12px; color:var(--text-muted); text-align:center;">No recent actions recorded.</p>
                    <% } else { %>
                        <ul style="width:100%; margin:0; padding:0; display:flex; flex-direction:column; gap:15px;">
                            <% for (String act : activities) { %>
                                <li style="font-size:12px; border-bottom:1px solid var(--border-color); padding-bottom:8px; display:flex; gap:10px; align-items:start;">
                                    <i class="fas fa-check-circle" style="color:var(--success); margin-top:3px;"></i>
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
        <p>© 2026 Vehicle Care. Dashboard Portal.</p>
    </footer>

    <script src="js/notifications.js"></script>
    <script src="js/script.js"></script>
    <script>
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
