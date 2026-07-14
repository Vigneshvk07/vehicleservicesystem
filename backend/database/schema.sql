-- Create Database
CREATE DATABASE IF NOT EXISTS vehicleservicesystem;
USE vehicleservicesystem;

-- 1. Users Table (Customers, Admins, Employees)
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15) NOT NULL,
    password_hash VARCHAR(64) NOT NULL, -- SHA-256
    role VARCHAR(20) NOT NULL DEFAULT 'CUSTOMER', -- 'CUSTOMER', 'ADMIN', 'EMPLOYEE'
    profile_pic VARCHAR(255) DEFAULT NULL,
    referral_code VARCHAR(20) DEFAULT NULL,
    loyalty_points INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_email (email),
    INDEX idx_user_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Vehicles Table
CREATE TABLE IF NOT EXISTS vehicles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    vehicle_number VARCHAR(20) NOT NULL UNIQUE,
    type VARCHAR(20) NOT NULL, -- 'Car', 'Bike', 'Scooter', 'Truck'
    brand VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    year INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_vehicle_customer (customer_id),
    INDEX idx_vehicle_number (vehicle_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Service Packages Table
CREATE TABLE IF NOT EXISTS service_packages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    cost DECIMAL(10, 2) NOT NULL,
    duration_hours INT NOT NULL DEFAULT 2
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Mechanics Table
CREATE TABLE IF NOT EXISTS mechanics (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL,
    specialization VARCHAR(100),
    status VARCHAR(20) NOT NULL DEFAULT 'AVAILABLE' -- 'AVAILABLE', 'BUSY'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Bookings Table
CREATE TABLE IF NOT EXISTS bookings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    vehicle_id INT NOT NULL,
    package_id INT NOT NULL,
    booking_date DATE NOT NULL,
    preferred_time VARCHAR(20) NOT NULL, -- e.g., '10:00 AM'
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING', -- 'PENDING', 'RECEIVED', 'INSPECTION', 'REPAIR_STARTED', 'WAITING_PARTS', 'QUALITY_CHECK', 'READY', 'DELIVERED', 'CANCELLED'
    notes TEXT,
    mechanic_id INT DEFAULT NULL,
    total_cost DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    pickup_drop VARCHAR(20) NOT NULL DEFAULT 'NONE', -- 'NONE', 'PICKUP', 'DROP', 'BOTH'
    pickup_address VARCHAR(255) DEFAULT NULL,
    coupon_code VARCHAR(20) DEFAULT NULL,
    discount_amount DECIMAL(10, 2) DEFAULT 0.00,
    estimated_delivery DATETIME DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
    FOREIGN KEY (package_id) REFERENCES service_packages(id) ON DELETE CASCADE,
    FOREIGN KEY (mechanic_id) REFERENCES mechanics(id) ON DELETE SET NULL,
    INDEX idx_booking_customer (customer_id),
    INDEX idx_booking_status (status),
    INDEX idx_booking_date (booking_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. Spare Parts Table
CREATE TABLE IF NOT EXISTS spare_parts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    cost DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. Booking Spare Parts Table
CREATE TABLE IF NOT EXISTS booking_parts (
    booking_id INT NOT NULL,
    part_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    PRIMARY KEY (booking_id, part_id),
    FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
    FOREIGN KEY (part_id) REFERENCES spare_parts(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. Invoices Table
CREATE TABLE IF NOT EXISTS invoices (
    id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL UNIQUE,
    invoice_number VARCHAR(50) NOT NULL UNIQUE,
    issue_date DATE NOT NULL,
    service_cost DECIMAL(10, 2) NOT NULL,
    part_cost DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    tax DECIMAL(10, 2) NOT NULL DEFAULT 0.00, -- 18% GST
    discount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    total_amount DECIMAL(10, 2) NOT NULL,
    payment_status VARCHAR(20) NOT NULL DEFAULT 'UNPAID', -- 'UNPAID', 'PAID'
    FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
    INDEX idx_invoice_number (invoice_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 9. Document Management Table (DL, Insurance, PUC, RC, Vehicle Photo)
CREATE TABLE IF NOT EXISTS documents (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT DEFAULT NULL, -- for DL, Aadhar, etc.
    vehicle_id INT DEFAULT NULL, -- for RC, Insurance, PUC, Vehicle Photo
    document_type VARCHAR(50) NOT NULL, -- 'DL', 'RC', 'INSURANCE', 'PUC', 'AADHAR', 'VEHICLE_PHOTO'
    file_name VARCHAR(100) DEFAULT NULL,
    file_path VARCHAR(255) NOT NULL,
    file_size BIGINT NOT NULL,
    expiry_date DATE DEFAULT NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
    INDEX idx_doc_user (user_id),
    INDEX idx_doc_vehicle (vehicle_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 10. Vehicle Health Reports Table
CREATE TABLE IF NOT EXISTS vehicle_health (
    id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT NOT NULL UNIQUE,
    battery_health INT DEFAULT 95, -- percentage
    engine_condition INT DEFAULT 90, -- percentage
    brake_status INT DEFAULT 85, -- percentage
    oil_level INT DEFAULT 100, -- percentage
    tyre_condition INT DEFAULT 80, -- percentage
    coolant_level INT DEFAULT 95, -- percentage
    overall_health INT DEFAULT 90, -- percentage
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 11. Payments Table
CREATE TABLE IF NOT EXISTS payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    invoice_id INT NOT NULL,
    payment_method VARCHAR(30) NOT NULL, -- 'CASH', 'UPI', 'CARD', 'NET_BANKING'
    payment_status VARCHAR(20) NOT NULL DEFAULT 'PENDING', -- 'PENDING', 'PAID', 'FAILED'
    transaction_id VARCHAR(100) DEFAULT NULL UNIQUE,
    payment_amount DECIMAL(10, 2) NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE,
    INDEX idx_payment_invoice (invoice_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 12. Feedback, Complaints & Reviews Table
CREATE TABLE IF NOT EXISTS feedback_complaints (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    booking_id INT DEFAULT NULL,
    type VARCHAR(20) NOT NULL, -- 'FEEDBACK', 'COMPLAINT', 'REVIEW'
    message TEXT NOT NULL,
    rating INT DEFAULT NULL, -- 1 to 5 for feedback/reviews
    status VARCHAR(20) NOT NULL DEFAULT 'OPEN', -- 'OPEN', 'RESOLVED', 'CLOSED'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 13. Wishlist Table (Favorite Service Packages)
CREATE TABLE IF NOT EXISTS wishlist (
    user_id INT NOT NULL,
    package_id INT NOT NULL,
    PRIMARY KEY (user_id, package_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (package_id) REFERENCES service_packages(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 14. Coupon Codes Table
CREATE TABLE IF NOT EXISTS coupons (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    discount_percent DECIMAL(5, 2) NOT NULL,
    max_discount DECIMAL(10, 2) NOT NULL,
    expiry_date DATE NOT NULL,
    active BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 15. Recent Activities Table (Dashboard Logs)
CREATE TABLE IF NOT EXISTS recent_activities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT DEFAULT NULL,
    description TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==========================================
-- SEED DATA
-- ==========================================

-- Default Admins and Customers
-- Default Admin password is "admin123" -> SHA-256 hash: 240751543329eb9687e91404c0ec40ffd227e85c8f85f1c91c33f06cb7526ee8
INSERT INTO users (name, email, phone, password_hash, role, loyalty_points) VALUES 
('System Admin', 'admin@vss.com', '9876543210', '240751543329eb9687e91404c0ec40ffd227e85c8f85f1c91c33f06cb7526ee8', 'ADMIN', 100),
('Customer Vignesh', 'customer@vss.com', '8765432109', '240751543329eb9687e91404c0ec40ffd227e85c8f85f1c91c33f06cb7526ee8', 'CUSTOMER', 250)
ON DUPLICATE KEY UPDATE id=id;

-- Service Packages
INSERT INTO service_packages (name, description, cost, duration_hours) VALUES
('General Service', 'Complete vehicle inspection, air filter cleaning, chain lubrication, and general tuning.', 1500.00, 3),
('Oil Change', 'Premium engine oil replacement and oil filter check.', 800.00, 1),
('Brake Service', 'Brake pad replacement, disc cleaning, and brake fluid top-up.', 1200.00, 2),
('Engine Repair', 'Full engine diagnostic, block cleaning, piston ring replacement, and cylinder work.', 7000.00, 8),
('Wheel Alignment', 'Precision wheel alignment and balancing with counterweight adjustments.', 1000.00, 1),
('Battery Service', 'Battery health checkup, terminal cleaning, and battery replacement if needed.', 500.00, 1),
('Water Wash', 'Full pressure foam wash, underbody cleaning, and detailing polish.', 350.00, 2),
('Insurance Renewal', 'Document verification and vehicle insurance renewal assistance.', 0.00, 1),
('Emergency Service', 'On-road breakdown assistance, towing service, and quick troubleshooting.', 2000.00, 2)
ON DUPLICATE KEY UPDATE id=id;

-- Mechanics
INSERT INTO mechanics (name, phone, specialization, status) VALUES
('Ramesh Kumar', '9988776655', 'Engine Tuning & Repairs', 'AVAILABLE'),
('Suresh Raina', '8877665544', 'Electricals & Battery Services', 'AVAILABLE'),
('John Doe', '7766554433', 'Wheel Balancing & Alignments', 'AVAILABLE'),
('Murugan Pillai', '6655443322', 'General Washing & Detailing', 'AVAILABLE')
ON DUPLICATE KEY UPDATE id=id;

-- Spare Parts
INSERT INTO spare_parts (name, cost, quantity) VALUES
('Engine Oil (Castrol 1L)', 450.00, 50),
('Brake Pads (Front)', 350.00, 30),
('Air Filter', 220.00, 40),
('Spark Plug', 120.00, 100),
('Battery (Exide 12V)', 2800.00, 15),
('Clutch Cable', 180.00, 25)
ON DUPLICATE KEY UPDATE id=id;

-- Seed Coupon Code
INSERT INTO coupons (code, discount_percent, max_discount, expiry_date, active) VALUES
('WELCOME10', 10.00, 500.00, '2027-12-31', TRUE),
('VSSCOMP50', 50.00, 2000.00, '2027-12-31', TRUE)
ON DUPLICATE KEY UPDATE id=id;
