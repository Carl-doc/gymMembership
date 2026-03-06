CREATE DATABASE IF NOT EXISTS membership_db;
USE membership_db;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS tbl_logs;
DROP TABLE IF EXISTS tbl_notifications;
DROP TABLE IF EXISTS tbl_transactions;
DROP TABLE IF EXISTS tbl_member_subscriptions;
DROP TABLE IF EXISTS tbl_subscription;
DROP TABLE IF EXISTS tbl_member;
DROP TABLE IF EXISTS tbl_admin;

SET FOREIGN_KEY_CHECKS = 1;

-- =========================================
-- 1. ADMIN TABLE
-- =========================================
CREATE TABLE tbl_admin (
    admin_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('super_admin', 'admin', 'staff') DEFAULT 'admin',
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =========================================
-- 2. MEMBER TABLE
-- =========================================
CREATE TABLE tbl_member (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    member_code VARCHAR(20) NOT NULL UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    gender ENUM('male', 'female', 'other') DEFAULT 'other',
    birth_date DATE NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    address TEXT,
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    profile_image VARCHAR(255),
    status ENUM('active', 'inactive', 'expired', 'banned') DEFAULT 'active',
    joined_date DATE DEFAULT (CURRENT_DATE),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =========================================
-- 3. SUBSCRIPTION PLANS TABLE
-- =========================================
CREATE TABLE tbl_subscription (
    subscription_id INT AUTO_INCREMENT PRIMARY KEY,
    plan_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    duration_days INT NOT NULL,
    access_level ENUM('regular', 'premium', 'vip') DEFAULT 'regular',
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =========================================
-- 4. MEMBER SUBSCRIPTIONS TABLE
-- =========================================
CREATE TABLE tbl_member_subscriptions (
    member_subscription_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    subscription_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status ENUM('active', 'expired', 'cancelled', 'pending') DEFAULT 'pending',
    assigned_by INT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_member_subscriptions_member
        FOREIGN KEY (member_id) REFERENCES tbl_member(member_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_member_subscriptions_subscription
        FOREIGN KEY (subscription_id) REFERENCES tbl_subscription(subscription_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_member_subscriptions_admin
        FOREIGN KEY (assigned_by) REFERENCES tbl_admin(admin_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- =========================================
-- 5. TRANSACTIONS TABLE
-- =========================================
CREATE TABLE tbl_transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_code VARCHAR(30) NOT NULL UNIQUE,
    member_subscription_id INT NOT NULL,
    member_id INT NOT NULL,
    subscription_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method ENUM('cash', 'gcash', 'bank_transfer', 'card') DEFAULT 'cash',
    payment_status ENUM('paid', 'pending', 'failed', 'refunded') DEFAULT 'paid',
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    reference_number VARCHAR(100),
    processed_by INT NULL,
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_transactions_member_subscription
        FOREIGN KEY (member_subscription_id) REFERENCES tbl_member_subscriptions(member_subscription_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_transactions_member
        FOREIGN KEY (member_id) REFERENCES tbl_member(member_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_transactions_subscription
        FOREIGN KEY (subscription_id) REFERENCES tbl_subscription(subscription_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_transactions_admin
        FOREIGN KEY (processed_by) REFERENCES tbl_admin(admin_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- =========================================
-- 6. NOTIFICATIONS TABLE
-- =========================================
CREATE TABLE tbl_notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    title VARCHAR(150) NOT NULL,
    message TEXT NOT NULL,
    notification_type ENUM('reminder', 'expiration', 'promotion', 'announcement') DEFAULT 'reminder',
    is_read TINYINT(1) DEFAULT 0,
    sent_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_notifications_member
        FOREIGN KEY (member_id) REFERENCES tbl_member(member_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- =========================================
-- 7. LOGS TABLE
-- =========================================
CREATE TABLE tbl_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    admin_id INT NULL,
    action VARCHAR(255) NOT NULL,
    description TEXT,
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_logs_admin
        FOREIGN KEY (admin_id) REFERENCES tbl_admin(admin_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- =========================================
-- SAMPLE DATA
-- =========================================

INSERT INTO tbl_admin (full_name, email, password, role, status)
VALUES
('System Admin', 'admin@gym.com', '$2a$10$abcdefghijklmnopqrstuv', 'super_admin', 'active'),
('Staff User', 'staff@gym.com', '$2a$10$abcdefghijklmnopqrstuv', 'staff', 'active');

INSERT INTO tbl_subscription (plan_name, description, price, duration_days, access_level, status)
VALUES
('Regular', 'Basic gym access', 800.00, 30, 'regular', 'active'),
('Premium', 'Gym access with group classes', 1500.00, 30, 'premium', 'active'),
('VIP', 'Full gym access with trainer support', 2500.00, 30, 'vip', 'active');

INSERT INTO tbl_member (
    member_code, first_name, last_name, gender, birth_date, email, phone, address,
    emergency_contact_name, emergency_contact_phone, status, joined_date
) VALUES
('MBR-001', 'John', 'Doe', 'male', '2000-05-10', 'john@example.com', '09123456789', 'Tacloban City',
 'Jane Doe', '09987654321', 'active', CURDATE()),
('MBR-002', 'Maria', 'Santos', 'female', '1998-08-21', 'maria@example.com', '09111222333', 'Ormoc City',
 'Pedro Santos', '09998887777', 'active', CURDATE());

INSERT INTO tbl_member_subscriptions (
    member_id, subscription_id, start_date, end_date, status, assigned_by, notes
) VALUES
(1, 2, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 30 DAY), 'active', 1, 'Premium plan assigned'),
(2, 3, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 30 DAY), 'active', 1, 'VIP plan assigned');

INSERT INTO tbl_transactions (
    transaction_code, member_subscription_id, member_id, subscription_id,
    amount, payment_method, payment_status, reference_number, processed_by, remarks
) VALUES
('TRX-1001', 1, 1, 2, 1500.00, 'cash', 'paid', 'CASH-1001', 1, 'Initial premium membership payment'),
('TRX-1002', 2, 2, 3, 2500.00, 'gcash', 'paid', 'GCASH-1002', 1, 'Initial VIP membership payment');

INSERT INTO tbl_notifications (
    member_id, title, message, notification_type, is_read
) VALUES
(1, 'Membership Reminder', 'Your membership will expire soon. Please renew on time.', 'reminder', 0),
(2, 'Promo Offer', 'Upgrade next month and enjoy added benefits.', 'promotion', 0);

INSERT INTO tbl_logs (
    admin_id, action, description, ip_address
) VALUES
(1, 'Created Member', 'Added member John Doe', '127.0.0.1'),
(1, 'Processed Payment', 'Recorded VIP payment for Maria Santos', '127.0.0.1');