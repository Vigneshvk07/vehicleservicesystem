<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Login - VehicleCare</title>
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
            <a href="login.jsp" class="active">Login</a>
            <a href="register.jsp">Register</a>
            <a href="contact.jsp">Support</a>
            <button class="theme-toggle-btn" id="theme-toggle"><i class="fas fa-moon"></i></button>
        </nav>
    </header>

    <!-- Login Container -->
    <div class="glass-container" style="max-width: 480px; margin: 80px auto;">
        <h2 style="text-align: center; color: var(--primary); margin-bottom: 25px;">
            <i class="fas fa-user-lock"></i> Account Sign In
        </h2>

        <form action="AuthController" method="POST">
            <input type="hidden" name="action" value="login">

            <div class="form-group">
                <label for="email"><i class="fas fa-envelope"></i> Email Address</label>
                <input type="email" name="email" id="email" class="form-control" placeholder="enter your registered email" required>
            </div>

            <div class="form-group">
                <label for="password"><i class="fas fa-key"></i> Password</label>
                <input type="password" name="password" id="password" class="form-control" placeholder="••••••••" required>
            </div>

            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                <label style="font-size: 13px; cursor: pointer;">
                    <input type="checkbox" name="remember"> Remember Me
                </label>
                <a href="forgot-password.jsp" style="font-size: 13px; color: var(--primary); text-decoration: none;">Forgot Password?</a>
            </div>

            <button type="submit" class="btn-ripple" style="width: 100%; border-radius: 8px;"><i class="fas fa-sign-in-alt"></i> Access Account</button>
        </form>

        <p style="text-align: center; margin-top: 25px; font-size: 14px; color: var(--text-muted);">
            Don't have an account? 
            <a href="register.jsp" style="color: var(--primary); text-decoration: none; font-weight: 600;">Register Here</a>
        </p>
    </div>

    <!-- Script imports -->
    <script src="js/notifications.js"></script>
    <script src="js/script.js"></script>
    <script>
        document.addEventListener("DOMContentLoaded", () => {
            // Read status messages from parameters
            <% if (request.getParameter("error") != null) { %>
                window.Toast.show("<%= request.getParameter("error") %>", "error");
            <% } %>
            <% if (request.getParameter("msg") != null) { %>
                window.Toast.show("<%= request.getParameter("msg") %>", "success");
            <% } %>
        });
    </form>
</body>
</html>
