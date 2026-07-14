<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.vehicleservice.model.User" %>
<%@ page import="com.vehicleservice.model.Booking" %>
<%@ page import="com.vehicleservice.model.Mechanic" %>
<%@ page import="com.vehicleservice.model.SparePart" %>
<%@ page import="com.vehicleservice.model.Document" %>
<%@ page import="com.vehicleservice.dao.BookingDAO" %>
<%@ page import="com.vehicleservice.dao.MechanicDAO" %>
<%@ page import="com.vehicleservice.dao.SparePartDAO" %>
<%@ page import="com.vehicleservice.dao.DocumentDAO" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"ADMIN".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/error-404.jsp");
        return;
    }

    BookingDAO bookingDAO = new BookingDAO();
    MechanicDAO mechanicDAO = new MechanicDAO();
    SparePartDAO sparePartDAO = new SparePartDAO();
    DocumentDAO documentDAO = new DocumentDAO();

    List<Booking> bookings = bookingDAO.getAllBookings();
    List<Mechanic> availableMechanics = mechanicDAO.getAvailableMechanics();
    List<SparePart> partsCatalog = sparePartDAO.getAllParts();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Bookings - VSS Admin</title>
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
        .btn-action-small {
            padding: 4px 10px;
            font-size: 11px;
            margin-top: 0;
            display: inline-block;
            cursor: pointer;
            border-radius: 4px;
        }
        /* Modal alignments */
        .admin-modal {
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            z-index: 1001;
            width: 500px;
            display: none;
            box-shadow: var(--shadow);
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
            <a href="admin-bookings.jsp" class="active">Approve Bookings</a>
            <a href="admin-customers.jsp">Customers</a>
            <a href="admin-parts.jsp">Parts Inventory</a>
            <a href="admin-mechanics.jsp">Mechanics</a>
            <a href="admin-reports.jsp">Analytics & Reports</a>
            <a href="AuthController?action=logout" class="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a>
            <button class="theme-toggle-btn" id="theme-toggle"><i class="fas fa-moon"></i></button>
        </nav>
    </header>

    <div class="glass-container">
        <h2><i class="fas fa-tasks text-primary"></i> Service Appointment Requests Queue</h2>
        <p style="color:var(--text-muted); font-size:14px; margin-bottom:20px;">Review document proofs (RC/DL/PUC), approve bookings, assign staff, update statuses, and generate GST receipts.</p>

        <!-- Search Table Filters -->
        <div style="margin-bottom: 20px; position:relative; width:300px;">
            <input type="text" id="search-input" class="form-control" placeholder="Search by customer, status, model..." onkeyup="filterAdminTable()" style="padding-left:35px;">
            <i class="fas fa-search" style="position:absolute; left:12px; top:15px; color:var(--text-muted);"></i>
        </div>

        <!-- Bookings queue table -->
        <div style="overflow-x:auto;">
            <table class="admin-table" id="admin-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Customer</th>
                        <th>Vehicle & Plate</th>
                        <th>Service Package</th>
                        <th>Schedule Slots</th>
                        <th>Staff Mechanic</th>
                        <th>Status</th>
                        <th>Documents Preview</th>
                        <th>Administrative Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (bookings.isEmpty()) { %>
                        <tr>
                            <td colspan="9" style="text-align:center; padding:30px;">
                                <i class="fas fa-inbox style='font-size:36px; color:var(--text-muted); margin-bottom:10px;'"></i>
                                <p>No service requests registered yet.</p>
                            </td>
                        </tr>
                    <% } else { 
                        for (Booking b : bookings) { 
                            Document rc = documentDAO.getDocumentByTypeAndVehicle("RC", b.getVehicleId());
                            Document dl = documentDAO.getDocumentByTypeAndUser("DL", b.getCustomerId());
                    %>
                            <tr class="admin-row">
                                <td><strong>#<%= b.getId() %></strong></td>
                                <td>
                                    <strong><%= b.getCustomerName() %></strong><br>
                                    <span style="font-size:11px; color:var(--text-muted);"><%= b.getCustomerPhone() %></span>
                                </td>
                                <td>
                                    <%= b.getVehicleBrand() %> <%= b.getVehicleModel() %><br>
                                    <span class="badge" style="background:rgba(0,0,0,0.05); padding:1px 5px; font-weight:600; text-transform:uppercase;"><%= b.getVehicleNumber() %></span>
                                </td>
                                <td><%= b.getPackageName() %></td>
                                <td><%= b.getBookingDate() %><br><span style="font-size:11px; color:var(--text-muted);"><%= b.getPreferredTime() %></span></td>
                                <td>
                                    <%= b.getMechanicName() != null ? b.getMechanicName() : "<span style='color:var(--danger); font-style:italic;'>Unassigned</span>" %>
                                </td>
                                <td>
                                    <span class="badge" style="background:var(--primary); color:#fff; padding:2px 8px; border-radius:4px; font-size:11px;"><%= b.getStatus() %></span>
                                </td>
                                <td>
                                    <!-- Documents links -->
                                    <div style="display:flex; flex-direction:column; gap:4px; font-size:11px;">
                                        <% if (rc != null) { %>
                                            <a href="javascript:void(0)" onclick="previewDocument('<%= rc.getFilePath() %>', '<%= rc.getFileName().substring(rc.getFileName().lastIndexOf(".")+1) %>')" style="color:var(--primary); text-decoration:none;"><i class="fas fa-file-invoice"></i> View RC</a>
                                        <% } else { %>
                                            <span style="color:var(--danger);"><i class="fas fa-times-circle"></i> RC Missing</span>
                                        <% } %>
                                        
                                        <% if (dl != null) { %>
                                            <a href="javascript:void(0)" onclick="previewDocument('<%= dl.getFilePath() %>', '<%= dl.getFileName().substring(dl.getFileName().lastIndexOf(".")+1) %>')" style="color:var(--primary); text-decoration:none;"><i class="fas fa-id-badge"></i> View DL</a>
                                        <% } else { %>
                                            <span style="color:var(--text-muted);"><i class="fas fa-times-circle"></i> DL Missing</span>
                                        <% } %>
                                    </div>
                                </td>
                                <td>
                                    <div style="display:flex; flex-direction:column; gap:5px;">
                                        <% if ("PENDING".equalsIgnoreCase(b.getStatus())) { %>
                                            <button class="btn-ripple btn-action-small" onclick="openAssignModal(<%= b.getId() %>)"><i class="fas fa-user-check"></i> Assign Staff</button>
                                        <% } else if (!"COMPLETED".equalsIgnoreCase(b.getStatus()) && !"CANCELLED".equalsIgnoreCase(b.getStatus()) && !"DELIVERED".equalsIgnoreCase(b.getStatus()) && !"READY".equalsIgnoreCase(b.getStatus())) { %>
                                            <!-- Update Status dropdown trigger -->
                                            <form action="BookingController" method="POST" style="display:flex; gap:5px; margin:0; padding:0; width:100%; box-shadow:none; border:none;">
                                                <input type="hidden" name="action" value="update-status">
                                                <input type="hidden" name="bookingId" value="<%= b.getId() %>">
                                                <select name="status" class="form-control" style="padding: 2px; font-size:11px; width:100px;" onchange="this.form.submit()">
                                                    <option value="">Update Status</option>
                                                    <option value="RECEIVED">Received</option>
                                                    <option value="INSPECTION">Inspection</option>
                                                    <option value="REPAIR_STARTED">Repair</option>
                                                    <option value="WAITING_PARTS">Waiting Parts</option>
                                                    <option value="QUALITY_CHECK">QC Check</option>
                                                    <option value="READY">Ready</option>
                                                </select>
                                            </form>
                                        <% } else if ("READY".equalsIgnoreCase(b.getStatus())) { %>
                                            <button class="btn-ripple btn-action-small" style="background:var(--success); color:#white;" onclick="openBillingModal(<%= b.getId() %>, <%= b.getTotalCost() %>)"><i class="fas fa-file-invoice-dollar"></i> Generate Bill</button>
                                        <% } else { %>
                                            <span style="font-size:11px; color:var(--text-muted); font-style:italic;">Order Finalized</span>
                                        <% } %>
                                    </div>
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

    <!-- Staff Assignment Modal -->
    <div id="assign-modal" class="card admin-modal">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px;">
            <h4>Assign Mechanic to Appointment</h4>
            <button onclick="closeAssignModal()" style="background:none; border:none; font-size:24px; cursor:pointer; color:var(--text-color);">&times;</button>
        </div>
        <form action="BookingController" method="POST">
            <input type="hidden" name="action" value="assign-mechanic">
            <input type="hidden" name="bookingId" id="assign-booking-id" value="">

            <div class="form-group">
                <label for="mechanicId">Select Available Mechanic</label>
                <select name="mechanicId" id="mechanicId" class="form-control" required>
                    <% for (Mechanic m : availableMechanics) { %>
                        <option value="<%= m.getId() %>"><%= m.getName() %> (<%= m.getSpecialization() %>)</option>
                    <% } %>
                    <% if (availableMechanics.isEmpty()) { %>
                        <option value="">No Available Mechanics! Add more or free active staff.</option>
                    <% } %>
                </select>
            </div>

            <button type="submit" class="btn-ripple" style="width:100%;"><i class="fas fa-save"></i> Approve & Assign Mechanic</button>
        </form>
    </div>

    <!-- Invoicing Generation Modal -->
    <div id="billing-modal" class="card admin-modal" style="width: 550px;">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px;">
            <h4>Generate Invoice & Add Spare Parts</h4>
            <button onclick="closeBillingModal()" style="background:none; border:none; font-size:24px; cursor:pointer; color:var(--text-color);">&times;</button>
        </div>
        <form action="InvoiceController" method="POST">
            <input type="hidden" name="action" value="generate">
            <input type="hidden" name="bookingId" id="billing-booking-id" value="">

            <div class="form-group">
                <label>Select Used Spare Parts (Quantities)</label>
                <div style="max-height: 200px; overflow-y: auto; border:1px solid var(--border-color); padding:10px; border-radius:8px;">
                    <% for (SparePart p : partsCatalog) { %>
                        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:8px; font-size:12px;">
                            <label style="cursor:pointer; display:flex; align-items:center; gap:8px;">
                                <input type="checkbox" name="partIds" value="<%= p.getId() %>" onchange="toggleQtyInput(this)">
                                <%= p.getName() %> (₹<%= p.getCost() %>) [Stock: <%= p.getQuantity() %>]
                            </label>
                            <input type="number" name="partQtys" min="1" max="<%= p.getQuantity() %>" value="1" class="form-control" style="width: 60px; padding:2px 5px; display:none;">
                        </div>
                    <% } %>
                    <% if (partsCatalog.isEmpty()) { %>
                        <p style="font-size:11px; color:var(--text-muted);">No parts registered in catalog</p>
                    <% } %>
                </div>
            </div>

            <div style="font-size:13px; font-weight:600; margin-bottom:15px; color:var(--primary);">
                Base Service Charge: <span id="bill-base-display">₹0.00</span>
            </div>

            <button type="submit" class="btn-ripple" style="width:100%;"><i class="fas fa-file-invoice-dollar"></i> Generate GST Invoice Receipt</button>
        </form>
    </div>

    <!-- Background Overlay -->
    <div id="modal-overlay" style="position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:1000; display:none;" onclick="closeAllModals()"></div>

    <!-- Document Preview Modal -->
    <div id="document-preview-modal" class="card" style="position:fixed; top:50%; left:50%; transform:translate(-50%, -50%); z-index:1005; width:90%; max-width:800px; display:none; box-shadow: var(--shadow);">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px;">
            <h4>Document Preview</h4>
            <button onclick="closePreview()" style="background:none; border:none; font-size:24px; cursor:pointer; color:var(--text-color);">&times;</button>
        </div>
        <div id="preview-modal-body"></div>
    </div>

    <footer style="background:var(--footer-bg); color:#white; text-align:center; padding: 20px; margin-top:40px;">
        <p>© 2026 Vehicle Care. Bookings Center.</p>
    </footer>

    <script src="js/notifications.js"></script>
    <script src="js/script.js"></script>
    <script>
        function openAssignModal(bookingId) {
            document.getElementById("assign-booking-id").value = bookingId;
            document.getElementById("assign-modal").style.display = "block";
            document.getElementById("modal-overlay").style.display = "block";
        }
        function closeAssignModal() {
            document.getElementById("assign-modal").style.display = "none";
            document.getElementById("modal-overlay").style.display = "none";
        }

        function openBillingModal(bookingId, baseCost) {
            document.getElementById("billing-booking-id").value = bookingId;
            document.getElementById("bill-base-display").innerText = "₹" + baseCost.toFixed(2);
            document.getElementById("billing-modal").style.display = "block";
            document.getElementById("modal-overlay").style.display = "block";
        }
        function closeBillingModal() {
            document.getElementById("billing-modal").style.display = "none";
            document.getElementById("modal-overlay").style.display = "none";
        }

        function toggleQtyInput(chk) {
            const qtyInput = chk.parentNode.parentNode.querySelector('input[type="number"]');
            if (chk.checked) {
                qtyInput.style.display = "block";
                qtyInput.name = "partQtys";
            } else {
                qtyInput.style.display = "none";
                qtyInput.name = ""; // Remove name so it's not submitted
            }
        }

        function closeAllModals() {
            closeAssignModal();
            closeBillingModal();
        }

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
