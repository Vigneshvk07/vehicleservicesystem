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
    <!-- Premium animated homepage theme -->
    <link rel="stylesheet" href="css/premium.css">
    <!-- Matte-black futuristic 3D theme (overrides the cinematic hero) -->
    <link rel="stylesheet" href="css/premium3d.css">
    <!-- ChartJS for dashboard statistics integration -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <!-- GSAP + ScrollTrigger for high-performance scroll animations -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.5/gsap.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.5/ScrollTrigger.min.js"></script>
    <!-- Three.js for the holographic wireframe vehicle -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>
    <!-- GLTFLoader for optional photoreal .glb/.gltf vehicle models -->
    <script src="https://unpkg.com/three@0.128.0/examples/js/loaders/GLTFLoader.js"></script>
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
<body class="premium-home pm3d-home">

    <!-- Premium Loading Screen -->
    <div id="pm-loader">
        <img src="images/logo.png" alt="Logo" class="pm-loader-logo" onerror="this.src='https://cdn-icons-png.flaticon.com/512/3202/3202926.png'">
        <div class="pm-loader-wheel"></div>
        <div class="pm-loader-brand">Vehicle Care</div>
        <div class="pm-loader-bar"><span></span></div>
        <div class="pm-loader-pct">0%</div>
    </div>

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

    <!-- Full-Screen 3D Holographic Wireframe Hero -->
    <section class="hero">
        <!-- Provided owner/vehicle photo as a cinematic hero backdrop -->
        <div class="pm3d-hero-photo" style="background-image:url('images/bikehome.jpg');"></div>
        <div class="pm3d-blueprint"></div>
        <div class="pm3d-fog"></div>
        <!-- Three.js CAD/X-ray vehicle renders here -->
        <canvas id="pm3d-hero-canvas"></canvas>

        <div class="hero-content">
            <span class="hero-eyebrow">CAD &middot; X-Ray &middot; Blueprint</span>
            <% if (user != null) { %>
                <h2>Welcome back,<br><span class="accent"><%= ownerName %></span></h2>
                <% if (hasActiveBooking) { %>
                    <p>Your <strong><%= vehicleModel %></strong> (<%= vehicleNumber %>) is in the bay — current status <strong><%= serviceStatus.replace("_", " ") %></strong>. Explore its live digital twin.</p>
                <% } else { %>
                    <p>Your <strong><%= vehicleModel %></strong>, rendered as a precision engineering blueprint. Book its next premium service.</p>
                <% } %>
                <a href="bookservice.jsp" class="btn-ripple"><i class="fas fa-calendar-check"></i> Book a Service Appointment</a>
            <% } else { %>
                <h2>Engineering<br><span class="accent">Precision Care</span></h2>
                <p>A luxury automotive service experience — visualized as a live CAD blueprint. Book inspections, track repairs, and download certified GST invoices.</p>
                <a href="register.jsp" class="btn-ripple"><i class="fas fa-user-plus"></i> Join Us Now</a>
            <% } %>
        </div>

        <!-- Vehicle wireframe selector -->
        <div class="pm3d-selector">
            <span class="sel-label">Model</span>
            <button class="pm3d-chip active" data-type="sedan" onclick="pm3dSelect('sedan', this)"><i class="fas fa-car-side"></i> Sedan</button>
            <button class="pm3d-chip" data-type="suv" onclick="pm3dSelect('suv', this)"><i class="fas fa-car"></i> SUV</button>
            <button class="pm3d-chip" data-type="hatchback" onclick="pm3dSelect('hatchback', this)"><i class="fas fa-car-side"></i> Hatchback</button>
            <button class="pm3d-chip" data-type="bike" onclick="pm3dSelect('bike', this)"><i class="fas fa-motorcycle"></i> Bike</button>
            <button class="pm3d-chip" data-type="truck" onclick="pm3dSelect('truck', this)"><i class="fas fa-truck"></i> Truck</button>
            <button class="pm3d-chip" data-type="ev" onclick="pm3dSelect('ev', this)"><i class="fas fa-charging-station"></i> EV</button>
        </div>

        <div class="pm-scroll-cue">
            <div class="mouse"></div>
            Scroll to explore
        </div>
    </section>

    <!-- Interactive Estimation Cost Widget -->
    <div class="glass-container pm-reveal" data-reveal="left">
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
    <div class="glass-container pm-reveal" data-reveal="right">
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
    <script src="js/premium.js"></script>
    <script src="js/premium3d.js"></script>
    <script>
        // Boot the holographic wireframe vehicle, seeded from the user's DB vehicle type
        // Photoreal models: drop .glb files at images/models/<type>.glb and they
        // auto-load in place of the procedural wireframe (falls back if absent).
        window.PM3D_MODELS = {
            sedan:     "images/models/sedan.glb",
            suv:       "images/models/suv.glb",
            hatchback: "images/models/hatchback.glb",
            bike:      "images/models/bike.glb",
            truck:     "images/models/truck.glb",
            ev:        "images/models/ev.glb"
        };

        window.addEventListener("DOMContentLoaded", () => {
            const initialType = '<%= vehicleType %>' || 'sedan';
            if (window.PM3D) {
                PM3D.mount("pm3d-hero-canvas", initialType);
                // reflect DB type in the selector highlight
                const norm = PM3D.normalizeType(initialType);
                document.querySelectorAll(".pm3d-chip").forEach(function (b) {
                    b.classList.toggle("active", b.dataset.type === norm);
                });
            }
        });

        // Swap the displayed wireframe vehicle
        function pm3dSelect(type, btn) {
            document.querySelectorAll(".pm3d-chip").forEach(b => b.classList.remove("active"));
            if (btn) btn.classList.add("active");
            if (window.PM3D) PM3D.select(type);
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
