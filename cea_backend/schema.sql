-- ============================================================
--  cea_lab_system — Full Database Schema
--  Run this in phpMyAdmin → cea_lab_system → SQL tab
-- ============================================================

CREATE TABLE IF NOT EXISTS students (
    student_id     INT AUTO_INCREMENT PRIMARY KEY,
    name           VARCHAR(100) NOT NULL,
    email          VARCHAR(100) UNIQUE,
    student_number VARCHAR(50)  UNIQUE NOT NULL,
    course         VARCHAR(50),
    year_level     INT,
    id_image       VARCHAR(255),
    password       VARCHAR(255) NOT NULL,
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS equipment (
    equipment_id   INT AUTO_INCREMENT PRIMARY KEY,
    equipment_name VARCHAR(100) NOT NULL,
    category       VARCHAR(50)  NOT NULL,
    qr_code        VARCHAR(100) UNIQUE NOT NULL,
    status         VARCHAR(20)  DEFAULT 'Available',
    location       VARCHAR(100),
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS staff (
    staff_id   INT AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(100) NOT NULL,
    email      VARCHAR(100) UNIQUE NOT NULL,
    password   VARCHAR(255) NOT NULL,
    role       VARCHAR(50)  DEFAULT 'staff',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS borrow_transactions (
    transaction_id   INT AUTO_INCREMENT PRIMARY KEY,
    student_id       INT,
    equipment_id     INT NOT NULL,
    borrower_name    VARCHAR(100),
    student_number   VARCHAR(50),
    subject          VARCHAR(100),
    quantity         INT DEFAULT 1,
    borrow_date      DATETIME DEFAULT CURRENT_TIMESTAMP,
    due_date         DATETIME,
    return_date      DATETIME,
    purpose          TEXT,
    status           VARCHAR(20) DEFAULT 'Pending',
    condition_returned VARCHAR(50),
    FOREIGN KEY (student_id)  REFERENCES students(student_id)  ON DELETE SET NULL,
    FOREIGN KEY (equipment_id) REFERENCES equipment(equipment_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS damage_reports (
    report_id      INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id INT,
    equipment_id   INT,
    student_id     INT,
    description    TEXT NOT NULL,
    image          VARCHAR(255),
    reported_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (transaction_id) REFERENCES borrow_transactions(transaction_id) ON DELETE SET NULL,
    FOREIGN KEY (equipment_id)   REFERENCES equipment(equipment_id) ON DELETE SET NULL,
    FOREIGN KEY (student_id)     REFERENCES students(student_id)    ON DELETE SET NULL
);

-- ============================================================
--  Sample staff account (password: admin123)
--  The hash below is bcrypt of "admin123"
-- ============================================================
INSERT IGNORE INTO staff (name, email, password, role) VALUES
('Maria Cruz', 'admin@neu.edu.ph', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin');

-- ============================================================
--  Sample equipment (with QR codes)
-- ============================================================
INSERT IGNORE INTO equipment (equipment_name, category, qr_code, status, location) VALUES
('Digital Multimeter',  'Electronics',   'ELE-001', 'Available', 'Cabinet A'),
('Oscilloscope',        'Electronics',   'ELE-002', 'Available', 'Cabinet A'),
('Breadboard Kit',      'Electronics',   'ELE-003', 'Available', 'Cabinet B'),
('Soldering Iron Kit',  'Tools',         'TOO-001', 'Available', 'Cabinet C'),
('Vernier Caliper',     'Measurement',   'MEA-001', 'Available', 'Cabinet D'),
('Micrometer',          'Measurement',   'MEA-002', 'Available', 'Cabinet D'),
('Optical Lens Set',    'Optics',        'OPT-001', 'Available', 'Cabinet E'),
('Power Supply Unit',   'Electronics',   'ELE-004', 'Available', 'Cabinet A'),
('Arduino Kit',         'Microcontroller','MIC-001','Available', 'Cabinet B');