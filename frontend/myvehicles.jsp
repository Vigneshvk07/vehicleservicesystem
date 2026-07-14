<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.vehicleservice.model.User" %>
<%@ page import="com.vehicleservice.model.Vehicle" %>
<%@ page import="com.vehicleservice.model.Document" %>
<%@ page import="com.vehicleservice.dao.VehicleDAO" %>
<%@ page import="com.vehicleservice.dao.DocumentDAO" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    VehicleDAO vehicleDAO = new VehicleDAO();
    DocumentDAO documentDAO = new DocumentDAO();
    List<Vehicle> vehicles = vehicleDAO.getVehiclesByCustomer(user.getId());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage My Vehicles - VehicleCare</title>
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
            <a href="myvehicles.jsp" class="active">My Vehicles</a>
            <a href="bookservice.jsp">Book Service</a>
            <a href="profile.jsp">My Profile</a>
            <a href="AuthController?action=logout" class="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a>
            <button class="theme-toggle-btn" id="theme-toggle"><i class="fas fa-moon"></i></button>
        </nav>
    </header>

    <div class="glass-container">
        <h2 style="margin-bottom: 25px;"><i class="fas fa-motorcycle text-primary"></i> Registered Vehicles Directory</h2>

        <div style="display: grid; grid-template-columns: 1.5fr 1fr; gap: 30px; align-items: start;">
            
            <!-- Left: List of Vehicles -->
            <div>
                <h3>My Garage List (<%= vehicles.size() %> vehicles)</h3>
                <% if (vehicles.isEmpty()) { %>
                    <div class="card" style="text-align:center; padding: 40px; margin-top:15px;">
                        <i class="fas fa-car-crash" style="font-size:48px; color:var(--text-muted); margin-bottom:15px;"></i>
                        <p style="font-weight:600;">No Vehicles Registered Yet</p>
                        <p style="font-size:12px; color:var(--text-muted); margin-top:5px;">Please fill out the registration form to add your first car, bike or scooter.</p>
                    </div>
                <% } else { %>
                    <div style="display:flex; flex-direction:column; gap:20px; margin-top:15px;">
                        <% for (Vehicle v : vehicles) { 
                            Document rcDoc = documentDAO.getDocumentByTypeAndVehicle("RC", v.getId());
                        %>
                            <div class="card">
                                <div style="display:flex; justify-content:space-between; align-items:start;">
                                    <div>
                                        <h4 style="font-size:18px;">
                                            <% if ("bike".equalsIgnoreCase(v.getType())) { %>
                                                <i class="fas fa-motorcycle text-primary"></i>
                                            <% } else if ("scooter".equalsIgnoreCase(v.getType())) { %>
                                                <i class="fas fa-motorcycle text-info"></i>
                                            <% } else if ("truck".equalsIgnoreCase(v.getType())) { %>
                                                <i class="fas fa-truck text-warning"></i>
                                            <% } else { %>
                                                <i class="fas fa-car text-primary"></i>
                                            <% } %>
                                            <%= v.getBrand() %> <%= v.getModel() %> (<%= v.getYear() %>)
                                        </h4>
                                        <span class="badge" style="background: rgba(13, 110, 253, 0.15); color: var(--primary); padding:3px 8px; border-radius:4px; font-size:11px; font-weight:700; margin-top:5px; display:inline-block; text-transform:uppercase;">
                                            Plate: <%= v.getVehicleNumber() %>
                                        </span>
                                    </div>
                                    <form action="VehicleController" method="POST" onsubmit="return confirm('Are you sure you want to remove this vehicle?');">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="vehicleId" value="<%= v.getId() %>">
                                        <button type="submit" style="background:none; border:none; color:var(--danger); cursor:pointer; font-size:15px; margin-top:0; width:auto; padding:0;"><i class="fas fa-trash-alt"></i> Remove</button>
                                    </form>
                                </div>

                                <!-- Registration Certificate (RC) Document Status -->
                                <div style="border-top: 1px solid var(--border-color); margin-top:15px; padding-top:15px; font-size:13px;">
                                    <h5><i class="fas fa-file-invoice"></i> Vehicle Registration Certificate (RC)</h5>
                                    <% if (rcDoc != null) { %>
                                        <div style="display:flex; justify-content:space-between; align-items:center; background: rgba(0,0,0,0.03); padding:10px; border-radius:8px; margin-top:8px;">
                                            <div>
                                                <div><strong>File Name:</strong> <%= rcDoc.getFileName() %></div>
                                                <div style="font-size:11px; color:var(--text-muted); margin-top:2px;">
                                                    Uploaded: <%= rcDoc.getUploadedAt().toString().substring(0, 10) %> | Size: <%= String.format("%.2f", (double)rcDoc.getFileSize() / (1024*1024)) %> MB
                                                </div>
                                            </div>
                                            <div style="display:flex; gap:10px;">
                                                <button class="btn-ripple" style="padding:6px 12px; font-size:12px; margin-top:0;" onclick="previewDocument('<%= rcDoc.getFilePath() %>', '<%= rcDoc.getFileName().substring(rcDoc.getFileName().lastIndexOf(".")+1) %>')"><i class="fas fa-eye"></i> View</button>
                                                <a href="<%= rcDoc.getFilePath() %>" download class="btn-ripple" style="padding:6px 12px; font-size:12px; margin-top:0; background:var(--success); color:#white;"><i class="fas fa-download"></i> Download</a>
                                                <form action="DocumentController" method="POST">
                                                    <input type="hidden" name="action" value="delete">
                                                    <input type="hidden" name="documentId" value="<%= rcDoc.getId() %>">
                                                    <button type="submit" class="btn-ripple" style="padding:6px 12px; font-size:12px; margin-top:0; background:var(--danger); color:#white;"><i class="fas fa-trash"></i> Delete</button>
                                                </form>
                                            </div>
                                        </div>
                                    <% } else { %>
                                        <div style="background: rgba(220, 53, 69, 0.1); color: var(--danger); padding:10px; border-radius:8px; margin-top:8px; display:flex; justify-content:space-between; align-items:center;">
                                            <span><i class="fas fa-exclamation-triangle"></i> Warning: Registration Certificate (RC) Document is Missing!</span>
                                            <button class="btn-ripple" style="padding:6px 12px; font-size:11px; margin-top:0; background:var(--danger); color:#white;" onclick="openUploadModal(<%= v.getId() %>)"><i class="fas fa-upload"></i> Upload RC</button>
                                        </div>
                                    <% } %>
                                </div>
                            </div>
                        <% } %>
                    </div>
                <% } %>
            </div>

            <!-- Right: Add Vehicle Form -->
            <div class="card" style="margin-top: 15px;">
                <h3><i class="fas fa-plus-circle text-primary"></i> Register New Vehicle</h3>
                <form action="VehicleController" method="POST" style="margin-top: 15px;">
                    <input type="hidden" name="action" value="add">

                    <div class="form-group">
                        <label for="type">Vehicle Class</label>
                        <select name="type" id="type" class="form-control">
                            <option value="Car">Sedan / SUV / Hatchback (Car)</option>
                            <option value="Bike">Sport bike (Motorcycle)</option>
                            <option value="Scooter">Gearless Scooter</option>
                            <option value="Truck">Recovery truck</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="vehicleNumber">Registration Number</label>
                        <input type="text" name="vehicleNumber" id="vehicleNumber" class="form-control" placeholder="e.g. MH12AB1234" required>
                    </div>

                    <div class="form-group">
                        <label for="brand">Manufacturer / Brand</label>
                        <input type="text" name="brand" id="brand" class="form-control" placeholder="e.g. Honda, Suzuki, Toyota" required>
                    </div>

                    <div class="form-group">
                        <label for="model">Model Name</label>
                        <input type="text" name="model" id="model" class="form-control" placeholder="e.g. Civic, Activa, Pulsar" required>
                    </div>

                    <div class="form-group">
                        <label for="year">Manufacture Year</label>
                        <input type="number" name="year" id="year" class="form-control" min="2000" max="2026" value="2020" required>
                    </div>

                    <button type="submit" class="btn-ripple" style="width:100%; border-radius:8px;"><i class="fas fa-save"></i> Register Vehicle</button>
                </form>
            </div>
        </div>
    </div>

    <!-- Upload Document Modal -->
    <div id="upload-doc-modal" class="card" style="position:fixed; top:50%; left:50%; transform:translate(-50%, -50%); z-index:1001; width:450px; display:none; box-shadow: var(--shadow);">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:20px;">
            <h4>Upload Registration Certificate (RC)</h4>
            <button onclick="closeUploadModal()" style="background:none; border:none; font-size:24px; cursor:pointer; color:var(--text-color);">&times;</button>
        </div>
        <form action="DocumentController" method="POST" enctype="multipart/form-data">
            <input type="hidden" name="action" value="upload">
            <input type="hidden" name="documentType" value="RC">
            <input type="hidden" name="vehicleId" id="upload-vehicle-id" value="">

            <div class="form-group">
                <label>Select RC Document (PDF, JPG, PNG - Max 5MB)</label>
                <div class="file-upload-wrapper">
                    <i class="fas fa-cloud-upload-alt" style="font-size:32px; color:var(--primary); margin-bottom:10px;"></i>
                    <p style="font-size:12px; color:var(--text-muted);">Drag and drop your file here, or click to browse</p>
                    <input type="file" name="documentFile" accept=".pdf,.jpg,.jpeg,.png" required>
                </div>
            </div>

            <button type="submit" class="btn-ripple" style="width:100%;"><i class="fas fa-upload"></i> Complete Upload</button>
        </form>
    </div>

    <!-- Background Overlay for Modal -->
    <div id="modal-overlay" style="position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:1000; display:none;" onclick="closeUploadModal()"></div>

    <!-- Document Preview Modal -->
    <div id="document-preview-modal" class="card" style="position:fixed; top:50%; left:50%; transform:translate(-50%, -50%); z-index:1005; width:90%; max-width:800px; display:none; box-shadow: var(--shadow);">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px;">
            <h4>RC Document Preview</h4>
            <button onclick="closePreview()" style="background:none; border:none; font-size:24px; cursor:pointer; color:var(--text-color);">&times;</button>
        </div>
        <div id="preview-modal-body"></div>
    </div>

    <footer style="background:var(--footer-bg); color:#white; text-align:center; padding: 20px; margin-top:40px;">
        <p>© 2026 Vehicle Care. Garage Portal.</p>
    </footer>

    <script src="js/notifications.js"></script>
    <script src="js/script.js"></script>
    <script>
        function openUploadModal(vehicleId) {
            document.getElementById("upload-vehicle-id").value = vehicleId;
            document.getElementById("upload-doc-modal").style.display = "block";
            document.getElementById("modal-overlay").style.display = "block";
        }
        function closeUploadModal() {
            document.getElementById("upload-doc-modal").style.display = "none";
            document.getElementById("modal-overlay").style.display = "none";
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
