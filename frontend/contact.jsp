<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.vehicleservice.model.User" %>
<%
    User user = (User) session.getAttribute("user");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Support & Contact - VehicleCare</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="css/style.css">
    <style>
        .map-container {
            width: 100%;
            height: 300px;
            border-radius: 12px;
            background: #e2e8f0;
            display: flex;
            align-items: center;
            justify-content: center;
            border: 1px solid var(--border-color);
            margin-top: 15px;
            position: relative;
            overflow: hidden;
        }
        .faq-item {
            margin-bottom: 15px;
            border-bottom: 1px solid var(--border-color);
            padding-bottom: 10px;
        }
        .faq-question {
            font-weight: 600;
            font-size: 14px;
            cursor: pointer;
            color: var(--primary);
        }
        .faq-answer {
            font-size: 13px;
            color: var(--text-muted);
            margin-top: 5px;
        }
    </style>
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
            <% if (user == null) { %>
                <a href="login.jsp">Login</a>
                <a href="register.jsp">Register</a>
            <% } else { %>
                <a href="dashboard.jsp">Dashboard</a>
            <% } %>
            <a href="contact.jsp" class="active">Support</a>
            <button class="theme-toggle-btn" id="theme-toggle"><i class="fas fa-moon"></i></button>
        </nav>
    </header>

    <!-- Support Content -->
    <div class="glass-container">
        <h2 style="text-align:center; color: var(--primary); margin-bottom: 10px;"><i class="fas fa-headset"></i> Customer Support Hub</h2>
        <p style="text-align:center; color: var(--text-muted); margin-bottom: 30px;">File complaints, request breakdown towing assistance, check FAQs, or view nearby care centers.</p>

        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 30px;">
            
            <!-- Left: FAQs and Map -->
            <div>
                <h3><i class="fas fa-map-marker-alt text-primary"></i> Nearby Service Centers</h3>
                <div class="map-container">
                    <iframe src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3887.971271169994!2d80.2036573757657!3d12.973685414840506!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x3a525d8f6cc9afcd%3A0x6b8d96df29c2ea5b!2sIIT%20Madras!5e0!3m2!1sen!2sin!4v1690000000000!5m2!1sen!2sin" 
                            width="100%" height="100%" style="border:0;" allowfullscreen="" loading="lazy"></iframe>
                </div>

                <h3 style="margin-top: 30px; margin-bottom:15px;"><i class="fas fa-question-circle text-primary"></i> Frequently Asked Questions</h3>
                <div class="faq-item">
                    <div class="faq-question">1. How do I book a general service?</div>
                    <div class="faq-answer">Log in to your customer dashboard, register your vehicle, and select "Book Service". Choose your desired slot and package.</div>
                </div>
                <div class="faq-item">
                    <div class="faq-question">2. What documents are required for drop-offs?</div>
                    <div class="faq-answer">We require your Registration Certificate (RC), valid insurance document, and Pollution Certificate (PUC). You can upload these in your vehicle section for a paperless experience.</div>
                </div>
                <div class="faq-item">
                    <div class="faq-question">3. How can I download my invoice?</div>
                    <div class="faq-answer">Once your service status changes to "Completed" and payment is processed, you will see a download button under the Invoice section.</div>
                </div>
            </div>

            <!-- Right: Contact / Complaint Form & Emergency towing -->
            <div>
                <div class="card" style="border-left: 5px solid var(--danger); margin-bottom: 25px;">
                    <h4><i class="fas fa-ambulance" style="color:var(--danger);"></i> Emergency Breakdown Assistance</h4>
                    <p style="font-size:12px; color:var(--text-muted); margin-top:5px;">Are you stranded on the road? Tap the button below to register an immediate breakdown alert with GPS tracking.</p>
                    <button class="btn-ripple" style="background:var(--danger); font-size:14px; margin-top:15px; width: 100%;" onclick="requestEmergency()"><i class="fas fa-exclamation-triangle"></i> Request Roadside Assistance (24/7)</button>
                </div>

                <h3><i class="fas fa-paper-plane text-primary"></i> Contact Us / Lodge Complaint</h3>
                <% if (user != null) { %>
                    <form action="CustomerActionController" method="POST" style="margin-top: 15px;">
                        <input type="hidden" name="action" value="feedback">
                        
                        <div class="form-group">
                            <label for="type">Request Category</label>
                            <select name="type" id="type" class="form-control">
                                <option value="FEEDBACK">General Feedback</option>
                                <option value="COMPLAINT">Lodge a Complaint</option>
                                <option value="REVIEW">Write a Service Review</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="rating">Rating (Optional for Reviews)</label>
                            <select name="rating" id="rating" class="form-control">
                                <option value="">Select Star Rating</option>
                                <option value="5">⭐⭐⭐⭐⭐ Excellent</option>
                                <option value="4">⭐⭐⭐⭐ Good</option>
                                <option value="3">⭐⭐⭐ Average</option>
                                <option value="2">⭐⭐ Fair</option>
                                <option value="1">⭐ Poor</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="message">Message / Details</label>
                            <textarea name="message" id="message" rows="5" class="form-control" placeholder="describe your request, feedback, or complaints here..." required></textarea>
                        </div>

                        <button type="submit" class="btn-ripple" style="width: 100%;"><i class="fas fa-check"></i> Submit Request</button>
                    </form>
                <% } else { %>
                    <p style="background: rgba(220, 53, 69, 0.1); color: var(--danger); padding:15px; border-radius: 8px; font-size:13px; margin-top:15px;">
                        <i class="fas fa-exclamation-circle"></i> Please <a href="login.jsp" style="color:var(--primary); font-weight:600;">Login</a> to submit tickets, file complaints, or request towing.
                    </p>
                <% } %>
            </div>
        </div>
    </div>

    <!-- Live chat demo overlay -->
    <div class="card" style="position:fixed; bottom: 30px; right: 30px; width: 300px; height: 350px; z-index: 1000; box-shadow: var(--shadow); display:none; flex-direction:column;" id="chat-box">
        <div style="background:var(--primary); color:#white; padding: 12px; display:flex; justify-content:space-between; align-items:center; border-radius: 12px 12px 0 0;">
            <span style="font-weight:600;"><i class="fas fa-comments"></i> Care Chat Support</span>
            <button onclick="toggleChat()" style="background:none; border:none; color:#fff; font-size: 20px; cursor:pointer;">&times;</button>
        </div>
        <div style="flex-grow:1; padding: 15px; overflow-y:auto; font-size:12px; background:var(--bg-color);" id="chat-messages">
            <div style="margin-bottom:10px; background: rgba(0,0,0,0.05); padding:8px; border-radius:6px;">
                <strong>VSS Assistant:</strong> Hello! How can we assist you today?
            </div>
        </div>
        <div style="padding:10px; display:flex; border-top:1px solid var(--border-color);">
            <input type="text" id="chat-input" class="form-control" style="padding: 6px; font-size:12px;" placeholder="type your query...">
            <button onclick="sendChatMessage()" class="btn-ripple" style="padding:6px 12px; margin-top:0; margin-left:5px;"><i class="fas fa-paper-plane"></i></button>
        </div>
    </div>
    <button class="btn-ripple" style="position:fixed; bottom: 30px; right: 30px; z-index: 999; border-radius:50%; width: 55px; height: 55px; display:flex; align-items:center; justify-content:center; box-shadow: var(--shadow);" id="chat-toggle-btn" onclick="toggleChat()">
        <i class="fas fa-comments" style="font-size:20px;"></i>
    </button>

    <footer style="background:var(--footer-bg); color:#white; text-align:center; padding: 20px; margin-top:40px;">
        <p>© 2026 Vehicle Care. Final Year Project.</p>
    </footer>

    <script src="js/notifications.js"></script>
    <script src="js/script.js"></script>
    <script>
        function requestEmergency() {
            window.Toast.show("Emergency towing alert generated! Dispatching rescue truck...", "error", 5000);
        }

        function toggleChat() {
            const chatBox = document.getElementById("chat-box");
            const toggleBtn = document.getElementById("chat-toggle-btn");
            if (chatBox.style.display === "none") {
                chatBox.style.display = "flex";
                toggleBtn.style.display = "none";
            } else {
                chatBox.style.display = "none";
                toggleBtn.style.display = "flex";
            }
        }

        function sendChatMessage() {
            const input = document.getElementById("chat-input");
            const msg = input.value.trim();
            if (msg === "") return;

            const chatMessages = document.getElementById("chat-messages");
            
            // User message
            const userDiv = document.createElement("div");
            userDiv.style.marginBottom = "10px";
            userDiv.style.textAlign = "right";
            userDiv.innerHTML = `<div style="display:inline-block; background:var(--primary); color:#white; padding:8px; border-radius:6px;"><strong>You:</strong> ${msg}</div>`;
            chatMessages.appendChild(userDiv);
            
            input.value = "";
            chatMessages.scrollTop = chatMessages.scrollHeight;

            // Bot answer simulation
            setTimeout(() => {
                const botDiv = document.createElement("div");
                botDiv.style.marginBottom = "10px";
                botDiv.innerHTML = `<div style="background:rgba(0,0,0,0.05); padding:8px; border-radius:6px;"><strong>VSS Assistant:</strong> Thanks for reaching out. A support employee will review your query shortly. For urgent status check, view your Dashboard.</div>`;
                chatMessages.appendChild(botDiv);
                chatMessages.scrollTop = chatMessages.scrollHeight;
            }, 1000);
        }
    </script>
</body>
</html>
