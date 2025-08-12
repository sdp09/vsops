-- Insert mock data for Redshift simulation
INSERT INTO users (id, name, email, department, salary) VALUES
(1, 'Alice Johnson', 'alice.johnson@datacompany.com', 'Analytics', 85000.00),
(2, 'Bob Smith', 'bob.smith@datacompany.com', 'Data Engineering', 90000.00),
(3, 'Carol Davis', 'carol.davis@datacompany.com', 'Business Intelligence', 78000.00),
(4, 'David Wilson', 'david.wilson@datacompany.com', 'Data Science', 95000.00),
(5, 'Emma Brown', 'emma.brown@datacompany.com', 'Analytics', 82000.00),
(6, 'Frank Miller', 'frank.miller@datacompany.com', 'Data Engineering', 88000.00),
(7, 'Grace Lee', 'grace.lee@datacompany.com', 'Business Intelligence', 76000.00),
(8, 'Henry Garcia', 'henry.garcia@datacompany.com', 'Data Science', 92000.00),
(9, 'Iris Martinez', 'iris.martinez@datacompany.com', 'Analytics', 80000.00),
(10, 'Jack Taylor', 'jack.taylor@datacompany.com', 'Data Engineering', 87000.00);

-- Insert product dimension data
INSERT INTO product_dim (product_name, category, subcategory, brand, price) VALUES
('Laptop Pro 15', 'Electronics', 'Computers', 'TechBrand', 1299.99),
('Wireless Mouse', 'Electronics', 'Accessories', 'TechBrand', 29.99),
('Office Chair', 'Furniture', 'Seating', 'ComfortCorp', 299.99),
('Standing Desk', 'Furniture', 'Desks', 'ComfortCorp', 599.99),
('Monitor 27inch', 'Electronics', 'Displays', 'ViewTech', 399.99),
('Keyboard Mechanical', 'Electronics', 'Accessories', 'TechBrand', 129.99),
('Desk Lamp LED', 'Furniture', 'Lighting', 'BrightLight', 79.99),
('Notebook Set', 'Office Supplies', 'Stationery', 'PaperCorp', 19.99),
('Webcam HD', 'Electronics', 'Accessories', 'ViewTech', 89.99),
('Coffee Mug', 'Kitchen', 'Drinkware', 'CupCo', 14.99);

-- Insert user analytics data
INSERT INTO user_analytics (user_id, page_views, session_duration, last_login, total_purchases) VALUES
(1, 156, 45, '2024-01-30 09:15:00', 2599.97),
(2, 89, 32, '2024-01-30 10:30:00', 1899.98),
(3, 234, 67, '2024-01-30 08:45:00', 3299.95),
(4, 178, 52, '2024-01-30 11:20:00', 2799.96),
(5, 201, 58, '2024-01-30 09:35:00', 1999.99),
(6, 145, 41, '2024-01-30 10:15:00', 2499.98),
(7, 167, 48, '2024-01-30 08:30:00', 1699.97),
(8, 289, 73, '2024-01-30 11:45:00', 3599.94),
(9, 198, 55, '2024-01-30 09:50:00', 2299.99),
(10, 134, 38, '2024-01-30 10:45:00', 1899.96);

-- Insert sales fact data
INSERT INTO sales_fact (user_id, product_id, sale_date, quantity, unit_price, total_amount, region) VALUES
(1, 1, '2024-01-15', 2, 1299.99, 2599.98, 'North America'),
(2, 3, '2024-01-16', 1, 299.99, 299.99, 'Europe'),
(3, 4, '2024-01-17', 1, 599.99, 599.99, 'North America'),
(4, 5, '2024-01-18', 3, 399.99, 1199.97, 'Asia Pacific'),
(5, 2, '2024-01-19', 5, 29.99, 149.95, 'Europe'),
(6, 6, '2024-01-20', 2, 129.99, 259.98, 'North America'),
(7, 7, '2024-01-21', 3, 79.99, 239.97, 'Asia Pacific'),
(8, 8, '2024-01-22', 10, 19.99, 199.90, 'Europe'),
(9, 9, '2024-01-23', 1, 89.99, 89.99, 'North America'),
(10, 10, '2024-01-24', 20, 14.99, 299.80, 'Asia Pacific'),
(1, 2, '2024-01-25', 1, 29.99, 29.99, 'North America'),
(3, 6, '2024-01-26', 1, 129.99, 129.99, 'North America'),
(5, 5, '2024-01-27', 2, 399.99, 799.98, 'Europe'),
(7, 1, '2024-01-28', 1, 1299.99, 1299.99, 'Asia Pacific'),
(9, 4, '2024-01-29', 1, 599.99, 599.99, 'North America');