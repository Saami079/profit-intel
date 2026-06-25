COPY dim_segments
FROM 'D:\Data Analysis\Project - Customer Profitability Discount Intelligence/data/generated/dim_segments.csv'
DELIMITER ','
CSV HEADER;

COPY dim_customers
FROM 'D:\Data Analysis\Project - Customer Profitability Discount Intelligence/data/generated/dim_customers.csv'
DELIMITER ','
CSV HEADER;

COPY dim_products
FROM 'D:\Data Analysis\Project - Customer Profitability Discount Intelligence/data/generated/dim_products.csv'
DELIMITER ','
CSV HEADER;

COPY dim_dates
FROM 'D:\Data Analysis\Project - Customer Profitability Discount Intelligence/data/generated/dim_dates.csv'
DELIMITER ','
CSV HEADER;

COPY fact_orders
FROM 'D:\Data Analysis\Project - Customer Profitability Discount Intelligence/data/generated/fact_orders.csv'
DELIMITER ','
CSV HEADER;

COPY fact_order_items
FROM 'D:\Data Analysis\Project - Customer Profitability Discount Intelligence/data/generated/fact_order_items.csv'
DELIMITER ','
CSV HEADER;