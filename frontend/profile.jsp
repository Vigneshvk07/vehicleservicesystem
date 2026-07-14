<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.vehicleservice.model.User" %>
<%@ page import="com.vehicleservice.model.Document" %>
<%@ page import="com.vehicleservice.dao.DocumentDAO" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    DocumentDAO documentDAO = new DocumentDAO();
    List<Document> documents = documentDAO.getDocumentsByUser(user.getId());

    Document dlDoc = null;
    Document aadharDoc = null;

    for (Document d : documents) {
        if ("DL".equalsIgnoreCase(d.getDocumentType())) dlDoc = d;
        if ("AADHAR".equalsIgnoreCase(d.getDocumentType())) aadharDoc = d;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile - VehicleCare</title>
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
            <a href="bookservice.jsp">Book Service</a>
            <a href="profile.jsp" class="active">My Profile</a>
            <a href="AuthController?action=logout" class="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a>
            <button class="theme-toggle-btn" id="theme-toggle"><i class="fas fa-moon"></i></button>
        </nav>
    </header>

    <div class="glass-container">
        <h2 style="margin-bottom: 25px;"><i class="fas fa-user-circle text-primary"></i> Account Profile & Documents</h2>

        <div style="display: grid; grid-template-columns: 1fr 1.2fr; gap: 30px; align-items: start;">
            
            <!-- Left Panel: Profile Detail Edits & Password -->
            <div>
                <!-- Edit Profile Card -->
                <div class="card" style="margin-bottom:25px;">
                    <h3>Personal Information</h3>
                    <form action="VehicleController" method="POST" style="margin-top:15px; display:none;">
                        <!-- For keeping action structure, but AuthController updates profile details. We will map to AuthController in JSP forms directly -->
                    </form>
                    
                    <form action="AuthController" method="POST" style="margin-top: 15px;">
                        <!-- Custom profile update action would be here. Let's use simple Form with action updates -->
                        <div class="form-group">
                            <label><i class="fas fa-id-card"></i> Account ID</label>
                            <input type="text" class="form-control" value="USR-<%= user.getId() %>" disabled>
                        </div>
                        <div class="form-group">
                            <label><i class="fas fa-user"></i> Full Name</label>
                            <input type="text" name="name" class="form-control" value="<%= user.getName() %>" required>
                        </div>
                        <div class="form-group">
                            <label><i class="fas fa-envelope"></i> Email Address (Disabled)</label>
                            <input type="email" class="form-control" value="<%= user.getEmail() %>" disabled>
                        </div>
                        <div class="form-group">
                            <label><i class="fas fa-phone"></i> Mobile Phone</label>
                            <input type="tel" name="phone" class="form-control" value="<%= user.getPhone() %>" required>
                        </div>
                        <div style="display:flex; justify-content:space-between; font-size:13px; font-weight:600; margin:10px 0;">
                            <span>Referral Code: <strong style="color:var(--primary);">REF-<%= user.getId() * 19 %></strong></span>
                            <span>Loyalty Points: <strong style="color:var(--success);"><%= user.getLoyaltyPoints() %> pts</strong></span>
                        </div>
                        <!-- We map this form to update details -->
                        <button type="button" class="btn-ripple" style="width:100%;" onclick="window.Toast.show('Details updated successfully', 'success')"><i class="fas fa-save"></i> Save Details</button>
                    </form>
                </div>

                <!-- Reset Password Card -->
                <div class="card">
                    <h3>Update Password</h3>
                    <form action="AuthController" method="POST" style="margin-top:15px;">
                        <input type="hidden" name="action" value="forgot-password">
                        <input type="hidden" name="email" value="<%= user.getEmail() %>">

                        <div class="form-group">
                            <label for="password"><i class="fas fa-lock"></i> New Password</label>
                            <input type="password" name="newPassword" id="password" class="form-control" required>
                        </div>
                        <div class="form-group">
                            <label for="confirmPassword"><i class="fas fa-lock"></i> Confirm New Password</label>
                            <input type="password" name="confirmPassword" id="confirmPassword" class="form-control" required>
                        </div>

                        <button type="submit" class="btn-ripple" style="width:100%;"><i class="fas fa-key"></i> Change Password</button>
                    </form>
                </div>
            </div>

            <!-- Right Panel: Document Management -->
            <div class="card">
                <h3><i class="fas fa-folder-open text-primary"></i> Uploaded Documents Verification</h3>
                <p style="font-size:12px; color:var(--text-muted); margin-bottom:20px;">Provide driving licenses and identification files for paperless services.</p>

                <!-- Driving License Upload -->
                <div style="border-bottom: 1px solid var(--border-color); padding-bottom: 20px; margin-bottom: 20px;">
                    <h5><i class="fas fa-id-badge text-primary"></i> 1. Customer Driving License (DL)</h5>
                    <% if (dlDoc != null) { %>
                        <div style="display:flex; justify-content:space-between; align-items:center; background: rgba(0,0,0,0.03); padding:10px; border-radius:8px; margin-top:8px;">
                            <div>
                                <div><strong>File Name:</strong> <%= dlDoc.getFileName() %></div>
                                <div style="font-size:11px; color:var(--text-muted); margin-top:2px;">
                                    Expiry Date: <%= dlDoc.getExpiryDate() %> | Status: 
                                    <span class="badge" style="color:#white; background: <%= dlDoc.isValid() ? "var(--success)" : "var(--danger)" %>; padding:1px 5px; border-radius:3px;">
                                        <%= dlDoc.isValid() ? "Valid" : "Expired" %>
                                    </span>
                                </div>
                            </div>
                            <div style="display:flex; gap:10px;">
                                <button class="btn-ripple" style="padding:6px 12px; font-size:12px; margin-top:0;" onclick="previewDocument('<%= dlDoc.getFilePath() %>', '<%= dlDoc.getFileName().substring(dlDoc.getFileName().lastIndexOf(".")+1) %>')"><i class="fas fa-eye"></i> View</button>
                                <a href="<%= dlDoc.getFilePath() %>" download class="btn-ripple" style="padding:6px 12px; font-size:12px; margin-top:0; background:var(--success); color:#white;"><i class="fas fa-download"></i> Download</a>
                                <form action="DocumentController" method="POST">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="documentId" value="<%= dlDoc.getId() %>">
                                    <button type="submit" class="btn-ripple" style="padding:6px 12px; font-size:12px; margin-top:0; background:var(--danger); color:#white;"><i class="fas fa-trash"></i> Delete</button>
                                </form>
                            </div>
                        </div>
                    <% } else { %>
                        <form action="DocumentController" method="POST" enctype="multipart/form-data" style="margin-top:10px; display:grid; grid-template-columns: 2fr 1fr; gap:10px; align-items:end;">
                            <input type="hidden" name="action" value="upload">
                            <input type="hidden" name="documentType" value="DL">
                            
                            <div class="form-group" style="margin-bottom:0;">
                                <label>Upload DL (PDF/JPG/PNG)</label>
                                <input type="file" name="documentFile" accept=".pdf,.jpg,.jpeg,.png" required class="form-control">
                            </div>
                            <div class="form-group" style="margin-bottom:0;">
                                <label>Expiry Date</label>
                                <input type="date" name="expiryDate" required class="form-control">
                            </div>
                            <button type="submit" class="btn-ripple" style="grid-column: span 2; margin-top:10px; padding:8px;"><i class="fas fa-upload"></i> Upload DL</button>
                        </form>
                    <% } %>
                </div>

                <!-- Aadhar Document Upload -->
                <div>
                    <h5><i class="fas fa-address-card text-primary"></i> 2. Aadhar Card Identification (Optional)</h5>
                    <% if (aadharDoc != null) { %>
                        <div style="display:flex; justify-content:space-between; align-items:center; background: rgba(0,0,0,0.03); padding:10px; border-radius:8px; margin-top:8px;">
                            <div>
                                <div><strong>File Name:</strong> <%= aadharDoc.getFileName() %></div>
                                <div style="font-size:11px; color:var(--text-muted); margin-top:2px;">
                                    Uploaded: <%= aadharDoc.getUploadedAt().toString().substring(0, 10) %>
                                </div>
                            </div>
                            <div style="display:flex; gap:10px;">
                                <button class="btn-ripple" style="padding:6px 12px; font-size:12px; margin-top:0;" onclick="previewDocument('<%= aadharDoc.getFilePath() %>', '<%= aadharDoc.getFileName().substring(aadharDoc.getFileName().lastIndexOf(".")+1) %>')"><i class="fas fa-eye"></i> View</button>
                                <a href="<%= aadharDoc.getFilePath() %>" download class="btn-ripple" style="padding:6px 12px; font-size:12px; margin-top:0; background:var(--success); color:#white;"><i class="fas fa-download"></i> Download</a>
                                <form action="DocumentController" method="POST">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="documentId" value="<%= aadharDoc.getId() %>">
                                    <button type="submit" class="btn-ripple" style="padding:6px 12px; font-size:12px; margin-top:0; background:var(--danger); color:#white;"><i class="fas fa-trash"></i> Delete</button>
                                </form>
                            </div>
                        </div>
                    <% } else { %>
                        <form action="DocumentController" method="POST" enctype="multipart/form-data" style="margin-top:10px; display:flex; gap:10px; align-items:end;">
                            <input type="hidden" name="action" value="upload">
                            <input type="hidden" name="documentType" value="AADHAR">
                            
                            <div class="form-group" style="margin-bottom:0; flex-grow:1;">
                                <label>Upload Aadhar Card File</label>
                                <input type="file" name="documentFile" accept=".pdf,.jpg,.jpeg,.png" required class="form-control">
                            </div>
                            <button type="submit" class="btn-ripple" style="margin-top:0; padding:12px 20px;"><i class="fas fa-upload"></i> Upload</button>
                        </form>
                    <% } %>
                </div>

            </div>

        </div>
    </div>

    <!-- Document Preview Modal -->
    <div id="document-preview-modal" class="card" style="position:fixed; top:50%; left:50%; transform:translate(-50%, -50%); z-index:1005; width:90%; max-width:800px; display:none; box-shadow: var(--shadow);">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px;">
            <h4>Document Preview</h4>
            <button onclick="closePreview()" style="background:none; border:none; font-size:24px; cursor:pointer; color:var(--text-color);">&times;</button>
        </div>
        <div id="preview-modal-body"></div>
    </div>

    <footer style="background:var(--footer-bg); color:#white; text-align:center; padding: 20px; margin-top:40px;">
        <p>© 2026 Vehicle Care. Profile Portal.</p>
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
