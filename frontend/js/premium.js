/* ============================================================
   premium.js — Premium animated homepage behaviours
   Depends on: GSAP + ScrollTrigger (loaded from CDN in index.jsp),
   and script.js (VehicleSVGs / loadVehicleShowcase).
   Everything degrades gracefully if GSAP is unavailable.
   ============================================================ */
(function () {
    "use strict";

    var prefersReduced = window.matchMedia &&
        window.matchMedia("(prefers-reduced-motion: reduce)").matches;

    /* --------------------------------------------------------
       1. Premium loading screen (logo + wheel + progress bar)
       -------------------------------------------------------- */
    function initLoader() {
        var loader = document.getElementById("pm-loader");
        if (!loader) return;
        var bar = loader.querySelector(".pm-loader-bar span");
        var pct = loader.querySelector(".pm-loader-pct");
        var progress = 0;

        var tick = setInterval(function () {
            // Ease towards 90% then wait for window load to finish
            progress += Math.random() * 12;
            if (progress > 90) progress = 90;
            if (bar) bar.style.width = progress + "%";
            if (pct) pct.textContent = Math.floor(progress) + "%";
        }, 160);

        function finish() {
            clearInterval(tick);
            if (bar) bar.style.width = "100%";
            if (pct) pct.textContent = "100%";
            // Optional engine ignition sound (silent-fail if blocked)
            tryIgnitionSound();
            setTimeout(function () {
                loader.classList.add("hidden");
                document.body.classList.add("pm-loaded");
            }, 450);
        }

        if (document.readyState === "complete") {
            setTimeout(finish, 600);
        } else {
            window.addEventListener("load", function () { setTimeout(finish, 400); });
        }
        // Safety timeout so the loader never gets stuck
        setTimeout(finish, 6000);
    }

    function tryIgnitionSound() {
        try {
            var Ctx = window.AudioContext || window.webkitAudioContext;
            if (!Ctx) return;
            var ctx = new Ctx();
            var o = ctx.createOscillator();
            var g = ctx.createGain();
            o.type = "sawtooth";
            o.frequency.setValueAtTime(60, ctx.currentTime);
            o.frequency.exponentialRampToValueAtTime(180, ctx.currentTime + 0.4);
            g.gain.setValueAtTime(0.0001, ctx.currentTime);
            g.gain.exponentialRampToValueAtTime(0.06, ctx.currentTime + 0.05);
            g.gain.exponentialRampToValueAtTime(0.0001, ctx.currentTime + 0.6);
            o.connect(g); g.connect(ctx.destination);
            o.start(); o.stop(ctx.currentTime + 0.65);
        } catch (e) { /* autoplay blocked — ignore */ }
    }

    /* --------------------------------------------------------
       2. Hero particles + smoke (lightweight canvas)
       -------------------------------------------------------- */
    function initHeroParticles() {
        var canvas = document.getElementById("pm-hero-canvas");
        if (!canvas || prefersReduced) return;
        var ctx = canvas.getContext("2d");
        var particles = [];
        var smoke = [];

        function resize() {
            var hero = canvas.parentElement;
            canvas.width = hero.offsetWidth;
            canvas.height = hero.offsetHeight;
        }
        resize();
        window.addEventListener("resize", resize);

        for (var i = 0; i < 60; i++) {
            particles.push(spawnParticle());
        }
        for (var j = 0; j < 6; j++) {
            smoke.push(spawnSmoke(Math.random() * canvas.height));
        }

        function spawnParticle() {
            return {
                x: Math.random() * canvas.width,
                y: Math.random() * canvas.height,
                r: Math.random() * 1.8 + 0.4,
                vx: (Math.random() - 0.5) * 0.3,
                vy: -Math.random() * 0.5 - 0.1,
                a: Math.random() * 0.5 + 0.1,
                blue: Math.random() > 0.4
            };
        }
        function spawnSmoke(y) {
            return {
                x: Math.random() * canvas.width,
                y: y == null ? canvas.height + 60 : y,
                r: Math.random() * 90 + 60,
                vy: -(Math.random() * 0.25 + 0.1),
                a: Math.random() * 0.05 + 0.02
            };
        }

        function frame() {
            ctx.clearRect(0, 0, canvas.width, canvas.height);

            // Drifting smoke
            for (var s = 0; s < smoke.length; s++) {
                var sm = smoke[s];
                var grad = ctx.createRadialGradient(sm.x, sm.y, 0, sm.x, sm.y, sm.r);
                grad.addColorStop(0, "rgba(120,140,170," + sm.a + ")");
                grad.addColorStop(1, "rgba(120,140,170,0)");
                ctx.fillStyle = grad;
                ctx.beginPath();
                ctx.arc(sm.x, sm.y, sm.r, 0, Math.PI * 2);
                ctx.fill();
                sm.y += sm.vy;
                sm.x += 0.15;
                if (sm.y + sm.r < 0) { smoke[s] = spawnSmoke(); }
            }

            // Floating light particles
            for (var p = 0; p < particles.length; p++) {
                var pt = particles[p];
                ctx.beginPath();
                ctx.arc(pt.x, pt.y, pt.r, 0, Math.PI * 2);
                ctx.fillStyle = pt.blue
                    ? "rgba(0,179,255," + pt.a + ")"
                    : "rgba(255,106,0," + pt.a + ")";
                ctx.fill();
                pt.x += pt.vx;
                pt.y += pt.vy;
                if (pt.y < -5 || pt.x < -5 || pt.x > canvas.width + 5) {
                    particles[p] = spawnParticle();
                    particles[p].y = canvas.height + 5;
                }
            }
            requestAnimationFrame(frame);
        }
        frame();
    }

    /* --------------------------------------------------------
       3. Mouse-follow lighting + parallax hero
       -------------------------------------------------------- */
    function initMouseLight() {
        var light = document.getElementById("pm-mouse-light");
        var photo = document.querySelector(".pm-hero-bg .layer-photo");
        if (prefersReduced) return;
        document.addEventListener("mousemove", function (e) {
            if (light) {
                light.style.transform = "translate(" + e.clientX + "px," + e.clientY + "px)";
            }
            if (photo && window.scrollY < window.innerHeight) {
                var dx = (e.clientX / window.innerWidth - 0.5) * 20;
                var dy = (e.clientY / window.innerHeight - 0.5) * 20;
                photo.style.transform = "translate(" + dx + "px," + dy + "px) scale(1.08)";
            }
        });
    }

    /* --------------------------------------------------------
       4. Scroll effects (GSAP ScrollTrigger with CSS fallback)
       -------------------------------------------------------- */
    function initScrollEffects() {
        var revealEls = document.querySelectorAll(".pm-reveal");

        if (window.gsap && window.ScrollTrigger && !prefersReduced) {
            gsap.registerPlugin(ScrollTrigger);

            revealEls.forEach(function (el) {
                var dir = el.getAttribute("data-reveal") || "up";
                var from = { opacity: 0 };
                if (dir === "up") from.y = 50;
                if (dir === "left") from.x = -60;
                if (dir === "right") from.x = 60;
                if (dir === "scale") from.scale = 0.9;
                gsap.fromTo(el, from, {
                    opacity: 1, x: 0, y: 0, scale: 1,
                    duration: 0.9, ease: "power3.out",
                    scrollTrigger: { trigger: el, start: "top 85%" }
                });
            });

            // Parallax garage / hero photo on scroll
            gsap.utils.toArray(".pm-parallax").forEach(function (el) {
                gsap.to(el, {
                    yPercent: 18, ease: "none",
                    scrollTrigger: { trigger: el, start: "top bottom", end: "bottom top", scrub: true }
                });
            });
        } else {
            // Fallback: IntersectionObserver toggles .is-visible
            if ("IntersectionObserver" in window) {
                var io = new IntersectionObserver(function (entries) {
                    entries.forEach(function (en) {
                        if (en.isIntersecting) { en.target.classList.add("is-visible"); io.unobserve(en.target); }
                    });
                }, { threshold: 0.15 });
                revealEls.forEach(function (el) { io.observe(el); });
            } else {
                revealEls.forEach(function (el) { el.classList.add("is-visible"); });
            }
        }
    }

    /* --------------------------------------------------------
       5. Floating ambient icons
       -------------------------------------------------------- */
    function initFloatingIcons() {
        if (prefersReduced) return;
        var wrap = document.querySelector(".pm-float-icons");
        if (!wrap) return;
        var icons = ["fa-wrench", "fa-car", "fa-gear", "fa-oil-can", "fa-bolt", "fa-gauge-high", "fa-screwdriver-wrench", "fa-car-battery"];
        for (var i = 0; i < 8; i++) {
            var el = document.createElement("i");
            el.className = "fas " + icons[i % icons.length];
            el.style.left = Math.random() * 100 + "%";
            el.style.top = Math.random() * 100 + "%";
            el.style.animationDelay = (Math.random() * 8) + "s";
            el.style.fontSize = (24 + Math.random() * 28) + "px";
            wrap.appendChild(el);
        }
    }

    /* --------------------------------------------------------
       6. Enhanced cinematic garage orchestration
          Wraps the existing loadVehicleShowcase (script.js).
       -------------------------------------------------------- */
    function registerExtraVehicles() {
        if (!window.VehicleSVGs) return;
        // Electric vehicle — sleek EV with charging bolt
        window.VehicleSVGs.ev = window.VehicleSVGs.ev || `
            <svg viewBox="0 0 200 100" width="100%" height="100%">
                <ellipse cx="100" cy="85" rx="78" ry="10" fill="rgba(0,0,0,0.4)"/>
                <path d="M18 68 L34 46 Q40 40 52 40 L150 40 Q162 42 172 55 L182 68 Q186 72 181 77 L23 77 Q18 73 18 68 Z" fill="#00b3ff" id="ev-paint"/>
                <path d="M52 40 L66 20 Q72 14 84 14 L128 14 Q140 14 146 22 L156 40 Z" fill="#0f172a"/>
                <path d="M60 38 L70 22 L100 22 L100 38 Z" fill="#bae6fd" opacity="0.85"/>
                <path d="M104 38 L104 22 L126 22 Q132 22 136 26 L146 38 Z" fill="#bae6fd" opacity="0.85"/>
                <!-- charging bolt -->
                <path d="M150 30 l-8 14 h6 l-4 12 12 -16 h-6 z" fill="#ffd43b" class="glow-light"/>
                <ellipse cx="23" cy="60" rx="4" ry="6" fill="#e0f2fe" id="headlight-left" class="glow-light"/>
                <polygon points="23,56 -50,28 -50,88 23,64" fill="rgba(224,242,254,0.28)" id="headlight-beam" style="display:none;"/>
                <rect x="177" y="56" width="5" height="10" rx="2" fill="#ef4444"/>
                <g class="wheel spin-wheel" transform-origin="52 74">
                    <circle cx="52" cy="74" r="16" fill="#0f172a"/><circle cx="52" cy="74" r="8" fill="#38bdf8"/>
                    <line x1="52" y1="58" x2="52" y2="90" stroke="#0369a1" stroke-width="2"/><line x1="36" y1="74" x2="68" y2="74" stroke="#0369a1" stroke-width="2"/>
                </g>
                <g class="wheel spin-wheel" transform-origin="150 74">
                    <circle cx="150" cy="74" r="16" fill="#0f172a"/><circle cx="150" cy="74" r="8" fill="#38bdf8"/>
                    <line x1="150" y1="58" x2="150" y2="90" stroke="#0369a1" stroke-width="2"/><line x1="134" y1="74" x2="166" y2="74" stroke="#0369a1" stroke-width="2"/>
                </g>
            </svg>`;
        // Bus — long body with rows of windows
        window.VehicleSVGs.bus = window.VehicleSVGs.bus || `
            <svg viewBox="0 0 200 100" width="100%" height="100%">
                <ellipse cx="100" cy="86" rx="88" ry="10" fill="rgba(0,0,0,0.4)"/>
                <path d="M12 70 L12 26 Q12 20 20 20 L182 20 Q188 20 188 26 L188 70 Q188 74 184 74 L16 74 Q12 74 12 70 Z" fill="#ff6a00" id="bus-paint"/>
                <rect x="20" y="28" width="18" height="16" rx="2" fill="#e2e8f0" opacity="0.85"/>
                <rect x="44" y="28" width="18" height="16" rx="2" fill="#e2e8f0" opacity="0.85"/>
                <rect x="68" y="28" width="18" height="16" rx="2" fill="#e2e8f0" opacity="0.85"/>
                <rect x="92" y="28" width="18" height="16" rx="2" fill="#e2e8f0" opacity="0.85"/>
                <rect x="116" y="28" width="18" height="16" rx="2" fill="#e2e8f0" opacity="0.85"/>
                <rect x="140" y="28" width="18" height="16" rx="2" fill="#e2e8f0" opacity="0.85"/>
                <rect x="164" y="28" width="16" height="30" rx="2" fill="#bae6fd" opacity="0.85"/>
                <ellipse cx="16" cy="60" rx="3" ry="5" fill="#fef08a" id="headlight-left" class="glow-light"/>
                <polygon points="16,57 -50,28 -50,86 16,63" fill="rgba(254,240,138,0.25)" id="headlight-beam" style="display:none;"/>
                <g class="wheel spin-wheel" transform-origin="48 74">
                    <circle cx="48" cy="74" r="15" fill="#0f172a"/><circle cx="48" cy="74" r="7" fill="#94a3b8"/>
                    <line x1="48" y1="59" x2="48" y2="89" stroke="#334155" stroke-width="2"/>
                </g>
                <g class="wheel spin-wheel" transform-origin="150 74">
                    <circle cx="150" cy="74" r="15" fill="#0f172a"/><circle cx="150" cy="74" r="7" fill="#94a3b8"/>
                    <line x1="150" y1="59" x2="150" y2="89" stroke="#334155" stroke-width="2"/>
                </g>
            </svg>`;
    }

    // Map various DB type spellings to an SVG key
    function normalizeType(type) {
        if (!type) return "car";
        var t = String(type).toLowerCase();
        if (t.indexOf("ev") === 0 || t.indexOf("electric") >= 0) return "ev";
        if (t.indexOf("bus") >= 0) return "bus";
        if (t.indexOf("bike") >= 0 || t.indexOf("motor") >= 0) return "bike";
        if (t.indexOf("scoot") >= 0) return "scooter";
        if (t.indexOf("truck") >= 0 || t.indexOf("lorry") >= 0) return "truck";
        return "car";
    }

    function ensureGarageElements() {
        var container = document.getElementById("garage-container");
        if (!container || container.dataset.pmEnhanced) return;
        container.dataset.pmEnhanced = "1";

        container.insertAdjacentHTML("afterbegin",
            '<div class="pm-garage-floor"></div>' +
            '<div class="pm-headlight-glow"></div>' +
            '<div class="pm-vehicle-reflection" id="pm-vehicle-reflection"></div>');

        container.insertAdjacentHTML("beforeend",
            '<div class="pm-garage-door"><div class="door-label">VSS Service Bay</div></div>' +
            '<div class="pm-scanner"></div>' +
            '<div class="pm-robot-arm"><div class="arm"></div><div class="head"></div></div>' +
            '<div class="pm-mechanic m1"><div class="head"></div><div class="body"></div></div>' +
            '<div class="pm-mechanic m2"><div class="head"></div><div class="body"></div></div>' +
            '<div class="pm-complete-badge"><i class="fas fa-circle-check"></i> Service Completed</div>');
    }

    function syncReflection() {
        var avatar = document.getElementById("vehicle-avatar");
        var reflection = document.getElementById("pm-vehicle-reflection");
        if (avatar && reflection) reflection.innerHTML = avatar.innerHTML;
    }

    // Dust particles emitted when the vehicle brakes to a stop
    function emitBrakeDust() {
        if (prefersReduced) return;
        var container = document.getElementById("garage-container");
        if (!container) return;
        var canvas = document.getElementById("pm-dust-canvas");
        if (!canvas) {
            canvas = document.createElement("canvas");
            canvas.id = "pm-dust-canvas";
            canvas.style.cssText = "position:absolute;inset:0;width:100%;height:100%;pointer-events:none;z-index:9;";
            container.appendChild(canvas);
        }
        var rect = container.getBoundingClientRect();
        canvas.width = rect.width; canvas.height = rect.height;
        var ctx = canvas.getContext("2d");
        var dust = [];
        for (var i = 0; i < 26; i++) {
            dust.push({
                x: canvas.width / 2 - 90 + Math.random() * 40,
                y: canvas.height - 70 + Math.random() * 20,
                vx: -(Math.random() * 2 + 0.5),
                vy: -(Math.random() * 1.5),
                r: Math.random() * 8 + 4,
                a: 0.5
            });
        }
        function draw() {
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            var alive = false;
            dust.forEach(function (d) {
                if (d.a <= 0) return;
                alive = true;
                ctx.beginPath();
                ctx.arc(d.x, d.y, d.r, 0, Math.PI * 2);
                ctx.fillStyle = "rgba(180,180,175," + d.a + ")";
                ctx.fill();
                d.x += d.vx; d.y += d.vy; d.r += 0.4; d.a -= 0.012;
            });
            if (alive) requestAnimationFrame(draw);
            else ctx.clearRect(0, 0, canvas.width, canvas.height);
        }
        draw();
    }

    var _serviceStates = ["IN_PROGRESS", "REPAIR_STARTED", "WAITING_PARTS", "QUALITY_CHECK"];

    // Drive the cinematic stage sequencing on top of the base animation
    function applyGarageStage(type, status) {
        var container = document.getElementById("garage-container");
        if (!container) return;
        status = (status || "RECEIVED").toUpperCase();

        container.classList.remove("door-open", "lights-on", "servicing", "completed");

        var drivesIn = ["RECEIVED", "INSPECTION"].indexOf(status) >= 0 || _serviceStates.indexOf(status) >= 0;

        if (drivesIn) {
            // Open door, then lights + reflection + brake dust as it parks
            setTimeout(function () { container.classList.add("door-open"); }, 200);
            setTimeout(function () { container.classList.add("lights-on"); syncReflection(); }, 900);
            setTimeout(function () { emitBrakeDust(); }, 2500);
            // Service stage: robot arm, scanner, mechanics
            if (_serviceStates.indexOf(status) >= 0) {
                setTimeout(function () { container.classList.add("servicing"); }, 3000);
            }
            // Close the door again after the vehicle is inside
            setTimeout(function () { container.classList.remove("door-open"); }, 4200);
        } else if (status === "READY") {
            container.classList.add("door-open", "lights-on", "completed");
            syncReflection();
        } else if (status === "DELIVERED") {
            container.classList.add("door-open", "completed");
            syncReflection();
            setTimeout(function () { container.classList.remove("door-open"); }, 4500);
        }
    }

    function wrapShowcase() {
        if (typeof window.loadVehicleShowcase !== "function") return;
        if (window.loadVehicleShowcase.__pmWrapped) return;
        var original = window.loadVehicleShowcase;
        var wrapped = function (type, status) {
            ensureGarageElements();
            var key = normalizeType(type);
            original(key, status);
            // reflection mirrors the freshly injected SVG
            setTimeout(syncReflection, 50);
            applyGarageStage(key, status);
        };
        wrapped.__pmWrapped = true;
        window.loadVehicleShowcase = wrapped;
    }

    /* --------------------------------------------------------
       Init
       -------------------------------------------------------- */
    // Wrap as early as possible so the inline DOMContentLoaded call is enhanced
    registerExtraVehicles();
    wrapShowcase();

    document.addEventListener("DOMContentLoaded", function () {
        registerExtraVehicles();
        wrapShowcase();
        initLoader();
        initHeroParticles();
        initMouseLight();
        initFloatingIcons();
        initScrollEffects();
    });
})();
