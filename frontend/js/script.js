// General Client-Side Scripting - Vehicle Service System

// 1. Dark Mode / Light Mode toggle logic
function initTheme() {
    const savedTheme = localStorage.getItem('theme') || 'light';
    document.documentElement.setAttribute('data-theme', savedTheme);
    const toggleBtn = document.getElementById('theme-toggle');
    if (toggleBtn) {
        toggleBtn.innerHTML = savedTheme === 'dark' ? '<i class="fas fa-sun"></i>' : '<i class="fas fa-moon"></i>';
    }
}

function toggleTheme() {
    const currentTheme = document.documentElement.getAttribute('data-theme');
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
    document.documentElement.setAttribute('data-theme', newTheme);
    localStorage.setItem('theme', newTheme);
    
    const toggleBtn = document.getElementById('theme-toggle');
    if (toggleBtn) {
        toggleBtn.innerHTML = newTheme === 'dark' ? '<i class="fas fa-sun"></i>' : '<i class="fas fa-moon"></i>';
    }
}

// 2. Ripple effect for buttons
function initRipples() {
    document.querySelectorAll('.btn-ripple').forEach(button => {
        button.addEventListener('click', function(e) {
            const rect = button.getBoundingClientRect();
            const x = e.clientX - rect.left;
            const y = e.clientY - rect.top;
            
            const ripple = document.createElement('span');
            ripple.className = 'ripple';
            ripple.style.left = `${x}px`;
            ripple.style.top = `${y}px`;
            
            button.appendChild(ripple);
            
            ripple.addEventListener('animationend', () => {
                ripple.remove();
            });
        });
    });
}

// 3. Form validations
function validateRegisterForm() {
    const email = document.getElementById("email").value;
    const phone = document.getElementById("phone").value;
    const password = document.getElementById("password").value;
    const confirmPassword = document.getElementById("confirmPassword").value;

    // Email Check
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
        window.Toast.show("Please enter a valid email address.", "error");
        return false;
    }

    // Phone Check (10 digits)
    const phoneRegex = /^[6-9]\d{9}$/;
    if (!phoneRegex.test(phone)) {
        window.Toast.show("Phone number must be a valid 10-digit number.", "error");
        return false;
    }

    // Password Strength
    if (password.length < 6) {
        window.Toast.show("Password must be at least 6 characters long.", "error");
        return false;
    }

    if (password !== confirmPassword) {
        window.Toast.show("Passwords do not match.", "error");
        return false;
    }
    return true;
}

// Real-time password strength meter
function checkPasswordStrength(password) {
    const strengthMeter = document.getElementById('password-strength-bar');
    const strengthText = document.getElementById('password-strength-text');
    if (!strengthMeter || !strengthText) return;

    let score = 0;
    if (password.length >= 6) score++;
    if (password.length >= 10) score++;
    if (/[A-Z]/.test(password)) score++;
    if (/[0-9]/.test(password)) score++;
    if (/[^A-Za-z0-9]/.test(password)) score++;

    let width = "0%";
    let color = "var(--danger)";
    let label = "Weak";

    if (score >= 4) {
        width = "100%";
        color = "var(--success)";
        label = "Strong";
    } else if (score >= 2) {
        width = "60%";
        color = "var(--warning)";
        label = "Medium";
    } else if (score > 0) {
        width = "30%";
        color = "var(--danger)";
        label = "Weak";
    }

    strengthMeter.style.width = width;
    strengthMeter.style.backgroundColor = color;
    strengthText.innerText = label;
    strengthText.style.color = color;
}

// Vehicle Number format validation (e.g. MH-12-AB-1234 or DL-3C-AB-1234)
function validateVehicleNumber(number) {
    const vehicleRegex = /^[A-Z]{2}[ -]?\d{1,2}[ -]?[A-Z]{1,3}[ -]?\d{4}$/i;
    return vehicleRegex.test(number);
}

// 4. Scroll-to-Top Button
function initScrollToTop() {
    let topBtn = document.getElementById("back-to-top");
    if (!topBtn) {
        topBtn = document.createElement("button");
        topBtn.id = "back-to-top";
        topBtn.innerHTML = '<i class="fas fa-arrow-up"></i>';
        topBtn.style.position = "fixed";
        topBtn.style.bottom = "30px";
        topBtn.style.right = "30px";
        topBtn.style.zIndex = "99";
        topBtn.style.border = "none";
        topBtn.style.outline = "none";
        topBtn.style.background = "var(--primary)";
        topBtn.style.color = "white";
        topBtn.style.cursor = "pointer";
        topBtn.style.padding = "15px";
        topBtn.style.borderRadius = "50%";
        topBtn.style.display = "none";
        topBtn.style.boxShadow = "var(--shadow)";
        topBtn.style.transition = "0.3s";
        document.body.appendChild(topBtn);

        topBtn.addEventListener("click", () => {
            window.scrollTo({ top: 0, behavior: 'smooth' });
        });
    }

    window.onscroll = function() {
        if (document.body.scrollTop > 300 || document.documentElement.scrollTop > 300) {
            topBtn.style.display = "block";
        } else {
            topBtn.style.display = "none";
        }
    };
}

// ==========================================
// 5. Dynamic Vehicle SVGs & Garage Animation
// ==========================================

const VehicleSVGs = {
    car: `
        <svg viewBox="0 0 200 100" width="100%" height="100%">
            <!-- Shadows -->
            <ellipse cx="100" cy="85" rx="75" ry="10" fill="rgba(0,0,0,0.4)"/>
            <!-- Body Chassis -->
            <path d="M20 70 L30 45 Q35 40 45 40 L145 40 Q155 40 160 45 L175 70 Q180 73 175 78 L25 78 Q20 73 20 70 Z" fill="#0d6efd" id="car-paint"/>
            <!-- Roof / Cabin -->
            <path d="M50 40 L65 18 Q70 12 80 12 L130 12 Q140 12 145 18 L155 40 Z" fill="#1e293b"/>
            <!-- Windows -->
            <path d="M56 38 L68 20 Q70 17 75 17 L100 17 L100 38 Z" fill="#e2e8f0" opacity="0.8"/>
            <path d="M104 38 L104 17 L130 17 Q135 17 138 20 L148 38 Z" fill="#e2e8f0" opacity="0.8"/>
            <!-- Headlights -->
            <ellipse cx="25" cy="62" rx="4" ry="6" fill="#fef08a" id="headlight-left" class="glow-light"/>
            <polygon points="25,58 -50,30 -50,90 25,66" fill="rgba(254, 240, 138, 0.25)" id="headlight-beam" style="display:none;"/>
            <!-- Tail light -->
            <rect x="171" y="58" width="5" height="10" rx="2" fill="#ef4444"/>
            <!-- Wheels -->
            <g class="wheel spin-wheel" transform-origin="50 72">
                <circle cx="50" cy="72" r="16" fill="#0f172a"/>
                <circle cx="50" cy="72" r="8" fill="#94a3b8"/>
                <line x1="50" y1="56" x2="50" y2="88" stroke="#334155" stroke-width="2"/>
                <line x1="34" y1="72" x2="66" y2="72" stroke="#334155" stroke-width="2"/>
            </g>
            <g class="wheel spin-wheel" transform-origin="145 72">
                <circle cx="145" cy="72" r="16" fill="#0f172a"/>
                <circle cx="145" cy="72" r="8" fill="#94a3b8"/>
                <line x1="145" y1="56" x2="145" y2="88" stroke="#334155" stroke-width="2"/>
                <line x1="129" y1="72" x2="161" y2="72" stroke="#334155" stroke-width="2"/>
            </g>
        </svg>
    `,
    bike: `
        <svg viewBox="0 0 200 100" width="100%" height="100%">
            <ellipse cx="100" cy="85" rx="65" ry="8" fill="rgba(0,0,0,0.4)"/>
            <!-- Frame -->
            <path d="M45 72 L95 45 L140 72 M95 45 L80 25 L50 25 M95 45 L120 25" stroke="#475569" stroke-width="5" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
            <!-- Gas Tank -->
            <path d="M75 28 C95 28 115 35 110 48 C105 52 75 52 70 42 Z" fill="#ef4444" id="bike-paint"/>
            <!-- Exhaust Pipe -->
            <path d="M90 68 L145 68 L160 55" stroke="#cbd5e1" stroke-width="4" stroke-linecap="round" fill="none"/>
            <polygon points="140,65 158,54 160,57 141,68" fill="#0f172a"/>
            <!-- Headlight -->
            <circle cx="46" cy="25" r="5" fill="#fef08a" class="glow-light"/>
            <polygon points="46,22 -30,10 -30,60 46,28" fill="rgba(254, 240, 138, 0.25)" id="headlight-beam" style="display:none;"/>
            <!-- Front Wheel -->
            <g class="wheel spin-wheel" transform-origin="45 72">
                <circle cx="45" cy="72" r="18" fill="#0f172a"/>
                <circle cx="45" cy="72" r="9" fill="#94a3b8"/>
                <line x1="45" y1="54" x2="45" y2="90" stroke="#334155" stroke-width="2"/>
                <line x1="27" y1="72" x2="63" y2="72" stroke="#334155" stroke-width="2"/>
            </g>
            <!-- Rear Wheel -->
            <g class="wheel spin-wheel" transform-origin="140 72">
                <circle cx="140" cy="72" r="18" fill="#0f172a"/>
                <circle cx="140" cy="72" r="9" fill="#94a3b8"/>
                <line x1="140" y1="54" x2="140" y2="90" stroke="#334155" stroke-width="2"/>
                <line x1="122" y1="72" x2="158" y2="72" stroke="#334155" stroke-width="2"/>
            </g>
        </svg>
    `,
    scooter: `
        <svg viewBox="0 0 200 100" width="100%" height="100%">
            <ellipse cx="100" cy="85" rx="60" ry="8" fill="rgba(0,0,0,0.4)"/>
            <!-- Body Chassis -->
            <path d="M45 72 Q35 70 35 50 Q35 30 50 25 L55 25 Q60 25 65 35 L70 55 L130 55 Q150 55 155 72 Z" fill="#10b981" id="scooter-paint"/>
            <!-- Seat -->
            <path d="M90 55 C100 42 135 42 140 55 Z" fill="#78350f"/>
            <!-- Steering Column -->
            <line x1="50" y1="25" x2="60" y2="68" stroke="#64748b" stroke-width="5"/>
            <!-- Handlebar -->
            <rect x="42" y="20" width="15" height="5" rx="2" fill="#334155"/>
            <!-- Front Headlight -->
            <circle cx="42" cy="22" r="4" fill="#fef08a" class="glow-light"/>
            <polygon points="42,19 -30,10 -30,55 42,25" fill="rgba(254, 240, 138, 0.2)" id="headlight-beam" style="display:none;"/>
            <!-- Front Wheel -->
            <g class="wheel spin-wheel" transform-origin="60 72">
                <circle cx="60" cy="72" r="14" fill="#0f172a"/>
                <circle cx="60" cy="72" r="7" fill="#cbd5e1"/>
                <line x1="60" y1="58" x2="60" y2="86" stroke="#475569" stroke-width="2"/>
                <line x1="46" y1="72" x2="74" y2="72" stroke="#475569" stroke-width="2"/>
            </g>
            <!-- Rear Wheel -->
            <g class="wheel spin-wheel" transform-origin="135 72">
                <circle cx="135" cy="72" r="14" fill="#0f172a"/>
                <circle cx="135" cy="72" r="7" fill="#cbd5e1"/>
                <line x1="135" y1="58" x2="135" y2="86" stroke="#475569" stroke-width="2"/>
                <line x1="121" y1="72" x2="149" y2="72" stroke="#475569" stroke-width="2"/>
            </g>
        </svg>
    `,
    truck: `
        <svg viewBox="0 0 200 100" width="100%" height="100%">
            <ellipse cx="100" cy="85" rx="85" ry="12" fill="rgba(0,0,0,0.4)"/>
            <!-- Flatbed Back -->
            <rect x="85" y="32" width="90" height="36" rx="4" fill="#475569"/>
            <!-- Cab Cabin -->
            <path d="M25 68 L25 45 Q25 35 35 35 L80 35 L85 68 Z" fill="#f59e0b" id="truck-paint"/>
            <!-- Cab Window -->
            <path d="M35 39 L60 39 L60 52 L30 52 Z" fill="#e2e8f0" opacity="0.8"/>
            <!-- Headlight -->
            <ellipse cx="23" cy="58" rx="3" ry="5" fill="#fef08a" class="glow-light"/>
            <polygon points="23,55 -50,20 -50,90 23,61" fill="rgba(254, 240, 138, 0.25)" id="headlight-beam" style="display:none;"/>
            <!-- Front Wheel -->
            <g class="wheel spin-wheel" transform-origin="50 72">
                <circle cx="50" cy="72" r="16" fill="#0f172a"/>
                <circle cx="50" cy="72" r="8" fill="#94a3b8"/>
                <line x1="50" y1="56" x2="50" y2="88" stroke="#334155" stroke-width="2"/>
            </g>
            <!-- Middle Wheel -->
            <g class="wheel spin-wheel" transform-origin="115 72">
                <circle cx="115" cy="72" r="16" fill="#0f172a"/>
                <circle cx="115" cy="72" r="8" fill="#94a3b8"/>
                <line x1="115" y1="56" x2="115" y2="88" stroke="#334155" stroke-width="2"/>
            </g>
            <!-- Rear Wheel -->
            <g class="wheel spin-wheel" transform-origin="150 72">
                <circle cx="150" cy="72" r="16" fill="#0f172a"/>
                <circle cx="150" cy="72" r="8" fill="#94a3b8"/>
                <line x1="150" y1="56" x2="150" y2="88" stroke="#334155" stroke-width="2"/>
            </g>
        </svg>
    `
};

// Expose so premium.js can register extra vehicle types (EV, Bus) on the same object
window.VehicleSVGs = VehicleSVGs;

function loadVehicleShowcase(type = 'car', status = 'RECEIVED') {
    const avatar = document.getElementById("vehicle-avatar");
    const container = document.getElementById("garage-container");
    if (!avatar || !container) return;

    // Load correct SVG graphics
    const selectedSvg = VehicleSVGs[type.toLowerCase()] || VehicleSVGs.car;
    avatar.innerHTML = selectedSvg;

    // Remove previous classes
    container.classList.remove('lift-up', 'parked-outside', 'delivered-out');
    avatar.classList.remove('vibrate-idle', 'shine-polish');
    
    // De-activate headlight beam by default
    const beam = avatar.querySelector("#headlight-beam");
    if (beam) beam.style.display = "none";

    // Set class and animate based on status
    if (status === 'PENDING' || status === 'BOOKED') {
        container.classList.add('parked-outside');
    } else if (status === 'IN_PROGRESS' || status === 'REPAIR_STARTED' || status === 'WAITING_PARTS' || status === 'INSPECTION' || status === 'RECEIVED') {
        // Drive in
        avatar.style.left = "-200px";
        setTimeout(() => {
            avatar.style.left = "50%";
            // Toggle headlights on entry
            if (beam) {
                setTimeout(() => { beam.style.display = "block"; }, 500);
            }
            // Stop spinning wheels after arrival
            setTimeout(() => {
                avatar.querySelectorAll('.wheel').forEach(w => w.style.animation = "none");
                // Start idle vibration
                avatar.classList.add('vibrate-idle');
                
                // If In Service, lift up
                if (status !== 'RECEIVED' && status !== 'INSPECTION') {
                    container.classList.add('lift-up');
                    startSparkShower();
                }
            }, 2500);
        }, 100);
    } else if (status === 'READY' || status === 'QUALITY_CHECK') {
        avatar.style.left = "50%";
        avatar.classList.add('shine-polish');
        if (beam) beam.style.display = "block";
    } else if (status === 'DELIVERED') {
        avatar.style.left = "50%";
        setTimeout(() => {
            avatar.style.left = "calc(100% + 200px)";
            avatar.querySelectorAll('.wheel').forEach(w => w.style.animation = "spin 0.5s linear infinite");
            setTimeout(() => {
                container.classList.add('delivered-out');
            }, 2500);
        }, 1000);
    }
}

// 6. Interactive rotations and zoom logic
let isZoomed = false;
let currentRotation = 0;

function initGarageInteractions() {
    const avatar = document.getElementById("vehicle-avatar");
    if (!avatar) return;

    avatar.addEventListener("click", () => {
        // Toggle Zoom in/out
        isZoomed = !isZoomed;
        avatar.style.transform = isZoomed ? "translateX(-50%) scale(1.4)" : "translateX(-50%) scale(1)";
        window.Toast.show(isZoomed ? "Zoomed In - Inspecting Details" : "Zoomed Out", "info", 1500);
    });

    // Rotation dragging logic
    let startX = 0;
    let isDragging = false;
    const container = document.getElementById("garage-container");

    container.addEventListener("mousedown", (e) => {
        isDragging = true;
        startX = e.clientX;
    });

    container.addEventListener("mousemove", (e) => {
        if (!isDragging) return;
        const diffX = e.clientX - startX;
        currentRotation += diffX * 0.15;
        avatar.style.transform = `translateX(-50%) rotateY(${currentRotation}deg) ${isZoomed ? 'scale(1.4)' : 'scale(1)'}`;
        startX = e.clientX;
    });

    window.addEventListener("mouseup", () => {
        isDragging = false;
    });
}

// 7. Spark effects (Canvas Overlay)
function startSparkShower() {
    const container = document.getElementById("garage-container");
    if (!container) return;

    let canvas = document.getElementById("spark-canvas");
    if (!canvas) {
        canvas = document.createElement("canvas");
        canvas.id = "spark-canvas";
        canvas.style.position = "absolute";
        canvas.style.top = "0";
        canvas.style.left = "0";
        canvas.style.width = "100%";
        canvas.style.height = "100%";
        canvas.style.pointerEvents = "none";
        canvas.style.zIndex = "5";
        container.appendChild(canvas);
    }

    const ctx = canvas.getContext("2d");
    const rect = container.getBoundingClientRect();
    canvas.width = rect.width;
    canvas.height = rect.height;

    const particles = [];
    const maxParticles = 30;

    function createParticle() {
        // Emit from center where the car is lifted
        return {
            x: canvas.width / 2 + (Math.random() * 80 - 40),
            y: canvas.height - 180 + (Math.random() * 30 - 15),
            vx: Math.random() * 6 - 3,
            vy: Math.random() * -8 - 2,
            color: `rgba(255, ${150 + Math.random() * 105}, 0, ${0.7 + Math.random() * 0.3})`,
            radius: Math.random() * 2.5 + 0.5,
            life: Math.random() * 20 + 10
        };
    }

    function animateSparks() {
        // Only run if lift is active
        if (!container.classList.contains("lift-up")) {
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            return;
        }

        ctx.clearRect(0, 0, canvas.width, canvas.height);

        if (particles.length < maxParticles && Math.random() < 0.3) {
            particles.push(createParticle());
        }

        for (let i = 0; i < particles.length; i++) {
            const p = particles[i];
            ctx.beginPath();
            ctx.arc(p.x, p.y, p.radius, 0, Math.PI * 2);
            ctx.fillStyle = p.color;
            ctx.fill();

            p.x += p.vx;
            p.y += p.vy;
            p.vy += 0.3; // Gravity
            p.life--;

            if (p.life <= 0 || p.y >= canvas.height - 20) {
                particles.splice(i, 1);
                i--;
            }
        }
        requestAnimationFrame(animateSparks);
    }
    animateSparks();
}

// 8. General Document Previews
function previewDocument(filePath, fileType) {
    const modal = document.getElementById("document-preview-modal");
    const body = document.getElementById("preview-modal-body");
    if (!modal || !body) return;

    body.innerHTML = "";
    if (fileType.toLowerCase() === "pdf") {
        body.innerHTML = `<iframe src="${filePath}" width="100%" height="450px" style="border:none;"></iframe>`;
    } else {
        body.innerHTML = `<img src="${filePath}" alt="Preview" style="max-width:100%; max-height:450px; display:block; margin:0 auto; border-radius:8px;"/>`;
    }
    modal.style.display = "block";
}

function closePreview() {
    const modal = document.getElementById("document-preview-modal");
    if (modal) modal.style.display = "none";
}

// Initialize on page load
document.addEventListener("DOMContentLoaded", () => {
    initTheme();
    initRipples();
    initScrollToTop();
    initGarageInteractions();

    const themeBtn = document.getElementById("theme-toggle");
    if (themeBtn) {
        themeBtn.addEventListener("click", toggleTheme);
    }
    
    // Add real-time password strength meter listener
    const pwdInput = document.getElementById("password");
    if (pwdInput) {
        pwdInput.addEventListener("input", (e) => checkPasswordStrength(e.target.value));
    }
});