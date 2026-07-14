<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.vehicleservice.model.User" %>
<%@ page import="com.vehicleservice.model.Vehicle" %>
<%@ page import="com.vehicleservice.model.Booking" %>
<%@ page import="com.vehicleservice.dao.VehicleDAO" %>
<%@ page import="com.vehicleservice.dao.BookingDAO" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    String vehicleType = "car";
    String serviceStatus = "RECEIVED";
    String vehicleNumber = "DEMO-001";
    String vehicleModel = "Sedan Model S";
    String ownerName = "Guest Visitor";
    boolean hasActiveBooking = false;

    if (user != null) {
        ownerName = user.getName();
        // Fetch user vehicles
        List<Vehicle> list = new VehicleDAO().getVehiclesByCustomer(user.getId());
        if (!list.isEmpty()) {
            Vehicle first = list.get(0);
            vehicleType = first.getType();
            vehicleNumber = first.getVehicleNumber();
            vehicleModel = first.getBrand() + " " + first.getModel();
            
            // Check active bookings
            List<Booking> bookings = new BookingDAO().getBookingsByCustomer(user.getId());
            if (!bookings.isEmpty()) {
                Booking active = bookings.get(0);
                serviceStatus = active.getStatus();
                hasActiveBooking = true;
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Vehicle Service & Maintenance System</title>
    <!-- Fonts and Icons -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="css/style.css">
    <!-- ChartJS for dashboard statistics integration -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        .vibrate-idle {
            animation: vibrate 0.15s linear infinite;
        }
        @keyframes vibrate {
            0% { transform: translate(-50%, 0) rotate(0deg); }
            25% { transform: translate(-50.5%, 0.5px) rotate(0.2deg); }
            50% { transform: translate(-50%, -0.5px) rotate(-0.2deg); }
            75% { transform: translate(-49.5%, 0.5px) rotate(0deg); }
            100% { transform: translate(-50%, 0) rotate(0deg); }
        }
        .shine-polish::after {
            content: '';
            position: absolute;
            top: 0;
            left: -150%;
            width: 50%;
            height: 100%;
            background: linear-gradient(to right, rgba(255,255,255,0) 0%, rgba(255,255,255,0.7) 50%, rgba(255,255,255,0) 100%);
            transform: skewX(-25deg);
            animation: shine 2.5s infinite;
        }
        @keyframes shine {
            0% { left: -150%; }
            50% { left: 150%; }
            100% { left: 150%; }
        }
        .demo-controls {
            display: flex;
            justify-content: center;
            flex-wrap: wrap;
            gap: 15px;
            margin-top: 15px;
            background: rgba(255,255,255,0.05);
            padding: 15px;
            border-radius: 12px;
            border: 1px solid var(--card-border);
        }
        .demo-btn {
            background: rgba(13, 110, 253, 0.15);
            color: var(--text-color);
            border: 1px solid var(--primary);
            padding: 6px 12px;
            border-radius: 6px;
            font-size: 13px;
            cursor: pointer;
            transition: 0.3s;
        }
        .demo-btn:hover, .demo-btn.active {
            background: var(--primary);
            color: #fff;
        }
    </style>
</head>
<body>

    <!-- Sticky Header Navbar -->
    <header>
        <h1>
            <img src="images/logo.png" alt="Logo" class="logo" onerror="this.src='https://cdn-icons-png.flaticon.com/512/3202/3202926.png'">
            Vehicle Care
        </h1>
        <nav>
            <a href="index.jsp" class="active">Home</a>
            <% if (user == null) { %>
                <a href="login.jsp">Login</a>
                <a href="register.jsp">Register</a>
            <% } else { %>
                <% if ("ADMIN".equalsIgnoreCase(user.getRole())) { %>
                    <a href="admin-dashboard.jsp">Dashboard</a>
                    <a href="admin-bookings.jsp">Appointments</a>
                <% } else { %>
                    <a href="dashboard.jsp">Dashboard</a>
                    <a href="myvehicles.jsp">My Vehicles</a>
                    <a href="bookservice.jsp">Book Service</a>
                <% } %>
                <a href="profile.jsp">My Profile</a>
                <a href="AuthController?action=logout" class="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a>
            <% } %>
            <a href="contact.jsp">Support</a>
            <button class="theme-toggle-btn" id="theme-toggle"><i class="fas fa-moon"></i></button>
        </nav>
    </header>

    <!-- Hero Showcase Section -->
    <section class="hero">
        <h2>Premium Vehicle Maintenance Services</h2>
        <p>Book vehicle inspections online, upload documents, track real-time workshop repair timelines, and download certified GST invoices.</p>
        <% if (user == null) { %>
            <a href="register.jsp" class="btn-ripple"><i class="fas fa-user-plus"></i> Join Us Now</a>
        <% } else { %>
            <a href="bookservice.jsp" class="btn-ripple"><i class="fas fa-calendar-check"></i> Book a Service Appointment</a>
        <% } %>
    </section>

    <!-- Realistic Animated Garage Arena -->
    <div class="glass-container">
        <h3 class="section-title" style="text-align: center; margin-bottom: 10px;">
            <i class="fas fa-warehouse text-primary"></i> VSS Live Garage Tracker
        </h3>
        <p style="text-align: center; margin-bottom: 25px; color: var(--text-muted);">
            <% if (user != null && hasActiveBooking) { %>
                Displaying real-time updates for <strong><%= ownerName %></strong>'s registered <strong><%= vehicleModel %></strong> (<%= vehicleNumber %>).
            <% } else { %>
                Interact with the simulation panel below to preview our mechanical service steps!
            <% } %>
        </p>

        <!-- Simulated Garage Box -->
        <div class="garage-canvas-container" id="garage-container">
            <div class="service-bay"></div>
            <div class="hydraulic-lift"></div>
            <!-- Dynamic Vector Vehicle -->
            <div class="vehicle-avatar" id="vehicle-avatar"></div>
        </div>

        <!-- Personalization Plate Info -->
        <div class="card" style="max-width: 600px; margin: 0 auto 25px auto;">
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px; font-size: 14px;">
                <div><strong>Owner Name:</strong> <span id="plate-owner"><%= ownerName %></span></div>
                <div><strong>Vehicle Class:</strong> <span id="plate-type" style="text-transform: capitalize;"><%= vehicleType %></span></div>
                <div><strong>Vehicle Model:</strong> <span id="plate-model"><%= vehicleModel %></span></div>
                <div><strong>Reg. Number:</strong> <span id="plate-number" style="text-transform: uppercase;"><%= vehicleNumber %></span></div>
                <div><strong>Service Status:</strong> <span id="plate-status" class="badge" style="background:var(--primary); color:#white; padding: 2px 8px; border-radius: 4px;"><%= serviceStatus %></span></div>
                <div><strong>Timeline Slot:</strong> <span id="plate-slot">Preferred Slot</span></div>
            </div>
            <p style="font-size: 11px; color: var(--text-muted); margin-top: 15px; text-align: center;">
                <i class="fas fa-info-circle"></i> Tip: You can click the vehicle to Zoom-In, or click-and-drag across the garage to rotate views.
            </p>
        </div>

        <!-- Live Demo Controls (shown if not logged in or doesn't have active booking) -->
        <div class="demo-controls">
            <div>
                <span style="font-size: 13px; font-weight: 600; margin-right: 10px;">Select Model:</span>
                <button class="demo-btn active" onclick="changeDemoVehicle('car', this)">Car</button>
                <button class="demo-btn" onclick="changeDemoVehicle('bike', this)">Bike</button>
                <button class="demo-btn" onclick="changeDemoVehicle('scooter', this)">Scooter</button>
                <button class="demo-btn" onclick="changeDemoVehicle('truck', this)">Truck</button>
            </div>
            <div style="border-left: 1px solid var(--border-color); padding-left: 15px;">
                <span style="font-size: 13px; font-weight: 600; margin-right: 10px;">Change Status:</span>
                <button class="demo-btn" onclick="changeDemoStatus('BOOKED', this)">Booked</button>
                <button class="demo-btn active" onclick="changeDemoStatus('RECEIVED', this)">Received</button>
                <button class="demo-btn" onclick="changeDemoStatus('IN_PROGRESS', this)">In Service</button>
                <button class="demo-btn" onclick="changeDemoStatus('READY', this)">Ready</button>
                <button class="demo-btn" onclick="changeDemoStatus('DELIVERED', this)">Delivered</button>
            </div>
        </div>
    </div>

    <!-- Interactive Estimation Cost Widget -->
    <div class="glass-container">
        <h3><i class="fas fa-calculator text-primary"></i> Service Cost Estimator</h3>
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-top: 20px;">
            <div>
                <div class="form-group">
                    <label>Select Service Package</label>
                    <select class="form-control" id="cost-estimator" onchange="estimateCost()">
                        <option value="General Service" data-cost="1500">General Service (₹1,500)</option>
                        <option value="Oil Change" data-cost="800">Oil Change (₹800)</option>
                        <option value="Brake Service" data-cost="1200">Brake Service (₹1,200)</option>
                        <option value="Engine Repair" data-cost="7000">Engine Repair (₹7,000)</option>
                        <option value="Wheel Alignment" data-cost="1000">Wheel Alignment (₹1,000)</option>
                        <option value="Water Wash" data-cost="350">Foam Water Wash (₹350)</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Add Optional Add-ons</label>
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px;">
                        <label><input type="checkbox" class="addon-check" value="450" onchange="estimateCost()"> Engine Oil Filter (₹450)</label>
                        <label><input type="checkbox" class="addon-check" value="350" onchange="estimateCost()"> Brake Pads (₹350)</label>
                        <label><input type="checkbox" class="addon-check" value="120" onchange="estimateCost()"> Spark Plug (₹120)</label>
                        <label><input type="checkbox" class="addon-check" value="300" onchange="estimateCost()"> Doorstep Pickup (₹300)</label>
                    </div>
                </div>
            </div>
            <div class="card" style="display:flex; flex-direction:column; justify-content:center; align-items:center; text-align:center;">
                <h4>Estimated Cost Summary</h4>
                <div id="cost-display" style="font-size: 38px; font-weight:700; margin: 15px 0; color: var(--primary);">₹1,500.00</div>
                <p style="font-size: 12px; color:var(--text-muted);">Includes 18% GST (CGST 9% + SGST 9%) on final bill generation.</p>
            </div>
        </div>
    </div>

    <!-- Quick Features Overview -->
    <div class="glass-container">
        <h3><i class="fas fa-star text-primary"></i> Our Features</h3>
        <div class="dashboard-grid" style="margin-top:20px;">
            <div class="card">
                <div class="card-icon"><i class="fas fa-file-invoice-dollar"></i></div>
                <h4 style="margin-top:10px;">Digital Invoicing</h4>
                <p style="font-size:12px; color:var(--text-muted); margin-top:5px;">Get digital copies of service breakdowns, taxes, and parts listings immediately.</p>
            </div>
            <div class="card">
                <div class="card-icon"><i class="fas fa-shield-alt"></i></div>
                <h4 style="margin-top:10px;">Security Lock</h4>
                <p style="font-size:12px; color:var(--text-muted); margin-top:5px;">We encrypt password configurations and sanitize database input tokens completely.</p>
            </div>
            <div class="card">
                <div class="card-icon"><i class="fas fa-file-signature"></i></div>
                <h4 style="margin-top:10px;">Paperless RC/DL</h4>
                <p style="font-size:12px; color:var(--text-muted); margin-top:5px;">Upload RC, Insurance, DL, and PUC files directly to make drop-offs simple.</p>
            </div>
        </div>
    </div>

    <!-- Footer -->
    <footer style="background:var(--footer-bg); color:#fff; text-align:center; padding: 25px; border-radius: 30px 30px 0 0; margin-top:40px;">
        <p>© 2026 Vehicle Care Management System. Engineered for Professional Engineering Viva.</p>
    </footer>

    <!-- Script triggers -->
    <script src="js/notifications.js"></script>
    <script src="js/script.js"></script>
    <script>
        // Load initial vehicle and status on page load
        window.addEventListener("DOMContentLoaded", () => {
            const initialType = '<%= vehicleType %>';
            const initialStatus = '<%= serviceStatus %>';
            loadVehicleShowcase(initialType, initialStatus);
        });

        function changeDemoVehicle(type, btn) {
            // Toggle active class
            btn.parentNode.querySelectorAll('button').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            
            // Set dynamic metadata labels
            document.getElementById("plate-type").innerText = type;
            if (type === 'bike') document.getElementById("plate-model").innerText = "Sport Bike v2.0";
            if (type === 'scooter') document.getElementById("plate-model").innerText = "Vespa S-125";
            if (type === 'truck') document.getElementById("plate-model").innerText = "Flatbed Recovery Utility";
            if (type === 'car') document.getElementById("plate-model").innerText = "Sedan Model S";
            
            const activeStatusBtn = document.querySelector('.demo-controls button[onclick*="changeDemoStatus"].active') || {innerText: 'RECEIVED'};
            const currentStatus = activeStatusBtn.innerText || 'RECEIVED';
            
            loadVehicleShowcase(type, currentStatus);
        }

        function changeDemoStatus(status, btn) {
            btn.parentNode.querySelectorAll('button').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            
            document.getElementById("plate-status").innerText = status;
            
            const activeTypeBtn = document.querySelector('.demo-controls button[onclick*="changeDemoVehicle"].active') || {innerText: 'car'};
            const currentType = activeTypeBtn.innerText.toLowerCase() || 'car';
            
            loadVehicleShowcase(currentType, status);
        }

        function estimateCost() {
            const selectEl = document.getElementById("cost-estimator");
            let baseCost = parseFloat(selectEl.options[selectEl.selectedIndex].dataset.cost);
            
            let addOns = 0;
            document.querySelectorAll(".addon-check:checked").forEach(chk => {
                addOns += parseFloat(chk.value);
            });
            
            const total = baseCost + addOns;
            document.getElementById("cost-display").innerText = "₹" + total.toLocaleString('en-IN') + ".00";
        }
    </script>
</body>
</html>
