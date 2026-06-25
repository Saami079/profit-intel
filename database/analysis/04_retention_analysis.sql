CREATE OR REPLACE VIEW vw_retention_analysis AS
SELECT
    c.customer_id,
    c.customer_name,
    s.segment_name,
    c.region,
    c.signup_date,

    COUNT(DISTINCT o.order_id) AS total_orders,

    MIN(d.date) AS first_purchase_date,
    MAX(d.date) AS last_purchase_date,

    MAX(d.date) - MIN(d.date) AS customer_lifespan_days,

    DATE '2025-12-31' - MAX(d.date) AS days_since_last_purchase,

    ROUND(SUM(oi.revenue), 2) AS lifetime_revenue,
    ROUND(SUM(oi.profit), 2) AS lifetime_profit,

    ROUND(AVG(o.discount_pct), 2) AS avg_discount_pct,

    CASE
        WHEN COUNT(DISTINCT o.order_id) >= 10
             AND DATE '2025-12-31' - MAX(d.date) <= 90
            THEN 'Highly Retained'

        WHEN COUNT(DISTINCT o.order_id) >= 5
             AND DATE '2025-12-31' - MAX(d.date) <= 180
            THEN 'Retained'

        WHEN DATE '2025-12-31' - MAX(d.date) BETWEEN 181 AND 365
            THEN 'At Risk'

        WHEN DATE '2025-12-31' - MAX(d.date) > 365
            THEN 'Churned'

        ELSE 'New / Low History'
    END AS retention_status,

    CASE
        WHEN AVG(o.discount_pct) >= 25
             AND DATE '2025-12-31' - MAX(d.date) > 180
            THEN 'Churn Risk After Discount Dependence'

        WHEN AVG(o.discount_pct) < 10
             AND COUNT(DISTINCT o.order_id) >= 5
            THEN 'Organic Loyal Customer'

        WHEN AVG(o.discount_pct) >= 20
             AND COUNT(DISTINCT o.order_id) >= 5
            THEN 'Discount Retained Customer'

        ELSE 'Neutral Pattern'
    END AS retention_behavior

FROM dim_customers c
JOIN dim_segments s
    ON c.segment_id = s.segment_id
JOIN fact_orders o
    ON c.customer_id = o.customer_id
JOIN fact_order_items oi
    ON o.order_id = oi.order_id
JOIN dim_dates d
    ON o.date_id = d.date_id
WHERE o.order_status = 'Completed'
GROUP BY
    c.customer_id,
    c.customer_name,
    s.segment_name,
    c.region,
    c.signup_date;