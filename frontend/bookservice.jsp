<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.vehicleservice.model.User" %>
<%@ page import="com.vehicleservice.model.Vehicle" %>
<%@ page import="com.vehicleservice.model.ServicePackage" %>
<%@ page import="com.vehicleservice.dao.VehicleDAO" %>
<%@ page import="com.vehicleservice.dao.ServiceDAO" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    VehicleDAO vehicleDAO = new VehicleDAO();
    ServiceDAO serviceDAO = new ServiceDAO();

    List<Vehicle> vehicles = vehicleDAO.getVehiclesByCustomer(user.getId());
    List<ServicePackage> packages = serviceDAO.getAllPackages();

    // Check applied coupon details from session
    String appliedCoupon = (String) session.getAttribute("appliedCoupon");
    Double discountPercent = (Double) session.getAttribute("couponDiscountPercent");
    if (discountPercent == null) discountPercent = 0.0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Book Service Appointment - VehicleCare</title>
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
            <a href="dashboard.jsp">Dashboard</a>
            <a href="myvehicles.jsp">My Vehicles</a>
            <a href="bookservice.jsp" class="active">Book Service</a>
            <a href="profile.jsp">My Profile</a>
            <a href="AuthController?action=logout" class="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a>
            <button class="theme-toggle-btn" id="theme-toggle"><i class="fas fa-moon"></i></button>
        </nav>
    </header>

    <div class="glass-container">
        <h2 style="margin-bottom: 25px;"><i class="fas fa-calendar-alt text-primary"></i> Service Appointment Booking</h2>

        <% if (vehicles.isEmpty()) { %>
            <div class="card" style="text-align:center; padding: 40px;">
                <i class="fas fa-exclamation-triangle" style="font-size: 54px; color: var(--danger); margin-bottom: 15px;"></i>
                <h4>No Registered Vehicles Found!</h4>
                <p style="font-size:13px; color:var(--text-muted); margin-top:5px; margin-bottom: 20px;">You must register at least one vehicle before booking a service appointment.</p>
                <a href="myvehicles.jsp" class="btn-ripple"><i class="fas fa-plus-circle"></i> Add Vehicle Now</a>
            </div>
        <% } else { %>
            <div style="display: grid; grid-template-columns: 1.5fr 1fr; gap: 30px; align-items: start;">
                
                <!-- Left: Booking Form -->
                <div class="card">
                    <h3>Service Information Form</h3>
                    <form action="BookingController" method="POST" id="booking-form" onsubmit="return validateBookingForm()" style="margin-top: 15px;">
                        <input type="hidden" name="action" value="book">

                        <!-- Select Vehicle -->
                        <div class="form-group">
                            <label for="vehicleId"><i class="fas fa-car"></i> Select Vehicle</label>
                            <select name="vehicleId" id="vehicleId" class="form-control">
                                <% for (Vehicle v : vehicles) { %>
                                    <option value="<%= v.getId() %>"><%= v.getBrand() %> <%= v.getModel() %> (<%= v.getVehicleNumber() %>)</option>
                                <% } %>
                            </select>
                        </div>

                        <!-- Select Package -->
                        <div class="form-group">
                            <label for="packageId"><i class="fas fa-toolbox"></i> Service Package Type</label>
                            <select name="packageId" id="packageId" class="form-control" onchange="calculateBookingCost()">
                                <% for (ServicePackage p : packages) { %>
                                    <option value="<%= p.getId() %>" data-cost="<%= p.getCost() %>" data-desc="<%= p.getDescription() %>">
                                        <%= p.getName() %> - (Base: ₹<%= p.getCost() %>)
                                    </option>
                                <% } %>
                            </select>
                            <p id="package-desc-hint" style="font-size:11px; color:var(--text-muted); margin-top:5px;"></p>
                        </div>

                        <!-- Appointment Date and Slot -->
                        <div style="display:grid; grid-template-columns:1fr 1fr; gap:15px;">
                            <div class="form-group">
                                <label for="bookingDate"><i class="fas fa-calendar-day"></i> Booking Date</label>
                                <input type="date" name="bookingDate" id="bookingDate" class="form-control" required>
                            </div>
                            <div class="form-group">
                                <label for="preferredTime"><i class="fas fa-clock"></i> Preferred Time Slot</label>
                                <select name="preferredTime" id="preferredTime" class="form-control">
                                    <option value="09:00 AM - 11:00 AM">09:00 AM - 11:00 AM</option>
                                    <option value="11:00 AM - 01:00 PM">11:00 AM - 01:00 PM</option>
                                    <option value="02:00 PM - 04:00 PM">02:00 PM - 04:00 PM</option>
                                    <option value="04:00 PM - 06:00 PM">04:00 PM - 06:00 PM</option>
                                </select>
                            </div>
                        </div>

                        <!-- Pickup and Drop Configuration -->
                        <div class="form-group">
                            <label for="pickupOption"><i class="fas fa-shipping-fast"></i> Pickup & Drop Option</label>
                            <select name="pickupOption" id="pickupOption" class="form-control" onchange="togglePickupAddress(this.value)">
                                <option value="NONE">No Pickup / Self Drop (₹0)</option>
                                <option value="PICKUP">Doorstep Pickup Only (₹200)</option>
                                <option value="DROP">Delivery Drop Only (₹200)</option>
                                <option value="BOTH">Both Pickup & Drop (₹350)</option>
                            </select>
                        </div>

                        <div class="form-group" id="pickup-address-group" style="display:none;">
                            <label for="pickupAddress">Address for Pickup / Drop</label>
                            <textarea name="pickupAddress" id="pickupAddress" rows="3" class="form-control" placeholder="enter your complete address..."></textarea>
                        </div>

                        <div class="form-group">
                            <label for="notes"><i class="fas fa-sticky-note"></i> Custom Service Requests / Notes</label>
                            <textarea name="notes" id="notes" class="form-control" rows="3" placeholder="add comments or mention any issues..."></textarea>
                        </div>

                        <button type="submit" class="btn-ripple" style="width:100%; border-radius:8px;"><i class="fas fa-calendar-check"></i> Book Service Appointment</button>
                    </form>
                </div>

                <!-- Right: Summary and Coupons -->
                <div>
                    <!-- Cost Summary Card -->
                    <div class="card" style="margin-bottom: 25px; text-align:center; padding:30px;">
                        <h4>Booking Cost Breakdown</h4>
                        <div style="font-size:32px; font-weight:700; color:var(--primary); margin:15px 0;" id="summary-total">₹0.00</div>
                        
                        <div style="text-align:left; font-size:13px; line-height:1.8; border-top:1px solid var(--border-color); padding-top:15px; display:flex; flex-direction:column; gap:8px;">
                            <div style="display:flex; justify-content:space-between;">
                                <span>Base Package Price:</span>
                                <span id="summary-base">₹0.00</span>
                            </div>
                            <div style="display:flex; justify-content:space-between;">
                                <span>Pickup & Drop:</span>
                                <span id="summary-pickup">₹0.00</span>
                            </div>
                            <div style="display:flex; justify-content:space-between; color:var(--danger); font-weight:600;" id="summary-coupon-row">
                                <span>Applied Coupon:</span>
                                <span id="summary-discount">₹0.00</span>
                            </div>
                            <div style="display:flex; justify-content:space-between; border-top: 1px dashed var(--border-color); padding-top:8px; font-weight:600;">
                                <span>Estimated Bill:</span>
                                <span id="summary-subtotal">₹0.00</span>
                            </div>
                        </div>
                    </div>

                    <!-- Apply Coupon Card -->
                    <div class="card">
                        <h4><i class="fas fa-percentage text-primary"></i> Apply Coupon Code</h4>
                        <form action="CustomerActionController" method="POST" style="margin-top:15px; display:flex; gap:10px;">
                            <input type="hidden" name="action" value="apply-coupon">
                            <input type="text" name="couponCode" class="form-control" placeholder="e.g. WELCOME10" value="<%= appliedCoupon != null ? appliedCoupon : "" %>" style="text-transform:uppercase;" required>
                            <button type="submit" class="btn-ripple" style="padding:10px 15px; margin-top:0;"><i class="fas fa-ticket-alt"></i> Apply</button>
                        </form>
                        <p style="font-size:11px; color:var(--text-muted); margin-top:10px;">
                            Use coupon <strong>WELCOME10</strong> for 10% discount on base services.
                        </p>
                    </div>
                </div>

            </div>
        <% } %>
    </div>

    <footer style="background:var(--footer-bg); color:#white; text-align:center; padding: 20px; margin-top:40px;">
        <p>© 2026 Vehicle Care. Bookings Center.</p>
    </footer>

    <script src="js/notifications.js"></script>
    <script src="js/script.js"></script>
    <script>
        function togglePickupAddress(val) {
            const group = document.getElementById("pickup-address-group");
            const input = document.getElementById("pickupAddress");
            if (val === 'NONE') {
                group.style.display = "none";
                input.required = false;
            } else {
                group.style.display = "block";
                input.required = true;
            }
            calculateBookingCost();
        }

        function calculateBookingCost() {
            const pkgSelect = document.getElementById("packageId");
            if (!pkgSelect) return;
            const selectedOpt = pkgSelect.options[pkgSelect.selectedIndex];
            const baseCost = parseFloat(selectedOpt.dataset.cost);
            const desc = selectedOpt.dataset.desc;

            // Show description hint
            document.getElementById("package-desc-hint").innerText = desc;

            // Pickup charge
            const pickupOption = document.getElementById("pickupOption").value;
            let pickupCost = 0;
            if (pickupOption === 'PICKUP' || pickupOption === 'DROP') pickupCost = 200;
            if (pickupOption === 'BOTH') pickupCost = 350;

            // Coupon discount percent
            const discountPercent = <%= discountPercent %>;
            const discountAmt = baseCost * (discountPercent / 100);
            
            const total = (baseCost + pickupCost) - discountAmt;

            // Update display
            document.getElementById("summary-base").innerText = "₹" + baseCost.toLocaleString('en-IN') + ".00";
            document.getElementById("summary-pickup").innerText = "₹" + pickupCost.toLocaleString('en-IN') + ".00";
            document.getElementById("summary-discount").innerText = "-₹" + discountAmt.toLocaleString('en-IN') + ".00";
            document.getElementById("summary-subtotal").innerText = "₹" + total.toLocaleString('en-IN') + ".00";
            document.getElementById("summary-total").innerText = "₹" + total.toLocaleString('en-IN') + ".00";
        }

        function validateBookingForm() {
            const dateInput = document.getElementById("bookingDate").value;
            if (!dateInput) return false;

            const selectedDate = new Date(dateInput);
            const today = new Date();
            today.setHours(0, 0, 0, 0);

            if (selectedDate < today) {
                window.Toast.show("Please select today's date or a future date for appointments.", "error");
                return false;
            }
            return true;
        }

        // Initialize calculation on load
        window.addEventListener("DOMContentLoaded", () => {
            // Set min date of booking to today
            const bookingDateEl = document.getElementById("bookingDate");
            if (bookingDateEl) {
                const todayStr = new Date().toISOString().split('T')[0];
                bookingDateEl.min = todayStr;
            }
            calculateBookingCost();

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
