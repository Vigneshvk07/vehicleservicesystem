<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Register - VehicleCare</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="css/style.css">
</head>
<body>

    <!-- Header -->
    <header>
        <h1>
            <img src="images/logo.png" alt="Logo" class="logo" onerror="this.src='https://cdn-icons-png.flaticon.com/512/3202/3202926.png'">
            Vehicle Care
        </h1>
        <nav>
            <a href="index.jsp">Home</a>
            <a href="login.jsp">Login</a>
            <a href="register.jsp" class="active">Register</a>
            <a href="contact.jsp">Support</a>
            <button class="theme-toggle-btn" id="theme-toggle"><i class="fas fa-moon"></i></button>
        </nav>
    </header>

    <!-- Register Container -->
    <div class="glass-container" style="max-width: 550px; margin: 40px auto;">
        <h2 style="text-align: center; color: var(--primary); margin-bottom: 25px;">
            <i class="fas fa-user-plus"></i> Customer Registration
        </h2>

        <form action="AuthController" method="POST" onsubmit="return validateRegisterForm()">
            <input type="hidden" name="action" value="register">

            <div class="form-group">
                <label for="name"><i class="fas fa-user"></i> Full Name</label>
                <input type="text" name="name" id="name" class="form-control" placeholder="enter your name" required>
            </div>

            <div class="form-group">
                <label for="email"><i class="fas fa-envelope"></i> Email Address</label>
                <input type="email" name="email" id="email" class="form-control" placeholder="example@email.com" required>
            </div>

            <div class="form-group">
                <label for="phone"><i class="fas fa-phone"></i> Phone Number</label>
                <input type="tel" name="phone" id="phone" class="form-control" placeholder="e.g. 9876543210" required>
            </div>

            <div class="form-group">
                <label for="password"><i class="fas fa-key"></i> Password</label>
                <input type="password" name="password" id="password" class="form-control" placeholder="••••••••" required>
                
                <!-- Password Strength meter indicator -->
                <div style="margin-top: 10px;">
                    <div style="display:flex; justify-content:space-between; font-size:11px; font-weight:600; margin-bottom:4px;">
                        <span>Password Strength</span>
                        <span id="password-strength-text" style="color:var(--danger);">Weak</span>
                    </div>
                    <div style="height:6px; width:100%; background:var(--border-color); border-radius:3px; overflow:hidden;">
                        <div id="password-strength-bar" style="height:100%; width:0%; background:var(--danger); transition:0.3s;"></div>
                    </div>
                </div>
            </div>

            <div class="form-group">
                <label for="confirmPassword"><i class="fas fa-key"></i> Confirm Password</label>
                <input type="password" name="confirmPassword" id="confirmPassword" class="form-control" placeholder="••••••••" required>
            </div>

            <button type="submit" class="btn-ripple" style="width: 100%; border-radius: 8px;"><i class="fas fa-check-circle"></i> Create Account</button>
        </form>

        <p style="text-align: center; margin-top: 25px; font-size: 14px; color: var(--text-muted);">
            Already have an account? 
            <a href="login.jsp" style="color: var(--primary); text-decoration: none; font-weight: 600;">Sign In</a>
        </p>
    </div>

    <!-- Scripts -->
    <script src="js/notifications.js"></script>
    <script src="js/script.js"></script>
    <script>
        document.addEventListener("DOMContentLoaded", () => {
            <% if (request.getParameter("error") != null) { %>
                window.Toast.show("<%= request.getParameter("error") %>", "error");
            <% } %>
        });
    </script>
</body>
</html>
