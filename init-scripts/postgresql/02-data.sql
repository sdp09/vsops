-- Insert mock data for PostgreSQL
INSERT INTO users (name, email, department, salary) VALUES
('John Doe', 'john.doe@company.com', 'Engineering', 75000.00),
('Jane Smith', 'jane.smith@company.com', 'Marketing', 65000.00),
('Mike Johnson', 'mike.johnson@company.com', 'Engineering', 80000.00),
('Sarah Wilson', 'sarah.wilson@company.com', 'Sales', 70000.00),
('David Brown', 'david.brown@company.com', 'HR', 60000.00),
('Lisa Davis', 'lisa.davis@company.com', 'Engineering', 85000.00),
('Robert Miller', 'robert.miller@company.com', 'Finance', 68000.00),
('Emily Garcia', 'emily.garcia@company.com', 'Marketing', 62000.00),
('James Martinez', 'james.martinez@company.com', 'Engineering', 78000.00),
('Jessica Lee', 'jessica.lee@company.com', 'Sales', 72000.00),
('Michael Taylor', 'michael.taylor@company.com', 'Operations', 66000.00),
('Amanda White', 'amanda.white@company.com', 'Engineering', 82000.00),
('Christopher Anderson', 'chris.anderson@company.com', 'Marketing', 64000.00),
('Ashley Thompson', 'ashley.thompson@company.com', 'Finance', 69000.00),
('Daniel Harris', 'daniel.harris@company.com', 'Engineering', 79000.00);

-- Insert orders data
INSERT INTO orders (user_id, total_amount, status, order_date) VALUES
(1, 299.99, 'completed', '2024-01-15 10:30:00'),
(2, 149.50, 'completed', '2024-01-16 14:22:00'),
(3, 599.99, 'pending', '2024-01-17 09:15:00'),
(4, 89.99, 'completed', '2024-01-18 16:45:00'),
(5, 199.99, 'cancelled', '2024-01-19 11:30:00'),
(6, 449.50, 'completed', '2024-01-20 13:20:00'),
(7, 329.99, 'processing', '2024-01-21 10:10:00'),
(8, 79.99, 'completed', '2024-01-22 15:35:00'),
(9, 999.99, 'completed', '2024-01-23 12:45:00'),
(10, 159.99, 'pending', '2024-01-24 09:50:00'),
(1, 249.99, 'completed', '2024-01-25 14:15:00'),
(3, 399.50, 'processing', '2024-01-26 11:20:00'),
(5, 129.99, 'completed', '2024-01-27 16:30:00'),
(7, 599.99, 'pending', '2024-01-28 10:40:00'),
(9, 179.99, 'completed', '2024-01-29 13:55:00');