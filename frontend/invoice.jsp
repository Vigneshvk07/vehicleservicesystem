<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.vehicleservice.model.User" %>
<%@ page import="com.vehicleservice.model.Invoice" %>
<%@ page import="com.vehicleservice.model.SparePart" %>
<%@ page import="com.vehicleservice.dao.InvoiceDAO" %>
<%@ page import="com.vehicleservice.dao.SparePartDAO" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String bookingIdStr = request.getParameter("bookingId");
    if (bookingIdStr == null || bookingIdStr.isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/history.jsp");
        return;
    }

    int bookingId = Integer.parseInt(bookingIdStr);
    InvoiceDAO invoiceDAO = new InvoiceDAO();
    Invoice invoice = invoiceDAO.getInvoiceByBookingId(bookingId);

    if (invoice == null) {
        response.sendRedirect(request.getContextPath() + "/history.jsp?error=Invoice not generated yet for booking #" + bookingId);
        return;
    }

    // Check ownership (only customer owner or admin can view)
    if (!"ADMIN".equalsIgnoreCase(user.getRole()) && !user.getEmail().equalsIgnoreCase(invoice.getCustomerEmail())) {
        response.sendRedirect(request.getContextPath() + "/error-404.jsp");
        return;
    }

    SparePartDAO sparePartDAO = new SparePartDAO();
    List<SparePart> partsUsed = sparePartDAO.getPartsForBooking(bookingId);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>GST Invoice #<%= invoice.getInvoiceNumber() %> - VehicleCare</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="css/style.css">
    <style>
        .paid-stamp {
            border: 4px solid var(--success);
            color: var(--success);
            font-size: 24px;
            font-weight: 700;
            padding: 10px 25px;
            text-transform: uppercase;
            border-radius: 6px;
            display: inline-block;
            transform: rotate(-15deg);
            box-shadow: 0 0 10px rgba(25, 135, 84, 0.2);
            position: absolute;
            top: 50px;
            right: 50px;
        }
        .unpaid-stamp {
            border: 4px solid var(--danger);
            color: var(--danger);
            font-size: 24px;
            font-weight: 700;
            padding: 10px 25px;
            text-transform: uppercase;
            border-radius: 6px;
            display: inline-block;
            transform: rotate(-15deg);
            position: absolute;
            top: 50px;
            right: 50px;
        }
        .invoice-actions {
            display: flex;
            justify-content: center;
            gap: 15px;
            margin-top: 30px;
        }
        .pay-tab {
            padding: 8px 16px;
            background: rgba(255,255,255,0.05);
            border: 1px solid var(--border-color);
            cursor: pointer;
            font-size: 13px;
            border-radius: 6px;
        }
        .pay-tab.active {
            background: var(--primary);
            color: white;
            border-color: var(--primary);
        }
    </style>
</head>
<body>

    <!-- Sticky Header -->
    <header class="no-print">
        <h1>
            <img src="images/logo.png" alt="Logo" class="logo" onerror="this.src='https://cdn-icons-png.flaticon.com/512/3202/3202926.png'">
            Vehicle Care
        </h1>
        <nav>
            <a href="index.jsp">Home</a>
            <% if ("ADMIN".equalsIgnoreCase(user.getRole())) { %>
                <a href="admin-dashboard.jsp">Dashboard</a>
            <% } else { %>
                <a href="dashboard.jsp">Dashboard</a>
                <a href="history.jsp">History</a>
            <% } %>
            <a href="AuthController?action=logout" class="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a>
            <button class="theme-toggle-btn" id="theme-toggle"><i class="fas fa-moon"></i></button>
        </nav>
    </header>

    <div class="glass-container">
        <!-- Invoice Block -->
        <div class="invoice-box" style="position:relative;">
            
            <!-- Verification stamps -->
            <% if ("PAID".equalsIgnoreCase(invoice.getPaymentStatus())) { %>
                <div class="paid-stamp">PAID</div>
            <% } else { %>
                <div class="unpaid-stamp">UNPAID</div>
            <% } %>

            <!-- Invoice Header -->
            <div class="invoice-header">
                <div>
                    <h2>VEHICLE CARE & SERVICE LTD</h2>
                    <p style="font-size:12px; color:#666; margin-top:5px;">
                        102, Garage Arena Industrial Estate, Chennai - 600032<br>
                        <strong>GSTIN:</strong> 33AAAAA1111A1Z1 | <strong>Phone:</strong> +91 98765 43210
                    </p>
                </div>
                <div style="text-align: right;">
                    <h3 style="color:var(--primary);">TAX INVOICE</h3>
                    <p style="font-size:13px; margin-top:5px;">
                        <strong>Invoice No:</strong> <%= invoice.getInvoiceNumber() %><br>
                        <strong>Date:</strong> <%= invoice.getIssueDate() %>
                    </p>
                </div>
            </div>

            <!-- Billing Details -->
            <div class="invoice-bill-row">
                <div>
                    <h5 style="color:#666; font-size:12px; text-transform:uppercase; margin-bottom:5px;">Customer Information</h5>
                    <strong><%= invoice.getCustomerName() %></strong><br>
                    Email: <%= invoice.getCustomerEmail() %><br>
                    Phone: <%= invoice.getCustomerPhone() %>
                </div>
                <div style="text-align: right;">
                    <h5 style="color:#666; font-size:12px; text-transform:uppercase; margin-bottom:5px;">Vehicle Details</h5>
                    <strong><%= invoice.getVehicleBrand() %> <%= invoice.getVehicleModel() %></strong><br>
                    Plate No: <span style="text-transform:uppercase;"><%= invoice.getVehicleNumber() %></span><br>
                    Booking ID: #<%= invoice.getBookingId() %>
                </div>
            </div>

            <!-- Itemized Table -->
            <table class="invoice-table">
                <thead>
                    <tr>
                        <th>Item Description</th>
                        <th>Type</th>
                        <th>Cost</th>
                    </tr>
                </thead>
                <tbody>
                    <!-- Base Service Package -->
                    <tr>
                        <td>
                            <strong><%= invoice.getPackageName() %></strong><br>
                            <span style="font-size:11px; color:#777;">Base diagnostic service package</span>
                        </td>
                        <td>Service Pack</td>
                        <td>₹<%= String.format("%,.2f", invoice.getServiceCost()) %></td>
                    </tr>
                    
                    <!-- Spare Parts Used -->
                    <% if (partsUsed.isEmpty()) { %>
                        <tr>
                            <td colspan="3" style="color:#888; font-style:italic; font-size:11px; text-align:center;">No replacement parts used during this service.</td>
                        </tr>
                    <% } else { 
                        for (SparePart part : partsUsed) {
                    %>
                            <tr>
                                <td>
                                    <strong><%= part.getName() %></strong><br>
                                    <span style="font-size:11px; color:#777;">Quantity used: <%= part.getQuantity() %> units</span>
                                </td>
                                <td>Spare Part</td>
                                <td>₹<%= String.format("%,.2f", part.getCost() * part.getQuantity()) %></td>
                            </tr>
                    <% 
                        } 
                    } 
                    %>
                </tbody>
            </table>

            <!-- Invoice Summary Totals -->
            <div style="display:flex; justify-content:space-between; align-items:end; margin-top:30px;">
                <!-- QR and Barcode Verification (Final Year Feature) -->
                <div style="display:flex; gap:20px; align-items:center;">
                    <!-- QR Code verification API -->
                    <div style="text-align:center;">
                        <img src="https://api.qrserver.com/v1/create-qr-code/?size=90x90&data=https://vehicleservicesystem/verify/booking-<%= invoice.getBookingId() %>" 
                             alt="Verification QR" style="border:1px solid #ccc; padding:3px; background:#fff; width:90px; height:90px;">
                        <div style="font-size:9px; color:#666; margin-top:3px;">Verify Receipt</div>
                    </div>
                    <!-- Job Card Barcode API -->
                    <div style="text-align:center;">
                        <img src="https://barcode.tec-it.com/barcode.ashx?data=JOB-<%= invoice.getBookingId() %>&code=Code128&translate-esc=on" 
                             alt="Job Barcode" style="height:60px; max-width:140px; background:#white;">
                        <div style="font-size:9px; color:#666; margin-top:3px;">Job Card Barcode</div>
                    </div>
                </div>

                <!-- Totals -->
                <div class="invoice-totals">
                    <div class="totals-row">
                        <span>Items Subtotal:</span>
                        <span>₹<%= String.format("%,.2f", invoice.getServiceCost() + invoice.getPartCost()) %></span>
                    </div>
                    <div class="totals-row">
                        <span>GST Tax (18%):</span>
                        <span>₹<%= String.format("%,.2f", invoice.getTax()) %></span>
                    </div>
                    <% if (invoice.getDiscount() > 0) { %>
                        <div class="totals-row" style="color:var(--danger); font-weight:600;">
                            <span>Coupon Discount:</span>
                            <span>-₹<%= String.format("%,.2f", invoice.getDiscount()) %></span>
                        </div>
                    <% } %>
                    <div class="totals-row grand-total">
                        <span>Grand Total:</span>
                        <span>₹<%= String.format("%,.2f", invoice.getTotalAmount()) %></span>
                    </div>
                </div>
            </div>

            <div style="clear:both;"></div>
        </div>

        <!-- Invoice Action Buttons -->
        <div class="invoice-actions no-print">
            <button class="btn-ripple" style="background:var(--info); color:#white;" onclick="window.print()"><i class="fas fa-print"></i> Print Invoice Receipt</button>
            
            <% if (!"PAID".equalsIgnoreCase(invoice.getPaymentStatus())) { %>
                <button class="btn-ripple" style="background:var(--danger); color:#white;" onclick="openPaymentGateway()"><i class="fas fa-wallet"></i> Pay Total Amount (₹<%= String.format("%,.2f", invoice.getTotalAmount()) %>)</button>
            <% } %>
        </div>
    </div>

    <!-- Payment Simulator Modal -->
    <div id="payment-modal" class="card" style="position:fixed; top:50%; left:50%; transform:translate(-50%, -50%); z-index:1001; width:500px; display:none; box-shadow: var(--shadow);">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px; border-bottom:1px solid var(--border-color); padding-bottom:10px;">
            <h4>VSS Secure Payment Gateway</h4>
            <button onclick="closePaymentGateway()" style="background:none; border:none; font-size:24px; cursor:pointer; color:var(--text-color);">&times;</button>
        </div>

        <!-- Mode selector tabs -->
        <div style="display:flex; gap:10px; margin-bottom:20px;">
            <button class="pay-tab active" onclick="switchPayTab('upi', this)"><i class="fas fa-mobile-alt"></i> UPI Pay</button>
            <button class="pay-tab" onclick="switchPayTab('card', this)"><i class="fas fa-credit-card"></i> Card</button>
            <button class="pay-tab" onclick="switchPayTab('banking', this)"><i class="fas fa-university"></i> Net Banking</button>
        </div>

        <form action="CustomerActionController" method="POST">
            <input type="hidden" name="action" value="payment">
            <input type="hidden" name="invoiceId" value="<%= invoice.getId() %>">
            <input type="hidden" name="bookingId" value="<%= invoice.getBookingId() %>">
            <input type="hidden" name="amount" value="<%= invoice.getTotalAmount() %>">
            <input type="hidden" name="paymentMethod" id="pay-method" value="UPI">

            <!-- UPI Form -->
            <div id="pay-upi-section">
                <div class="form-group">
                    <label for="upi-id">Enter UPI VPA ID</label>
                    <input type="text" id="upi-id" class="form-control" placeholder="e.g. vignesh@okaxis">
                </div>
            </div>

            <!-- Card Form -->
            <div id="pay-card-section" style="display:none;">
                <div class="form-group">
                    <label>Cardholder Name</label>
                    <input type="text" class="form-control" placeholder="FullName">
                </div>
                <div class="form-group">
                    <label>Card Number</label>
                    <input type="text" class="form-control" placeholder="4111 2222 3333 4444" maxlength="19">
                </div>
                <div style="display:grid; grid-template-columns:1fr 1fr; gap:15px;">
                    <div class="form-group">
                        <label>Expiry Date</label>
                        <input type="text" class="form-control" placeholder="MM/YY" maxlength="5">
                    </div>
                    <div class="form-group">
                        <label>CVV Code</label>
                        <input type="password" class="form-control" placeholder="•••" maxlength="3">
                    </div>
                </div>
            </div>

            <!-- Banking Form -->
            <div id="pay-banking-section" style="display:none;">
                <div class="form-group">
                    <label for="bank">Select Net Banking Provider</label>
                    <select id="bank" class="form-control">
                        <option value="sbi">State Bank of India</option>
                        <option value="hdfc">HDFC Bank</option>
                        <option value="icici">ICICI Bank</option>
                        <option value="axis">Axis Bank</option>
                    </select>
                </div>
            </div>

            <div class="form-group">
                <label for="transactionId">Mock Transaction Reference ID (Optional)</label>
                <input type="text" name="transactionId" id="transactionId" class="form-control" placeholder="Generate automatically if empty">
            </div>

            <button type="submit" class="btn-ripple" style="width:100%;"><i class="fas fa-shield-alt"></i> Complete Secure Payment (₹<%= String.format("%,.2f", invoice.getTotalAmount()) %>)</button>
        </form>
    </div>

    <!-- Background Overlay for Modal -->
    <div id="modal-overlay" style="position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:1000; display:none;" onclick="closePaymentGateway()"></div>

    <footer style="background:var(--footer-bg); color:#white; text-align:center; padding: 20px; margin-top:40px;" class="no-print">
        <p>© 2026 Vehicle Care. Invoice Checkout.</p>
    </footer>

    <script src="js/notifications.js"></script>
    <script src="js/script.js"></script>
    <script>
        function openPaymentGateway() {
            document.getElementById("payment-modal").style.display = "block";
            document.getElementById("modal-overlay").style.display = "block";
        }

        function closePaymentGateway() {
            document.getElementById("payment-modal").style.display = "none";
            document.getElementById("modal-overlay").style.display = "none";
        }

        function switchPayTab(mode, tab) {
            // Toggle active classes on tabs
            tab.parentNode.querySelectorAll('button').forEach(b => b.classList.remove('active'));
            tab.classList.add('active');

            // Hide all sections
            document.getElementById("pay-upi-section").style.display = "none";
            document.getElementById("pay-card-section").style.display = "none";
            document.getElementById("pay-banking-section").style.display = "none";

            if (mode === 'upi') {
                document.getElementById("pay-upi-section").style.display = "block";
                document.getElementById("pay-method").value = "UPI";
            } else if (mode === 'card') {
                document.getElementById("pay-card-section").style.display = "block";
                document.getElementById("pay-method").value = "CARD";
            } else if (mode === 'banking') {
                document.getElementById("pay-banking-section").style.display = "block";
                document.getElementById("pay-method").value = "NET_BANKING";
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
