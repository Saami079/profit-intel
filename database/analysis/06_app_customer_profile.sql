CREATE OR REPLACE VIEW vw_app_customer_profile AS
SELECT
    cp.customer_id,
    cp.customer_name,
    cp.segment_name,
    cp.region,
    cp.acquisition_channel,

    cp.total_orders,
    cp.total_revenue,
    cp.total_cost,
    cp.total_profit,
    cp.profit_margin_pct,
    cp.avg_discount_pct,

    dd.discount_order_share_pct,
    dd.full_price_orders,
    dd.discounted_orders,
    dd.dependency_type,

    ra.customer_lifespan_days,
    ra.days_since_last_purchase,
    ra.retention_status,
    ra.retention_behavior,

    CASE
        WHEN cp.total_profit >= 5000
             AND cp.avg_discount_pct < 15
             AND ra.retention_status IN ('Highly Retained', 'Retained')
            THEN 'High Value Sustainable Customer'

        WHEN cp.total_profit >= 5000
             AND cp.avg_discount_pct >= 20
            THEN 'High Value Discount Sensitive Customer'

        WHEN cp.total_profit < 0
            THEN 'Loss Making Customer'

        WHEN dd.discount_order_share_pct >= 80
            THEN 'Discount Dependent Customer'

        WHEN ra.retention_status IN ('At Risk', 'Churned')
            THEN 'Retention Risk Customer'

        ELSE 'Standard Customer'
    END AS customer_value_type

FROM vw_customer_profitability cp
JOIN vw_discount_dependency dd
    ON cp.customer_id = dd.customer_id
JOIN vw_retention_analysis ra
    ON cp.customer_id = ra.customer_id;