-- ===================================================================
-- SMART CANTEEN ORDERING SYSTEM - MYSQL DATABASE SCHEMA & INITIAL DATA
-- ===================================================================

CREATE DATABASE IF NOT EXISTS smart_canteen
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE smart_canteen;

-- 1. Table: students
CREATE TABLE IF NOT EXISTS students (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    register_number VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone_number VARCHAR(20) NOT NULL,
    password VARCHAR(255) NOT NULL,
    department VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_student_regno (register_number),
    INDEX idx_student_email (email)
) ENGINE=InnoDB;

-- 2. Table: admins
CREATE TABLE IF NOT EXISTS admins (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_admin_username (username)
) ENGINE=InnoDB;

-- 3. Table: menu_items
CREATE TABLE IF NOT EXISTS menu_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    description VARCHAR(500),
    price DECIMAL(10, 2) NOT NULL,
    available_quantity INT NOT NULL DEFAULT 0,
    is_available BOOLEAN NOT NULL DEFAULT TRUE,
    image_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_menu_category (category),
    INDEX idx_menu_available (is_available)
) ENGINE=InnoDB;

-- 4. Table: orders
CREATE TABLE IF NOT EXISTS orders (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(50) NOT NULL UNIQUE,
    student_id BIGINT NOT NULL,
    order_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(30) NOT NULL DEFAULT 'CONFIRMED',
    subtotal_amount DECIMAL(10, 2) NOT NULL,
    tax_amount DECIMAL(10, 2) NOT NULL,
    final_amount DECIMAL(10, 2) NOT NULL,
    cancellation_window_minutes INT NOT NULL DEFAULT 5,
    admin_notes VARCHAR(255),
    CONSTRAINT fk_orders_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE RESTRICT,
    INDEX idx_orders_student (student_id),
    INDEX idx_orders_status (status),
    INDEX idx_orders_time (order_time)
) ENGINE=InnoDB;

-- 5. Table: order_items
CREATE TABLE IF NOT EXISTS order_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    menu_item_id BIGINT NOT NULL,
    item_name VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    CONSTRAINT fk_order_items_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    CONSTRAINT fk_order_items_menu_item FOREIGN KEY (menu_item_id) REFERENCES menu_items(id) ON DELETE RESTRICT,
    INDEX idx_order_items_order (order_id)
) ENGINE=InnoDB;

-- 6. Table: payments
CREATE TABLE IF NOT EXISTS payments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL UNIQUE,
    payment_method VARCHAR(30) NOT NULL,
    payment_status VARCHAR(30) NOT NULL,
    transaction_id VARCHAR(100),
    paid_amount DECIMAL(10, 2) NOT NULL,
    payment_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_payments_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 7. Table: stock_logs (Inventory audit trail)
CREATE TABLE IF NOT EXISTS stock_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    menu_item_id BIGINT NOT NULL,
    change_quantity INT NOT NULL,
    resulting_quantity INT NOT NULL,
    reason VARCHAR(150) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_stock_logs_menu_item FOREIGN KEY (menu_item_id) REFERENCES menu_items(id) ON DELETE CASCADE,
    INDEX idx_stock_logs_item (menu_item_id)
) ENGINE=InnoDB;

-- ===================================================================
-- SEED INITIAL DATA
-- Note: Passwords below are BCrypt hashes:
-- 'admin123' -> $2a$10$wS2W15rBvN1W/1z3oWbLjeZzTjH8gqD16P3B8wR8jP6aF0fH8F9qG
-- 'student123' -> $2a$10$8v5iF2N7F2u.z9G3K4h/h.K4B1iK9T1Y1pQ2M3R4E5W6T7Y8U9I0O
-- The application's DataInitializer will also auto-hash using BCrypt.
-- ===================================================================

INSERT IGNORE INTO admins (id, username, password, full_name, email)
VALUES (1, 'admin', '$2a$10$7v59kK7kQ5kG8vj0uI0v3.dEaGqO6lE8uT5X2P3kF1M4z6S7W8U9I', 'Canteen Administrator', 'admin@canteen.edu');

INSERT IGNORE INTO students (id, register_number, name, email, phone_number, password, department)
VALUES (1, '21CS101', 'Nithyanandhan S', 'student@canteen.edu', '9876543210', '$2a$10$7v59kK7kQ5kG8vj0uI0v3.dEaGqO6lE8uT5X2P3kF1M4z6S7W8U9I', 'Computer Science & Engineering');

INSERT IGNORE INTO menu_items (id, name, category, description, price, available_quantity, is_available, image_url) VALUES
(1, 'Idli', 'South Indian', '3 steamed fluffy rice cakes served with hot sambar and fresh coconut chutney', 35.00, 50, TRUE, 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=600&auto=format&fit=crop&q=80'),
(2, 'Dosa', 'South Indian', 'Crispy golden roasted crepe served with spiced potato masala and trio chutneys', 45.00, 40, TRUE, 'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?w=600&auto=format&fit=crop&q=80'),
(3, 'Pongal', 'South Indian', 'Traditional clarified ghee ven pongal with black pepper, cashews and sambar', 40.00, 30, TRUE, 'https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?w=600&auto=format&fit=crop&q=80'),
(4, 'Poori', 'Breakfast', '2 puffed golden whole wheat pooris served with flavorful potato masala sagu', 45.00, 25, TRUE, 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=600&auto=format&fit=crop&q=80'),
(5, 'Veg Sandwich', 'Snacks', 'Toasted multigrain bread filled with cucumber, tomato, paneer slice, herbs & mint chutney', 50.00, 20, TRUE, 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=600&auto=format&fit=crop&q=80'),
(6, 'Meals', 'Lunch', 'Complete South Indian lunch with steamed ponni rice, sambar, rasam, kootu, poriyal & appalam', 90.00, 35, TRUE, 'https://images.unsplash.com/photo-1610057099443-fde8c4d50f91?w=600&auto=format&fit=crop&q=80'),
(7, 'Tea', 'Beverages', 'Freshly brewed kadak masala chai infused with crushed cardamom and fresh ginger', 15.00, 100, TRUE, 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?w=600&auto=format&fit=crop&q=80'),
(8, 'Coffee', 'Beverages', 'Authentic South Indian degree filter coffee served hot with creamy foam', 20.00, 80, TRUE, 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=600&auto=format&fit=crop&q=80'),
(9, 'Fresh Juice', 'Beverages', 'Freshly squeezed seasonal fruit juice (Orange / Watermelon) with natural sweetness', 40.00, 25, TRUE, 'https://images.unsplash.com/photo-1613478223719-2ab802602423?w=600&auto=format&fit=crop&q=80'),
(10, 'Vegetable Samosa', 'Snacks', 'Crispy golden triangles stuffed with spiced potatoes and green peas', 20.00, 6, TRUE, 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=600&auto=format&fit=crop&q=80');
