<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Page Not Found - VehicleCare</title>
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
            <a href="contact.jsp">Support</a>
        </nav>
    </header>

    <!-- Error container -->
    <div class="glass-container" style="max-width: 600px; margin: 80px auto; text-align: center;">
        <div style="font-size: 80px; color: var(--primary); margin-bottom: 20px;">
            <i class="fas fa-exclamation-triangle"></i>
        </div>
        <h2 style="font-size: 32px; font-weight: 700; margin-bottom: 15px;">404 - Resource Not Found</h2>
        <p style="color: var(--text-muted); font-size: 16px; line-height: 1.6; margin-bottom: 30px;">
            We couldn't locate the requested page. The link might be broken, or you may not have authorization to view this area.
        </p>
        <a href="index.jsp" class="btn-ripple"><i class="fas fa-home"></i> Return to Homepage</a>
    </div>

    <!-- Footer -->
    <footer style="background:var(--footer-bg); color:#white; text-align:center; padding: 20px; position: absolute; bottom: 0; width: 100%;">
        <p>© 2026 Vehicle Care. All Rights Reserved.</p>
    </footer>

    <script src="js/script.js"></script>
</body>
</html>
