<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.vehicleservice.model.User" %>
<%@ page import="com.vehicleservice.model.SparePart" %>
<%@ page import="com.vehicleservice.dao.SparePartDAO" %>
<%@ page import="java.util.List" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null || !"ADMIN".equalsIgnoreCase(sessionUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/error-404.jsp");
        return;
    }

    SparePartDAO sparePartDAO = new SparePartDAO();
    List<SparePart> parts = sparePartDAO.getAllParts();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Spare Parts - VSS Admin</title>
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
        .low-stock {
            color: var(--danger);
            font-weight: 600;
        }
        .admin-modal {
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            z-index: 1001;
            width: 400px;
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
            <a href="admin-parts.jsp" class="active">Parts Inventory</a>
            <a href="admin-mechanics.jsp">Mechanics</a>
            <a href="admin-reports.jsp">Analytics & Reports</a>
            <a href="AuthController?action=logout" class="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a>
            <button class="theme-toggle-btn" id="theme-toggle"><i class="fas fa-moon"></i></button>
        </nav>
    </header>

    <div class="glass-container">
        <h2><i class="fas fa-box-open text-primary"></i> Spare Parts Inventory Management</h2>
        
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:20px;">
            <div style="position:relative; width:300px;">
                <input type="text" id="search-input" class="form-control" placeholder="Search part name, ID..." onkeyup="filterAdminTable()" style="padding-left:35px;">
                <i class="fas fa-search" style="position:absolute; left:12px; top:15px; color:var(--text-muted);"></i>
            </div>
            <button class="btn-ripple" onclick="openAddModal()"><i class="fas fa-plus-circle"></i> Add New Part</button>
        </div>

        <div style="overflow-x:auto;">
            <table class="admin-table" id="admin-table">
                <thead>
                    <tr>
                        <th>Part ID</th>
                        <th>Part Name</th>
                        <th>Stock Quantity</th>
                        <th>Unit Price (₹)</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (parts.isEmpty()) { %>
                        <tr>
                            <td colspan="5" style="text-align:center; padding:30px;">
                                <i class="fas fa-box" style="font-size:36px; color:var(--text-muted); margin-bottom:10px;"></i>
                                <p>No spare parts recorded in inventory.</p>
                            </td>
                        </tr>
                    <% } else { 
                        for (SparePart p : parts) { 
                    %>
                            <tr class="admin-row">
                                <td><strong>#PRT-<%= p.getId() %></strong></td>
                                <td><%= p.getName() %></td>
                                <td>
                                    <span class="<%= p.getQuantity() < 5 ? "low-stock" : "" %>">
                                        <%= p.getQuantity() %> Units
                                        <% if (p.getQuantity() < 5) { %> <i class="fas fa-exclamation-triangle" title="Low Stock Warning"></i> <% } %>
                                    </span>
                                </td>
                                <td>₹<%= String.format("%,.2f", p.getCost()) %></td>
                                <td>
                                    <div style="display:flex; gap:5px;">
                                        <button class="btn-ripple" style="padding:4px 10px; font-size:11px; margin-top:0;" 
                                                onclick="openEditModal(<%= p.getId() %>, '<%= p.getName() %>', <%= p.getCost() %>, <%= p.getQuantity() %>)">
                                            <i class="fas fa-edit"></i> Edit
                                        </button>
                                        <form action="AdminController" method="POST" onsubmit="return confirm('Delete this part?');" style="margin:0;">
                                            <input type="hidden" name="action" value="delete-part">
                                            <input type="hidden" name="partId" value="<%= p.getId() %>">
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

    <!-- Add Part Modal -->
    <div id="add-modal" class="card admin-modal">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px;">
            <h4>Add New Spare Part</h4>
            <button onclick="closeModals()" style="background:none; border:none; font-size:24px; cursor:pointer; color:var(--text-color);">&times;</button>
        </div>
        <form action="AdminController" method="POST">
            <input type="hidden" name="action" value="add-part">
            
            <div class="form-group">
                <label>Part Name</label>
                <input type="text" name="name" class="form-control" required>
            </div>
            <div class="form-group">
                <label>Unit Cost (₹)</label>
                <input type="number" name="cost" class="form-control" step="0.01" required>
            </div>
            <div class="form-group">
                <label>Initial Stock Quantity</label>
                <input type="number" name="quantity" class="form-control" required>
            </div>
            <button type="submit" class="btn-ripple" style="width:100%;"><i class="fas fa-save"></i> Add Part</button>
        </form>
    </div>

    <!-- Edit Part Modal -->
    <div id="edit-modal" class="card admin-modal">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px;">
            <h4>Edit Spare Part</h4>
            <button onclick="closeModals()" style="background:none; border:none; font-size:24px; cursor:pointer; color:var(--text-color);">&times;</button>
        </div>
        <form action="AdminController" method="POST">
            <input type="hidden" name="action" value="update-part">
            <input type="hidden" name="partId" id="edit-id" value="">
            
            <div class="form-group">
                <label>Part Name</label>
                <input type="text" name="name" id="edit-name" class="form-control" required>
            </div>
            <div class="form-group">
                <label>Unit Cost (₹)</label>
                <input type="number" name="cost" id="edit-cost" class="form-control" step="0.01" required>
            </div>
            <div class="form-group">
                <label>Current Stock Quantity</label>
                <input type="number" name="quantity" id="edit-quantity" class="form-control" required>
            </div>
            <button type="submit" class="btn-ripple" style="width:100%;"><i class="fas fa-save"></i> Update Part</button>
        </form>
    </div>

    <!-- Overlay -->
    <div id="modal-overlay" style="position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:1000; display:none;" onclick="closeModals()"></div>

    <footer style="background:var(--footer-bg); color:#white; text-align:center; padding: 20px; margin-top:40px;">
        <p>© 2026 Vehicle Care. Admin Center.</p>
    </footer>

    <script src="js/notifications.js"></script>
    <script src="js/script.js"></script>
    <script>
        function openAddModal() {
            document.getElementById("add-modal").style.display = "block";
            document.getElementById("modal-overlay").style.display = "block";
        }
        function openEditModal(id, name, cost, qty) {
            document.getElementById("edit-id").value = id;
            document.getElementById("edit-name").value = name;
            document.getElementById("edit-cost").value = cost;
            document.getElementById("edit-quantity").value = qty;
            
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
