CREATE OR REPLACE VIEW vw_customer_profitability AS
SELECT
    c.customer_id,
    c.customer_name,
    s.segment_name,
    c.region,
    c.acquisition_channel,

    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity) AS total_units,
    ROUND(SUM(oi.revenue), 2) AS total_revenue,
    ROUND(SUM(oi.cost), 2) AS total_cost,
    ROUND(SUM(oi.profit), 2) AS total_profit,

    ROUND(
        SUM(oi.profit) / NULLIF(SUM(oi.revenue), 0) * 100,
        2
    ) AS profit_margin_pct,

    ROUND(AVG(o.discount_pct), 2) AS avg_discount_pct,

    MIN(d.date) AS first_purchase_date,
    MAX(d.date) AS last_purchase_date

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
    c.acquisition_channel;