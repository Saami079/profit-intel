CREATE OR REPLACE VIEW vw_discount_band_performance AS
SELECT
    CASE
        WHEN o.discount_pct = 0 THEN '0% No Discount'
        WHEN o.discount_pct BETWEEN 1 AND 10 THEN '1-10% Low Discount'
        WHEN o.discount_pct BETWEEN 11 AND 20 THEN '11-20% Moderate Discount'
        WHEN o.discount_pct BETWEEN 21 AND 30 THEN '21-30% High Discount'
        ELSE '31%+ Extreme Discount'
    END AS discount_band,

    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.customer_id) AS total_customers,

    ROUND(SUM(oi.revenue), 2) AS total_revenue,
    ROUND(SUM(oi.profit), 2) AS total_profit,

    ROUND(
        SUM(oi.profit) / NULLIF(SUM(oi.revenue), 0) * 100,
        2
    ) AS profit_margin_pct,

    ROUND(AVG(o.discount_pct), 2) AS avg_discount_pct,

    CASE
        WHEN SUM(oi.profit) / NULLIF(SUM(oi.revenue), 0) * 100 >= 25
            THEN 'Healthy Discount Band'

        WHEN SUM(oi.profit) / NULLIF(SUM(oi.revenue), 0) * 100 BETWEEN 15 AND 24.99
            THEN 'Acceptable Discount Band'

        WHEN SUM(oi.profit) / NULLIF(SUM(oi.revenue), 0) * 100 BETWEEN 5 AND 14.99
            THEN 'Margin Warning Band'

        ELSE 'Margin Destructive Band'
    END AS band_status

FROM fact_orders o
JOIN fact_order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY
    CASE
        WHEN o.discount_pct = 0 THEN '0% No Discount'
        WHEN o.discount_pct BETWEEN 1 AND 10 THEN '1-10% Low Discount'
        WHEN o.discount_pct BETWEEN 11 AND 20 THEN '11-20% Moderate Discount'
        WHEN o.discount_pct BETWEEN 21 AND 30 THEN '21-30% High Discount'
        ELSE '31%+ Extreme Discount'
    END;