CREATE OR REPLACE VIEW vw_customer_recommendations AS
SELECT
    customer_id,
    customer_name,
    segment_name,
    region,
    total_profit,
    profit_margin_pct,
    avg_discount_pct,
    discount_order_share_pct,
    retention_status,
    dependency_type,
    customer_value_type,

    CASE
        WHEN total_profit >= 5000
             AND avg_discount_pct >= 25
             AND discount_order_share_pct >= 70
            THEN 'Reduce Discount Gradually'

        WHEN retention_status IN ('At Risk', 'Churned')
             AND avg_discount_pct >= 20
            THEN 'Replace Discount With Loyalty Offer'

        WHEN total_profit < 0
            THEN 'Stop Margin Leakage'

        WHEN total_profit >= 5000
             AND avg_discount_pct < 15
             AND retention_status IN ('Highly Retained', 'Retained')
            THEN 'Protect High Value Customer'

        WHEN dependency_type = 'Pure Discount Buyer'
            THEN 'Do Not Increase Discount'

        ELSE 'Monitor Customer'
    END AS recommended_action,

    CASE
        WHEN total_profit >= 5000
             AND avg_discount_pct >= 25
             AND discount_order_share_pct >= 70
            THEN 'Customer is profitable but heavily trained to buy only under discounts. Reduce discount slowly and test loyalty-based retention.'

        WHEN retention_status IN ('At Risk', 'Churned')
             AND avg_discount_pct >= 20
            THEN 'Customer shows retention weakness after discount dependency. Use loyalty benefits instead of deeper promotions.'

        WHEN total_profit < 0
            THEN 'Customer creates negative margin. Restrict discount exposure and review product mix.'

        WHEN total_profit >= 5000
             AND avg_discount_pct < 15
             AND retention_status IN ('Highly Retained', 'Retained')
            THEN 'Customer generates strong profit without heavy discounting. Prioritize retention and premium upsell.'

        WHEN dependency_type = 'Pure Discount Buyer'
            THEN 'Customer only responds to discounts. Avoid deeper promotion because loyalty quality is weak.'

        ELSE 'No immediate action required. Continue monitoring margin and retention behavior.'
    END AS recommendation_reason

FROM vw_app_customer_profile;