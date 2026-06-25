DROP TABLE IF EXISTS fact_order_items;
DROP TABLE IF EXISTS fact_orders;
DROP TABLE IF EXISTS dim_products;
DROP TABLE IF EXISTS dim_customers;
DROP TABLE IF EXISTS dim_dates;
DROP TABLE IF EXISTS dim_segments;

CREATE TABLE dim_segments (
    segment_id INT PRIMARY KEY,
    segment_name VARCHAR(100),
    segment_description TEXT
);

CREATE TABLE dim_customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    segment_id INT,
    region VARCHAR(50),
    signup_date DATE,
    acquisition_channel VARCHAR(100),
    FOREIGN KEY (segment_id) REFERENCES dim_segments(segment_id)
);

CREATE TABLE dim_products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(150),
    category VARCHAR(100),
    unit_cost NUMERIC(12,2),
    list_price NUMERIC(12,2)
);

CREATE TABLE dim_dates (
    date_id INT PRIMARY KEY,
    date DATE,
    year INT,
    month INT,
    month_name VARCHAR(20),
    quarter VARCHAR(10)
);

CREATE TABLE fact_orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    date_id INT,
    discount_pct NUMERIC(5,2),
    order_status VARCHAR(30),
    FOREIGN KEY (customer_id) REFERENCES dim_customers(customer_id),
    FOREIGN KEY (date_id) REFERENCES dim_dates(date_id)
);

CREATE TABLE fact_order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_cost NUMERIC(12,2),
    list_price NUMERIC(12,2),
    discount_pct NUMERIC(5,2),
    selling_price NUMERIC(12,2),
    revenue NUMERIC(12,2),
    cost NUMERIC(12,2),
    profit NUMERIC(12,2),
    FOREIGN KEY (order_id) REFERENCES fact_orders(order_id),
    FOREIGN KEY (product_id) REFERENCES dim_products(product_id)
);