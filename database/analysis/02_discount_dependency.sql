CREATE OR REPLACE VIEW vw_discount_dependency AS
SELECT
    c.customer_id,
    c.customer_name,
    s.segment_name,
    c.region,

    COUNT(DISTINCT o.order_id) AS total_orders,

    COUNT(DISTINCT CASE 
        WHEN o.discount_pct = 0 THEN o.order_id 
    END) AS full_price_orders,

    COUNT(DISTINCT CASE 
        WHEN o.discount_pct > 0 THEN o.order_id 
    END) AS discounted_orders,

    ROUND(AVG(o.discount_pct), 2) AS avg_discount_pct,

    ROUND(
        COUNT(DISTINCT CASE WHEN o.discount_pct > 0 THEN o.order_id END)::NUMERIC
        / NULLIF(COUNT(DISTINCT o.order_id), 0) * 100,
        2
    ) AS discount_order_share_pct,

    ROUND(SUM(oi.revenue), 2) AS total_revenue,
    ROUND(SUM(oi.profit), 2) AS total_profit,

    ROUND(
        SUM(oi.profit) / NULLIF(SUM(oi.revenue), 0) * 100,
        2
    ) AS profit_margin_pct,

    CASE
        WHEN COUNT(DISTINCT CASE WHEN o.discount_pct = 0 THEN o.order_id END) = 0
             AND COUNT(DISTINCT o.order_id) >= 3
            THEN 'Pure Discount Buyer'

        WHEN ROUND(AVG(o.discount_pct), 2) >= 25
             AND COUNT(DISTINCT o.order_id) >= 3
            THEN 'High Discount Dependency'

        WHEN ROUND(AVG(o.discount_pct), 2) BETWEEN 10 AND 24.99
            THEN 'Moderate Discount Dependency'

        WHEN ROUND(AVG(o.discount_pct), 2) < 10
            THEN 'Low Discount Dependency'

        ELSE 'Insufficient History'
    END AS dependency_type

FROM dim_customers c
JOIN dim_segments s
    ON c.segment_id = s.segment_id
JOIN fact_orders o
    ON c.customer_id = o.customer_id
JOIN fact_order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY
    c.customer_id,
    c.customer_name,
    s.segment_name,
    c.region;