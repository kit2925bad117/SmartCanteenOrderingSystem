# Smart Canteen Ordering System 🍽️

A modern, full-stack, enterprise-grade college canteen pre-ordering and kitchen management web application developed with **Java Spring Boot**, **MySQL**, **Spring Data JPA**, and responsive **HTML5/CSS3/JavaScript (Bootstrap 5.3)**.

---

## 📋 Academic Problem Statement & Core Requirements

> *"Develop a Smart Canteen Ordering System with student registration, menu management, order placement, billing and order status. Use ArrayList, Queue and HashMap."*

This project satisfies all requirements:
1. **End-to-End Workflow**: Student registration, authentication, browsing menu, live stock validation, cart management, checkout with itemized billing, visual order tracking, 5-minute cancellation window, thermal slip receipt generation.
2. **Administrator Portal**: Dedicated login, dashboard analytics, menu CRUD, stock management, automatic low-stock alerts, live FIFO kitchen queue board, and date-range sales reports.
3. **Mandatory Java Data Structures**: Implemented in actual backend service logic with thread-safety and database synchronization.
4. **Relational Database Design**: Comprehensive MySQL schema (`students`, `admins`, `menu_items`, `orders`, `order_items`, `payments`, `stock_logs`) with transactions and referential integrity.

---

## 🧠 Mandatory Java Data Structures Implementation

All three required data structures are implemented in backend services:

### 1. `ArrayList` (`java.util.ArrayList<MenuItem>`)
- **Location**: [`MenuService.java`](file:///c:/Users/Nithy/Desktop/smartsystem/src/main/java/com/canteen/smartsystem/service/MenuService.java)
- **Role**: Maintains a working in-memory collection of food menu items.
- **Operations Implemented**:
  - `getAllMenuItemsAsList()`: Returns working `ArrayList<MenuItem>`.
  - `filterByCategory(String category)`: Traverses `ArrayList` to filter items dynamically (Breakfast, South Indian, Lunch, Snacks, Beverages).
  - `searchMenuItems(String query)`: Traverses `ArrayList` for real-time text matching across item names and descriptions.
  - `getLowStockItemsList(int threshold)`: Filters and sorts low-stock items using `ArrayList.sort()`.
  - `addMenuItem()`, `updateMenuItem()`, `deleteMenuItem()`: Dynamically modifies the `ArrayList` and database in sync.

### 2. `Queue` (`java.util.Queue<Long>` / `ConcurrentLinkedQueue`)
- **Location**: [`OrderQueueService.java`](file:///c:/Users/Nithy/Desktop/smartsystem/src/main/java/com/canteen/smartsystem/service/OrderQueueService.java)
- **Role**: Implements a strict **First-In, First-Out (FIFO)** queue for incoming canteen kitchen orders.
- **Operations Implemented**:
  - `enqueueOrder(Long orderId)`: Enqueues confirmed orders into the FIFO preparation queue.
  - `pollNextOrder()`: Dequeues the oldest order waiting in queue when kitchen staff click **"Process Next Order (FIFO)"**, transitioning it to `PREPARING`.
  - `peekNextOrder()`: Peeks at the order currently at the head of the queue.
  - `removeOrderFromQueue(Long orderId)`: Removes an order from the queue if cancelled within the cancellation window.
  - **Restart Persistence & Reconstruction**: The queue is reconstructed on server startup via `@PostConstruct` by querying MySQL for pending/confirmed orders ordered by `orderTime ASC`!
  - **Thread-Safety**: Uses `ConcurrentLinkedQueue` and `synchronized` blocks to handle concurrent order submissions safely.

### 3. `HashMap` (`java.util.HashMap` / `ConcurrentHashMap`)
- **Location**: [`CacheLookupService.java`](file:///c:/Users/Nithy/Desktop/smartsystem/src/main/java/com/canteen/smartsystem/service/CacheLookupService.java)
- **Role**: Provides **$O(1)$ constant-time fast lookup** for student records and active order tracking.
- **Operations Implemented**:
  - `studentMap`: Keyed by uppercase Register Number (`getStudentByRegisterNumber("21CS101")`).
  - `orderMap`: Keyed by unique Order Number (`getOrderByOrderNumber("ORD-20261027-...")`).
  - `putStudent()`, `putOrder()`, `updateOrderStatus()`: Synchronized on every database modification, maintaining cache consistency.
  - **Pre-loading**: Automatically loads database records into the HashMaps upon application startup.

> 💡 **Live Diagnostic Panel**: Click the **"Data Structures Live"** badge on the top navigation bar or query `GET /api/academic/data-structures-status` to inspect the live sizes, types, and operations of all three data structures in real time!

---

## 🖥️ 16 Built Pages & Views

| # | View | Description | Access |
|---|------|-------------|--------|
| 1 | **Home Page** | Hero banner, value propositions, popular food specials, process overview | Public |
| 2 | **Student Registration** | Validated form with unique RegNo, email, phone, and BCrypt password | Public |
| 3 | **Student Login** | Student authentication with demo 1-click auto-fill credentials | Public |
| 4 | **Admin Login** | Secure dark-themed canteen staff portal login with demo auto-fill | Public |
| 5 | **Student Dashboard** | Welcome banner, active live order alert cards, recent orders | Student |
| 6 | **Food Menu Page** | Category filter pills, instant search, stock badges, Add-to-Cart | Public/Student |
| 7 | **Shopping Cart** | Item list, quantity increment/decrement, 5% GST tax calculation | Public/Student |
| 8 | **Checkout & Billing** | Student review, dietary notes, payment selection (Cash/UPI/Card) | Student |
| 9 | **Order Tracking Page** | 5-step visual progress stepper, live 5-min cancellation timer, cancel button | Student |
| 10 | **Student Order History** | Historical orders table with items, date/time, status badges, view bill | Student |
| 11 | **Admin Dashboard** | Daily sales revenue, queue length, preparing count, low stock alert counter | Admin |
| 12 | **Menu Management** | Food items CRUD table, Add/Edit modal, toggle availability, quick restock | Admin |
| 13 | **Order Management & Queue** | Live visual FIFO Queue conveyor belt + All Orders status transition manager | Admin |
| 14 | **Inventory & Alerts** | Configurable low-stock threshold, warning badges, stock movement audit logs | Admin |
| 15 | **Sales Reports** | Date-range filters, total revenue, average order value, top-selling items | Admin |
| 16 | **Student Profile** | Permitted details update, password change, simulated Digital Student ID Pass | Student |

---

## 🗄️ Database Schema (`canteen_mysql_setup.sql`)

The database consists of 7 normalized relational tables:
- `students`: `id`, `register_number` (UNIQUE), `name`, `email` (UNIQUE), `phone_number`, `password` (BCrypt), `department`, `created_at`
- `admins`: `id`, `username` (UNIQUE), `password` (BCrypt), `full_name`, `email` (UNIQUE), `created_at`
- `menu_items`: `id`, `name`, `category`, `description`, `price`, `available_quantity`, `is_available`, `image_url`
- `orders`: `id`, `order_number` (UNIQUE), `student_id` (FK), `order_time`, `status`, `subtotal_amount`, `tax_amount`, `final_amount`, `cancellation_window_minutes`
- `order_items`: `id`, `order_id` (FK), `menu_item_id` (FK), `item_name`, `unit_price`, `quantity`, `subtotal`
- `payments`: `id`, `order_id` (FK, UNIQUE), `payment_method`, `payment_status`, `transaction_id`, `paid_amount`, `payment_time`
- `stock_logs`: `id`, `menu_item_id` (FK), `change_quantity`, `resulting_quantity`, `reason`, `timestamp`

---

## 🚀 Running the Application on Windows

### Prerequisites
- **Java**: JDK 21 or JDK 25 (Java 25 LTS is already installed on this machine).
- **Maven**: Maven wrapper `mvnw.bat` is included in the project root.
- **MySQL**: (Optional for production; application defaults to `dev` profile with zero-config in-memory database in MySQL mode).

### Step 1: Run with Default In-Memory Mode (Immediate Execution)
Double-click or run from PowerShell / Terminal:
```powershell
.\mvnw.bat spring-boot:run
```
The server will start at: **`http://localhost:8080/`**

### Step 2: Running with Local MySQL Server (Production Mode)
1. Start your local MySQL service (e.g., via MySQL Workbench, XAMPP, or Services).
2. Execute the included SQL setup script:
   ```powershell
   mysql -u root -p < canteen_mysql_setup.sql
   ```
3. Run the application with the `mysql` profile:
   ```powershell
   .\mvnw.bat spring-boot:run -Dspring-boot.run.profiles=mysql
   ```
   *(Or change `spring.profiles.active=mysql` in `src/main/resources/application.properties`).*

### Step 3: Run Unit & Integration Tests
To verify all data structures, order placement, stock reduction, and cancellation logic:
```powershell
.\mvnw.bat test
```

---

## 🔑 Default Credentials

| Role | Identifier / Username | Password | Notes |
|------|------------------------|----------|-------|
| **Student** | `21CS101` (or `student@canteen.edu`) | `student123` | Has 1-click auto-fill button on login |
| **Admin** | `admin` (or `admin@canteen.edu`) | `admin123` | Has 1-click auto-fill button on admin login |

---

## 🧪 Verified Test Scenarios

The automated test suite (`DataStructuresAndOrderTests.java`) verifies:
- ✅ **ArrayList Operations**: Dynamic insertion, retrieval, category filtering, keyword searching, low-stock extraction, and deletion.
- ✅ **FIFO Queue Processing**: Strictly preserves order sequence; dequeue polling processes orders in first-come, first-served order.
- ✅ **HashMap Fast Lookups**: Constant-time retrieval of student summaries and active order statuses.
- ✅ **Transactional Stock Reduction & Restoration**: Safe deduction upon order placement, and automatic return of inventory upon cancellation.
- ✅ **Billing Precision**: Subtotal calculation, 5% GST computation, and final decimal-safe payable amount.
- ✅ **Cancellation Window**: 5-minute countdown and restriction against cancelling orders already in `PREPARING` state.
- ✅ **Security**: BCrypt password verification, session protection, and unauthorized order access rejection.
