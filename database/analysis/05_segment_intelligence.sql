CREATE OR REPLACE VIEW vw_segment_intelligence AS
SELECT
    s.segment_id,
    s.segment_name,

    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(DISTINCT o.order_id) AS total_orders,

    ROUND(SUM(oi.revenue), 2) AS total_revenue,
    ROUND(SUM(oi.cost), 2) AS total_cost,
    ROUND(SUM(oi.profit), 2) AS total_profit,

    ROUND(
        SUM(oi.profit) / NULLIF(SUM(oi.revenue), 0) * 100,
        2
    ) AS profit_margin_pct,

    ROUND(AVG(o.discount_pct), 2) AS avg_discount_pct,

    ROUND(
        COUNT(DISTINCT o.order_id)::NUMERIC
        / NULLIF(COUNT(DISTINCT c.customer_id), 0),
        2
    ) AS avg_orders_per_customer,

    ROUND(
        SUM(oi.revenue)
        / NULLIF(COUNT(DISTINCT c.customer_id), 0),
        2
    ) AS revenue_per_customer,

    ROUND(
        SUM(oi.profit)
        / NULLIF(COUNT(DISTINCT c.customer_id), 0),
        2
    ) AS profit_per_customer,

    CASE
        WHEN SUM(oi.profit) / NULLIF(SUM(oi.revenue), 0) * 100 >= 25
             AND AVG(o.discount_pct) < 15
             AND COUNT(DISTINCT o.order_id)::NUMERIC / NULLIF(COUNT(DISTINCT c.customer_id), 0) >= 5
            THEN 'Sustainable Profit Segment'

        WHEN SUM(oi.profit) / NULLIF(SUM(oi.revenue), 0) * 100 >= 20
             AND AVG(o.discount_pct) >= 20
            THEN 'Profitable But Discount Sensitive'

        WHEN SUM(oi.revenue) >= 500000
             AND SUM(oi.profit) / NULLIF(SUM(oi.revenue), 0) * 100 < 15
            THEN 'Revenue Heavy Margin Weak'

        WHEN AVG(o.discount_pct) >= 25
             AND SUM(oi.profit) / NULLIF(SUM(oi.revenue), 0) * 100 < 15
            THEN 'Discount Dependent Segment'

        ELSE 'Monitor Segment'
    END AS segment_quality

FROM dim_segments s
JOIN dim_customers c
    ON s.segment_id = c.segment_id
JOIN fact_orders o
    ON c.customer_id = o.customer_id
JOIN fact_order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY
    s.segment_id,
    s.segment_name;