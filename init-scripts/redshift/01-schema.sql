-- Mock Redshift Schema (using PostgreSQL)
-- Note: This simulates Redshift structure using PostgreSQL

-- Create users table (Redshift-like structure)
CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    department VARCHAR(50),
    salary DECIMAL(10,2)
);

-- Create analytics table (typical data warehouse structure)
CREATE TABLE user_analytics (
    id SERIAL PRIMARY KEY,
    user_id INTEGER,
    page_views INTEGER DEFAULT 0,
    session_duration INTEGER DEFAULT 0, -- in minutes
    last_login TIMESTAMP,
    total_purchases DECIMAL(12,2) DEFAULT 0.00,
    created_date DATE DEFAULT CURRENT_DATE
);

-- Create sales fact table (typical data warehouse pattern)
CREATE TABLE sales_fact (
    id SERIAL PRIMARY KEY,
    user_id INTEGER,
    product_id INTEGER,
    sale_date DATE,
    quantity INTEGER,
    unit_price DECIMAL(8,2),
    total_amount DECIMAL(10,2),
    region VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create dimension table for products
CREATE TABLE product_dim (
    id SERIAL PRIMARY KEY,
    product_name VARCHAR(200),
    category VARCHAR(100),
    subcategory VARCHAR(100),
    brand VARCHAR(100),
    price DECIMAL(8,2)
);

-- Create indexes (Redshift would use sort/dist keys, but we'll use indexes)
CREATE INDEX idx_users_department ON users(department);
CREATE INDEX idx_user_analytics_user_id ON user_analytics(user_id);
CREATE INDEX idx_sales_fact_user_id ON sales_fact(user_id);
CREATE INDEX idx_sales_fact_date ON sales_fact(sale_date);
CREATE INDEX idx_sales_fact_region ON sales_fact(region);