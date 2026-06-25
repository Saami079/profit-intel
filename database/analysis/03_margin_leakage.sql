CREATE OR REPLACE VIEW vw_margin_leakage AS
SELECT
    p.product_id,
    p.product_name,
    p.category,

    COUNT(DISTINCT oi.order_id) AS total_orders,
    SUM(oi.quantity) AS total_units_sold,

    ROUND(SUM(oi.revenue), 2) AS total_revenue,
    ROUND(SUM(oi.cost), 2) AS total_cost,
    ROUND(SUM(oi.profit), 2) AS total_profit,

    ROUND(AVG(oi.discount_pct), 2) AS avg_discount_pct,

    ROUND(
        SUM(oi.profit) / NULLIF(SUM(oi.revenue), 0) * 100,
        2
    ) AS profit_margin_pct,

    CASE
        WHEN SUM(oi.revenue) >= 50000
             AND SUM(oi.profit) <= 0
            THEN 'Critical Margin Leakage'

        WHEN SUM(oi.revenue) >= 50000
             AND SUM(oi.profit) / NULLIF(SUM(oi.revenue), 0) * 100 < 10
            THEN 'High Revenue Low Margin'

        WHEN AVG(oi.discount_pct) >= 30
             AND SUM(oi.profit) / NULLIF(SUM(oi.revenue), 0) * 100 < 15
            THEN 'Over Discounted Product'

        WHEN SUM(oi.profit) / NULLIF(SUM(oi.revenue), 0) * 100 >= 25
            THEN 'Healthy Margin Product'

        ELSE 'Monitor'
    END AS leakage_status

FROM dim_products p
JOIN fact_order_items oi
    ON p.product_id = oi.product_id
JOIN fact_orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY
    p.product_id,
    p.product_name,
    p.category;