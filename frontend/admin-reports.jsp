<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.vehicleservice.model.User" %>
<%@ page import="com.vehicleservice.model.ServicePackage" %>
<%@ page import="com.vehicleservice.dao.ServiceDAO" %>
<%@ page import="java.util.List" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null || !"ADMIN".equalsIgnoreCase(sessionUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/error-404.jsp");
        return;
    }

    ServiceDAO serviceDAO = new ServiceDAO();
    List<ServicePackage> packages = serviceDAO.getAllPackages();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Analytics & Reports - VSS Admin</title>
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
            <a href="admin-bookings.jsp">Approve Bookings</a>
            <a href="admin-customers.jsp">Customers</a>
            <a href="admin-parts.jsp">Parts Inventory</a>
            <a href="admin-mechanics.jsp">Mechanics</a>
            <a href="admin-reports.jsp" class="active">Analytics & Reports</a>
            <a href="AuthController?action=logout" class="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a>
            <button class="theme-toggle-btn" id="theme-toggle"><i class="fas fa-moon"></i></button>
        </nav>
    </header>

    <div class="glass-container">
        <!-- Exports Section -->
        <h2 style="margin-bottom: 20px;"><i class="fas fa-file-excel text-success"></i> Generate Database Reports (CSV)</h2>
        <div class="dashboard-grid" style="margin-bottom:40px;">
            <div class="card" style="text-align:center;">
                <i class="fas fa-users text-primary" style="font-size:32px; margin-bottom:10px;"></i>
                <h4>Customers Roster</h4>
                <p style="font-size:11px; color:var(--text-muted); margin:5px 0 15px;">Export all registered users</p>
                <button class="btn-ripple" style="width:100%;" onclick="alert('In a real setup, this triggers a backend CSV stream. Simulated export successful.')"><i class="fas fa-download"></i> Download CSV</button>
            </div>
            <div class="card" style="text-align:center;">
                <i class="fas fa-calendar-check text-warning" style="font-size:32px; margin-bottom:10px;"></i>
                <h4>Bookings & Appointments</h4>
                <p style="font-size:11px; color:var(--text-muted); margin:5px 0 15px;">Export historical booking logs</p>
                <button class="btn-ripple" style="width:100%;" onclick="alert('Simulated export of bookings.csv successful.')"><i class="fas fa-download"></i> Download CSV</button>
            </div>
            <div class="card" style="text-align:center;">
                <i class="fas fa-file-invoice-dollar text-success" style="font-size:32px; margin-bottom:10px;"></i>
                <h4>Revenue & Invoices</h4>
                <p style="font-size:11px; color:var(--text-muted); margin:5px 0 15px;">Export completed payments and tax data</p>
                <button class="btn-ripple" style="width:100%;" onclick="alert('Simulated export of revenue_invoices.csv successful.')"><i class="fas fa-download"></i> Download CSV</button>
            </div>
        </div>

        <hr style="border:0; border-top:1px solid var(--border-color); margin: 30px 0;">

        <!-- Service Packages Management -->
        <h2><i class="fas fa-tags text-primary"></i> Service Packages Configurations</h2>
        
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:20px;">
            <div style="position:relative; width:300px;">
                <input type="text" id="search-input" class="form-control" placeholder="Search packages..." onkeyup="filterAdminTable()" style="padding-left:35px;">
                <i class="fas fa-search" style="position:absolute; left:12px; top:15px; color:var(--text-muted);"></i>
            </div>
            <button class="btn-ripple" onclick="openAddModal()"><i class="fas fa-plus-circle"></i> Create New Package</button>
        </div>

        <div style="overflow-x:auto;">
            <table class="admin-table" id="admin-table">
                <thead>
                    <tr>
                        <th>Package ID</th>
                        <th>Service Name</th>
                        <th>Description Details</th>
                        <th>Base Price (₹)</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (packages.isEmpty()) { %>
                        <tr>
                            <td colspan="5" style="text-align:center; padding:30px;">
                                <p>No service packages created yet.</p>
                            </td>
                        </tr>
                    <% } else { 
                        for (ServicePackage p : packages) { 
                    %>
                            <tr class="admin-row">
                                <td><strong>#PKG-<%= p.getId() %></strong></td>
                                <td><strong><%= p.getName() %></strong></td>
                                <td><span style="font-size:11px; color:var(--text-muted);"><%= p.getDescription() %></span></td>
                                <td>₹<%= String.format("%,.2f", p.getCost()) %></td>
                                <td>
                                    <div style="display:flex; gap:5px;">
                                        <button class="btn-ripple" style="padding:4px 10px; font-size:11px; margin-top:0;" 
                                                onclick="openEditModal(<%= p.getId() %>, '<%= p.getName().replace("'", "\\'") %>', '<%= p.getDescription().replace("'", "\\'") %>', <%= p.getCost() %>)">
                                            <i class="fas fa-edit"></i> Edit
                                        </button>
                                        <form action="AdminController" method="POST" onsubmit="return confirm('Delete this package?');" style="margin:0;">
                                            <input type="hidden" name="action" value="delete-package">
                                            <input type="hidden" name="packageId" value="<%= p.getId() %>">
                                            <button type="submit" class="btn-ripple" style="padding:4px 10px; font-size:11px; margin-top:0; background:var(--danger); color:#white;"><i class="fas fa-trash-alt"></i> Delete</button>
                                        </form>
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

    <!-- Add Package Modal -->
    <div id="add-modal" class="card admin-modal">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px;">
            <h4>Create Service Package</h4>
            <button onclick="closeModals()" style="background:none; border:none; font-size:24px; cursor:pointer; color:var(--text-color);">&times;</button>
        </div>
        <form action="AdminController" method="POST">
            <input type="hidden" name="action" value="add-package">
            
            <div class="form-group">
                <label>Package Title Name</label>
                <input type="text" name="name" class="form-control" required>
            </div>
            <div class="form-group">
                <label>Package Details / Description</label>
                <textarea name="description" rows="3" class="form-control" required></textarea>
            </div>
            <div class="form-group">
                <label>Base Price Cost (₹)</label>
                <input type="number" name="cost" class="form-control" step="0.01" required>
            </div>
            <button type="submit" class="btn-ripple" style="width:100%;"><i class="fas fa-save"></i> Save Package</button>
        </form>
    </div>

    <!-- Edit Package Modal -->
    <div id="edit-modal" class="card admin-modal">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px;">
            <h4>Edit Service Package</h4>
            <button onclick="closeModals()" style="background:none; border:none; font-size:24px; cursor:pointer; color:var(--text-color);">&times;</button>
        </div>
        <form action="AdminController" method="POST">
            <input type="hidden" name="action" value="update-package">
            <input type="hidden" name="packageId" id="edit-id" value="">
            
            <div class="form-group">
                <label>Package Title Name</label>
                <input type="text" name="name" id="edit-name" class="form-control" required>
            </div>
            <div class="form-group">
                <label>Package Details / Description</label>
                <textarea name="description" id="edit-desc" rows="3" class="form-control" required></textarea>
            </div>
            <div class="form-group">
                <label>Base Price Cost (₹)</label>
                <input type="number" name="cost" id="edit-cost" class="form-control" step="0.01" required>
            </div>
            <button type="submit" class="btn-ripple" style="width:100%;"><i class="fas fa-save"></i> Update Package</button>
        </form>
    </div>

    <!-- Overlay -->
    <div id="modal-overlay" style="position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:1000; display:none;" onclick="closeModals()"></div>

    <footer style="background:var(--footer-bg); color:#white; text-align:center; padding: 20px; margin-top:40px;">
        <p>© 2026 Vehicle Care. Analytics Center.</p>
    </footer>

    <script src="js/notifications.js"></script>
    <script src="js/script.js"></script>
    <script>
        function openAddModal() {
            document.getElementById("add-modal").style.display = "block";
            document.getElementById("modal-overlay").style.display = "block";
        }
        function openEditModal(id, name, desc, cost) {
            document.getElementById("edit-id").value = id;
            document.getElementById("edit-name").value = name;
            document.getElementById("edit-desc").value = desc;
            document.getElementById("edit-cost").value = cost;
            
            document.getElementById("edit-modal").style.display = "block";
            document.getElementById("modal-overlay").style.display = "block";
        }
        function closeModals() {
            document.getElementById("add-modal").style.display = "none";
            document.getElementById("edit-modal").style.display = "none";
            document.getElementById("modal-overlay").style.display = "none";
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
