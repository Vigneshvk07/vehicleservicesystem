/* =====================================================================
   premium3d.js  —  Holographic wireframe vehicle visualization
   ---------------------------------------------------------------------
   Renders a semi-transparent CAD / X-ray blueprint vehicle using
   procedurally-generated Three.js geometry (no external GLTF assets
   required). Monochrome only: black background, white edge glow, grey
   polygon mesh. Includes: slow auto-rotation, floating motion, camera
   orbit, breathing glow, sweeping scan line, self-drawing blueprint
   reveal, particle dust, animated grid floor + glossy reflection, and
   mouse / scroll / hover interactivity.

   Public API (window.PM3D):
     PM3D.mount(canvasId, initialType)   -> boot a scene on a <canvas>
     PM3D.select(type)                   -> swap the displayed vehicle
   ===================================================================== */
(function () {
    "use strict";

    if (typeof THREE === "undefined") {
        console.warn("[PM3D] Three.js not available — 3D vehicle disabled.");
        return;
    }

    var prefersReduced = window.matchMedia &&
        window.matchMedia("(prefers-reduced-motion: reduce)").matches;

    /* ---- palette (monochrome only) ---- */
    var COL_EDGE = 0xffffff;   // white outline edges
    var COL_MESH = 0x8b93a1;   // faint grey polygon mesh
    var COL_GRID = 0x1c1f26;

    /* ---------------------------------------------------------------
       Vehicle type normalization (DB values -> model keys)
       --------------------------------------------------------------- */
    function normalizeType(type) {
        if (!type) return "sedan";
        var t = String(type).toLowerCase();
        if (t.indexOf("ev") === 0 || t.indexOf("electric") >= 0) return "ev";
        if (t.indexOf("suv") >= 0) return "suv";
        if (t.indexOf("hatch") >= 0) return "hatchback";
        if (t.indexOf("bike") >= 0 || t.indexOf("motor") >= 0 || t.indexOf("scoot") >= 0) return "bike";
        if (t.indexOf("truck") >= 0 || t.indexOf("lorry") >= 0 || t.indexOf("bus") >= 0) return "truck";
        if (t.indexOf("sedan") >= 0 || t.indexOf("car") >= 0) return "sedan";
        return "sedan";
    }

    /* ---------------------------------------------------------------
       Material factories — fresh instances each call so parts can be
       faded / highlighted independently.
       --------------------------------------------------------------- */
    function glassMat() {
        return new THREE.MeshStandardMaterial({
            color: 0xffffff, metalness: 0.95, roughness: 0.12,
            transparent: true, opacity: 0.05, depthWrite: false
        });
    }
    function edgeMat() {
        return new THREE.LineBasicMaterial({ color: COL_EDGE, transparent: true, opacity: 0.9 });
    }
    function wireMat() {
        return new THREE.LineBasicMaterial({ color: COL_MESH, transparent: true, opacity: 0.06 });
    }

    /* Build one part: glass surface + white edges + faint polygon mesh.
       Registers the part for the draw-on reveal and for hover highlight. */
    function addPart(store, geo, pos, opts) {
        opts = opts || {};
        var g = new THREE.Group();

        var mesh = new THREE.Mesh(geo, glassMat());
        var edges = new THREE.LineSegments(new THREE.EdgesGeometry(geo, opts.edgeAngle || 18), edgeMat());
        var wire = new THREE.LineSegments(new THREE.WireframeGeometry(geo), wireMat());

        g.add(mesh); g.add(edges); g.add(wire);
        if (pos) g.position.set(pos[0], pos[1], pos[2]);

        store.group.add(g);
        store.parts.push({ group: g, mesh: mesh, edges: edges, wire: wire, x: (pos ? pos[0] : 0), wheel: !!opts.wheel });
        if (opts.wheel) store.wheels.push(g);
        return g;
    }

    /* A wheel: torus tire (axle along Z) + rim circle + spokes.
       Spin by rotating the group about Z. */
    function addWheel(store, x, z, radius, width) {
        var tire = new THREE.TorusGeometry(radius, width * 0.5, 8, 24);
        var wheelGroup = addPart(store, tire, [x, radius, z], { wheel: true, edgeAngle: 22 });

        // rim outline
        var rim = new THREE.CircleGeometry(radius * 0.55, 20);
        wheelGroup.add(new THREE.LineSegments(new THREE.EdgesGeometry(rim), edgeMat()));
        var hub = new THREE.CircleGeometry(radius * 0.16, 12);
        wheelGroup.add(new THREE.LineSegments(new THREE.EdgesGeometry(hub), edgeMat()));

        // spokes
        for (var s = 0; s < 5; s++) {
            var spoke = new THREE.CylinderGeometry(0.018, 0.018, radius, 4);
            var spokeEdges = new THREE.LineSegments(new THREE.EdgesGeometry(spoke, 1), edgeMat());
            spokeEdges.position.y = radius * 0.28;
            var pivot = new THREE.Group();
            pivot.add(spokeEdges);
            pivot.rotation.z = (s / 5) * Math.PI * 2;
            wheelGroup.add(pivot);
        }
        return wheelGroup;
    }

    function addHeadlights(store, x, y, zSpread) {
        var lights = [];
        [-zSpread, zSpread].forEach(function (z) {
            var geo = new THREE.SphereGeometry(0.14, 12, 12);
            var g = addPart(store, geo, [x, y, z], { edgeAngle: 30 });
            var light = new THREE.PointLight(0xffffff, 0.0, 6, 2);
            light.position.set(x + 0.4, y, z);
            store.group.add(light);
            lights.push(light);
        });
        store.headlights = lights;
    }

    /* ---------------------------------------------------------------
       Per-type builders — return nothing, populate `store`.
       Convention: +X = front of vehicle.
       --------------------------------------------------------------- */
    function buildCarLike(store, cfg) {
        // lower body
        addPart(store, new THREE.BoxGeometry(cfg.len, cfg.bodyH, cfg.width), [0, cfg.bodyH / 2 + cfg.wheelR * 0.55, 0]);
        // cabin / greenhouse
        addPart(store, new THREE.BoxGeometry(cfg.cabinLen, cfg.cabinH, cfg.width * 0.9),
            [cfg.cabinX, cfg.bodyH + cfg.wheelR * 0.55 + cfg.cabinH / 2 - 0.02, 0], { edgeAngle: 12 });
        // hood + trunk slopes (thin wedges as boxes)
        addPart(store, new THREE.BoxGeometry(cfg.len * 0.22, cfg.bodyH * 0.5, cfg.width * 0.96),
            [cfg.len * 0.36, cfg.bodyH * 0.9 + cfg.wheelR * 0.55, 0], { edgeAngle: 25 });
        // wheels
        var wx = cfg.len * 0.32, wz = cfg.width / 2 - 0.05;
        addWheel(store, wx, wz, cfg.wheelR, cfg.wheelW);
        addWheel(store, wx, -wz, cfg.wheelR, cfg.wheelW);
        addWheel(store, -wx, wz, cfg.wheelR, cfg.wheelW);
        addWheel(store, -wx, -wz, cfg.wheelR, cfg.wheelW);
        addHeadlights(store, cfg.len / 2 - 0.05, cfg.bodyH * 0.75 + cfg.wheelR * 0.55, cfg.width / 2 - 0.35);
    }

    var BUILDERS = {
        sedan: function (s) { buildCarLike(s, { len: 4.2, width: 1.8, bodyH: 0.7, cabinLen: 2.0, cabinH: 0.62, cabinX: -0.15, wheelR: 0.46, wheelW: 0.32 }); },
        hatchback: function (s) { buildCarLike(s, { len: 3.5, width: 1.75, bodyH: 0.72, cabinLen: 1.9, cabinH: 0.7, cabinX: -0.35, wheelR: 0.44, wheelW: 0.3 }); },
        suv: function (s) { buildCarLike(s, { len: 4.4, width: 1.95, bodyH: 0.9, cabinLen: 2.4, cabinH: 0.82, cabinX: -0.1, wheelR: 0.56, wheelW: 0.38 }); },
        ev: function (s) { buildCarLike(s, { len: 4.3, width: 1.85, bodyH: 0.66, cabinLen: 2.5, cabinH: 0.6, cabinX: -0.05, wheelR: 0.48, wheelW: 0.34 }); s.breathe = 1.8; },
        truck: function (s) {
            // cab
            addPart(s, new THREE.BoxGeometry(1.5, 1.4, 2.0), [1.9, 0.45 + 0.7, 0], { edgeAngle: 14 });
            // chassis
            addPart(s, new THREE.BoxGeometry(5.2, 0.5, 2.0), [0, 0.45 + 0.25, 0]);
            // cargo
            addPart(s, new THREE.BoxGeometry(3.2, 1.7, 2.05), [-1.1, 0.45 + 1.15, 0], { edgeAngle: 12 });
            var wz = 0.95;
            addWheel(s, 1.9, wz, 0.55, 0.4); addWheel(s, 1.9, -wz, 0.55, 0.4);
            addWheel(s, -1.4, wz, 0.55, 0.4); addWheel(s, -1.4, -wz, 0.55, 0.4);
            addWheel(s, -2.3, wz, 0.55, 0.4); addWheel(s, -2.3, -wz, 0.55, 0.4);
            addHeadlights(s, 2.65, 1.0, 0.7);
        },
        bike: function (s) {
            var R = 0.62, wz = 0;
            // wheels (both on centerline, spaced along X)
            addWheel(s, 1.05, wz, R, 0.18);
            addWheel(s, -1.05, wz, R, 0.18);
            // frame tubes
            var f1 = new THREE.CylinderGeometry(0.05, 0.05, 1.6, 6); f1.rotateZ(Math.PI / 2.6);
            addPart(s, f1, [0.15, 0.9, 0], { edgeAngle: 1 });
            var f2 = new THREE.CylinderGeometry(0.05, 0.05, 1.3, 6); f2.rotateZ(-Math.PI / 3);
            addPart(s, f2, [-0.35, 0.85, 0], { edgeAngle: 1 });
            // tank + seat
            addPart(s, new THREE.BoxGeometry(1.0, 0.4, 0.5), [0.15, 1.15, 0], { edgeAngle: 16 });
            addPart(s, new THREE.BoxGeometry(0.9, 0.18, 0.45), [-0.55, 1.15, 0], { edgeAngle: 16 });
            // handlebar
            var hb = new THREE.CylinderGeometry(0.03, 0.03, 0.7, 6);
            addPart(s, hb, [1.0, 1.35, 0], { edgeAngle: 1 });
            addHeadlights(s, 1.35, 1.15, 0);
        }
    };

    /* ---------------------------------------------------------------
       Scene controller
       --------------------------------------------------------------- */
    function Viewer(canvas, initialType) {
        this.canvas = canvas;
        this.type = normalizeType(initialType);
        this.mouse = { x: 0, y: 0 };
        this.hover = new THREE.Vector2(-2, -2);
        this.scrollTilt = 0;
        this.clock = new THREE.Clock();
        this.raycaster = new THREE.Raycaster();
        this.running = true;
        this._init();
    }

    Viewer.prototype._init = function () {
        var w = this.canvas.clientWidth || this.canvas.offsetWidth || 800;
        var h = this.canvas.clientHeight || this.canvas.offsetHeight || 500;

        this.renderer = new THREE.WebGLRenderer({ canvas: this.canvas, antialias: true, alpha: true });
        this.renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
        this.renderer.setSize(w, h, false);
        this.renderer.setClearColor(0x000000, 0);

        this.scene = new THREE.Scene();
        this.scene.fog = new THREE.FogExp2(0x000000, 0.055);

        this.camera = new THREE.PerspectiveCamera(34, w / h, 0.1, 100);
        this.camera.position.set(7.4, 3.0, 9.2);
        this.camera.lookAt(0, 0.6, 0);

        // lighting — minimal, cool white
        this.scene.add(new THREE.AmbientLight(0x707880, 0.7));
        var key = new THREE.DirectionalLight(0xffffff, 0.9); key.position.set(5, 8, 6); this.scene.add(key);
        var rim = new THREE.DirectionalLight(0xbfd0ff, 0.5); rim.position.set(-6, 4, -5); this.scene.add(rim);

        this._buildFloor();
        this._buildParticles();
        this._buildScanLine();
        this._buildVehicle(this.type);

        this._bind();
        this._loop();
    };

    Viewer.prototype._buildFloor = function () {
        this.grid = new THREE.GridHelper(60, 60, COL_GRID, COL_GRID);
        this.grid.material.transparent = true;
        this.grid.material.opacity = 0.5;
        this.grid.position.y = 0;
        this.scene.add(this.grid);

        // glossy floor plane
        var floor = new THREE.Mesh(
            new THREE.PlaneGeometry(80, 80),
            new THREE.MeshStandardMaterial({ color: 0x05060a, metalness: 0.9, roughness: 0.35, transparent: true, opacity: 0.85 })
        );
        floor.rotation.x = -Math.PI / 2;
        floor.position.y = -0.001;
        this.scene.add(floor);
    };

    Viewer.prototype._buildParticles = function () {
        var N = 260, pos = new Float32Array(N * 3);
        for (var i = 0; i < N; i++) {
            pos[i * 3] = (Math.random() - 0.5) * 18;
            pos[i * 3 + 1] = Math.random() * 6;
            pos[i * 3 + 2] = (Math.random() - 0.5) * 12;
        }
        var geo = new THREE.BufferGeometry();
        geo.setAttribute("position", new THREE.Float32BufferAttribute(pos, 3));
        this.dust = new THREE.Points(geo, new THREE.PointsMaterial({
            color: 0xffffff, size: 0.03, transparent: true, opacity: 0.5, depthWrite: false
        }));
        this.scene.add(this.dust);
    };

    Viewer.prototype._buildScanLine = function () {
        var geo = new THREE.PlaneGeometry(0.06, 4.2);
        geo.rotateX(-Math.PI / 2);
        this.scan = new THREE.Mesh(geo, new THREE.MeshBasicMaterial({
            color: 0xffffff, transparent: true, opacity: 0.0, blending: THREE.AdditiveBlending, depthWrite: false
        }));
        this.scan.position.y = 0.02;
        this.scene.add(this.scan);
    };

    Viewer.prototype._buildVehicle = function (type) {
        this._disposeVehicle();

        var store = { group: new THREE.Group(), parts: [], wheels: [], headlights: [], breathe: 1 };
        (BUILDERS[type] || BUILDERS.sedan)(store);
        this.scene.add(store.group);
        this.vehicle = store;

        // reflection (mirror across floor y=0), faint
        var rstore = { group: new THREE.Group(), parts: [], wheels: [], headlights: [], breathe: 1 };
        (BUILDERS[type] || BUILDERS.sedan)(rstore);
        rstore.group.scale.y = -1;
        rstore.parts.forEach(function (p) {
            p.edges.material.opacity = 0.12;
            p.wire.material.opacity = 0.02;
            p.mesh.material.opacity = 0.015;
        });
        this.scene.add(rstore.group);
        this.reflection = rstore;

        this._drawOn(store);
    };

    /* Self-drawing blueprint reveal: fade parts in, front (+X) to back. */
    Viewer.prototype._drawOn = function (store) {
        var ordered = store.parts.slice().sort(function (a, b) { return b.x - a.x; });
        ordered.forEach(function (p) { p.edges.material.opacity = 0; p.wire.material.opacity = 0; p.mesh.material.opacity = 0; });

        if (prefersReduced || typeof gsap === "undefined") {
            ordered.forEach(function (p) { p.edges.material.opacity = 0.9; p.wire.material.opacity = 0.06; p.mesh.material.opacity = 0.05; });
            return;
        }
        ordered.forEach(function (p, i) {
            var d = i * 0.09;
            gsap.to(p.edges.material, { opacity: 0.9, duration: 0.8, delay: d, ease: "power2.out" });
            gsap.to(p.wire.material, { opacity: 0.06, duration: 0.8, delay: d });
            gsap.to(p.mesh.material, { opacity: 0.05, duration: 0.8, delay: d });
        });
    };

    Viewer.prototype._disposeVehicle = function () {
        var self = this;
        [this.vehicle, this.reflection].forEach(function (s) {
            if (!s) return;
            self.scene.remove(s.group);
            s.parts.forEach(function (p) {
                p.mesh.geometry.dispose(); p.mesh.material.dispose();
                p.edges.geometry.dispose(); p.edges.material.dispose();
                p.wire.geometry.dispose(); p.wire.material.dispose();
            });
        });
        this.vehicle = null; this.reflection = null;
    };

    Viewer.prototype._bind = function () {
        var self = this;

        this._onMove = function (e) {
            var r = self.canvas.getBoundingClientRect();
            var cx = (e.clientX - r.left) / r.width;
            var cy = (e.clientY - r.top) / r.height;
            self.mouse.x = cx * 2 - 1;
            self.mouse.y = cy * 2 - 1;
            self.hover.x = self.mouse.x;
            self.hover.y = -(self.mouse.y);
        };
        this._onLeave = function () { self.hover.set(-2, -2); self.mouse.x = 0; self.mouse.y = 0; };
        window.addEventListener("mousemove", this._onMove);
        this.canvas.addEventListener("mouseleave", this._onLeave);

        this._onScroll = function () {
            var max = window.innerHeight || 800;
            self.scrollTilt = Math.min(window.scrollY / max, 1);
        };
        window.addEventListener("scroll", this._onScroll, { passive: true });

        this._onResize = function () {
            var w = self.canvas.clientWidth, h = self.canvas.clientHeight;
            if (!w || !h) return;
            self.camera.aspect = w / h;
            self.camera.updateProjectionMatrix();
            self.renderer.setSize(w, h, false);
        };
        window.addEventListener("resize", this._onResize);

        this._onVis = function () { self.running = !document.hidden; if (self.running) { self.clock.getDelta(); self._loop(); } };
        document.addEventListener("visibilitychange", this._onVis);
    };

    Viewer.prototype._updateHover = function () {
        if (!this.vehicle) return;
        var hit = null;
        if (this.hover.x > -1.5) {
            this.raycaster.setFromCamera(this.hover, this.camera);
            var meshes = this.vehicle.parts.map(function (p) { return p.mesh; });
            var hits = this.raycaster.intersectObjects(meshes, false);
            if (hits.length) hit = hits[0].object;
        }
        var wheelsHot = false;
        this.vehicle.parts.forEach(function (p) {
            var on = (p.mesh === hit);
            var targetEdge = on ? 1.0 : 0.9;
            var targetGlass = on ? 0.16 : 0.05;
            p.edges.material.opacity += (targetEdge - p.edges.material.opacity) * 0.15;
            p.mesh.material.opacity += (targetGlass - p.mesh.material.opacity) * 0.15;
            if (on && p.wheel) wheelsHot = true;
        });
        this._wheelsHot = wheelsHot;
        // headlight glow when hovering the front of the model
        var target = (hit ? 1.6 : 0.0);
        (this.vehicle.headlights || []).forEach(function (l) { l.intensity += (target - l.intensity) * 0.1; });
    };

    Viewer.prototype._loop = function () {
        if (!this.running) return;
        var self = this;
        this._raf = requestAnimationFrame(function () { self._loop(); });

        var dt = this.clock.getDelta();
        var t = this.clock.elapsedTime;
        var speed = prefersReduced ? 0 : 1;

        if (this.vehicle) {
            // slow continuous rotation + mouse influence
            var base = this.vehicle.group.rotation.y + dt * 0.25 * speed;
            var targetY = base + this.mouse.x * 0.35;
            this.vehicle.group.rotation.y = targetY;
            var targetX = this.mouse.y * 0.12 + this.scrollTilt * 0.15;
            this.vehicle.group.rotation.x += (targetX - this.vehicle.group.rotation.x) * 0.06;
            // floating
            var floatY = Math.sin(t * 0.9) * 0.08 * speed;
            this.vehicle.group.position.y = floatY;

            // breathing edge glow
            var breathe = 0.78 + Math.sin(t * (1.2 * (this.vehicle.breathe || 1))) * 0.12;
            this.vehicle.parts.forEach(function (p) {
                if (!self._hoverActive) p.edges.material.opacity = breathe;
            });

            // wheel spin on hover
            if (this._wheelsHot && speed) {
                this.vehicle.wheels.forEach(function (w) { w.rotation.z -= dt * 2.2; });
            }

            // sync reflection
            if (this.reflection) {
                this.reflection.group.rotation.y = this.vehicle.group.rotation.y;
                this.reflection.group.rotation.x = -this.vehicle.group.rotation.x;
                this.reflection.group.position.y = -floatY;
            }
        }

        this._updateHover();

        // sweeping scan line (front -> back)
        if (this.scan) {
            var period = 4.0;
            var phase = (t % period) / period;
            this.scan.position.x = 3.0 - phase * 6.0;
            this.scan.material.opacity = speed ? (0.5 * Math.sin(phase * Math.PI)) : 0;
        }

        // drifting dust
        if (this.dust && speed) {
            var arr = this.dust.geometry.attributes.position.array;
            for (var i = 1; i < arr.length; i += 3) {
                arr[i] += dt * 0.15;
                if (arr[i] > 6) arr[i] = 0;
            }
            this.dust.geometry.attributes.position.needsUpdate = true;
            this.dust.rotation.y += dt * 0.02;
        }

        // subtle camera orbit + grid breathing
        var orbit = Math.sin(t * 0.15) * 0.6 * speed;
        this.camera.position.x = 7.4 + orbit;
        this.camera.position.y = 3.0 - this.scrollTilt * 1.0;
        this.camera.lookAt(0, 0.6, 0);
        if (this.grid) this.grid.material.opacity = 0.35 + Math.sin(t * 0.8) * 0.1;

        this.renderer.render(this.scene, this.camera);
    };

    Viewer.prototype.select = function (type) {
        var norm = normalizeType(type);
        if (norm === this.type && this.vehicle) return;
        this.type = norm;
        this._buildVehicle(norm);
    };

    /* ---------------------------------------------------------------
       Public API
       --------------------------------------------------------------- */
    var _viewers = {};
    window.PM3D = {
        mount: function (canvasId, initialType) {
            var canvas = document.getElementById(canvasId);
            if (!canvas) return null;
            try {
                var v = new Viewer(canvas, initialType);
                _viewers[canvasId] = v;
                return v;
            } catch (err) {
                console.warn("[PM3D] init failed:", err);
                return null;
            }
        },
        select: function (type, canvasId) {
            var v = canvasId ? _viewers[canvasId] : _viewers[Object.keys(_viewers)[0]];
            if (v) v.select(type);
        },
        normalizeType: normalizeType
    };
})();
