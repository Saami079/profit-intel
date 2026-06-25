CREATE OR REPLACE VIEW vw_app_dashboard_summary AS
SELECT
    COUNT(DISTINCT customer_id) AS total_customers,

    ROUND(SUM(total_revenue), 2) AS total_revenue,
    ROUND(SUM(total_profit), 2) AS total_profit,

    ROUND(
        SUM(total_profit) / NULLIF(SUM(total_revenue), 0) * 100,
        2
    ) AS overall_margin_pct,

    ROUND(AVG(avg_discount_pct), 2) AS avg_discount_pct,

    COUNT(CASE WHEN customer_value_type = 'High Value Sustainable Customer' THEN 1 END) AS sustainable_customers,
    COUNT(CASE WHEN customer_value_type = 'Discount Dependent Customer' THEN 1 END) AS discount_dependent_customers,
    COUNT(CASE WHEN customer_value_type = 'Loss Making Customer' THEN 1 END) AS loss_making_customers,
    COUNT(CASE WHEN customer_value_type = 'Retention Risk Customer' THEN 1 END) AS retention_risk_customers

FROM vw_app_customer_profile;