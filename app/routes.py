from flask import Blueprint, render_template
from app.db import fetch_all, fetch_one

main = Blueprint("main", __name__)


@main.route("/")
def dashboard():
    summary = fetch_one("""
        SELECT *
        FROM vw_app_dashboard_summary;
    """)

    discount_bands = fetch_all("""
        SELECT *
        FROM vw_discount_band_performance
        ORDER BY avg_discount_pct;
    """)

    segments = fetch_all("""
        SELECT *
        FROM vw_segment_intelligence
        ORDER BY total_profit DESC;
    """)

    alerts = fetch_one("""
        SELECT
            COUNT(CASE 
                WHEN avg_discount_pct >= 25 AND total_profit >= 5000 
                THEN 1 
            END) AS high_value_discount_risk,

            COUNT(CASE 
                WHEN customer_value_type = 'Retention Risk Customer' 
                THEN 1 
            END) AS retention_risk_customers,

            COUNT(CASE 
                WHEN customer_value_type = 'Discount Dependent Customer' 
                THEN 1 
            END) AS discount_dependent_customers,

            COUNT(CASE 
                WHEN customer_value_type = 'Loss Making Customer' 
                THEN 1 
            END) AS loss_making_customers

        FROM vw_app_customer_profile;
    """)

    return render_template(
        "dashboard.html",
        summary=summary,
        discount_bands=discount_bands,
        segments=segments,
        alerts=alerts
    )

@main.route("/customers")
def customer_search():
    customers = fetch_all("""
        SELECT
            customer_id,
            customer_name,
            segment_name,
            region,
            total_profit,
            profit_margin_pct,
            avg_discount_pct,
            retention_status,
            customer_value_type
        FROM vw_app_customer_profile
        ORDER BY total_profit DESC
        LIMIT 100;
    """)

    return render_template(
        "customer_search.html",
        customers=customers
    )


@main.route("/discount-dependency")
def discount_dependency():
    customers = fetch_all("""
        SELECT *
        FROM vw_discount_dependency
        ORDER BY discount_order_share_pct DESC, total_profit ASC
        LIMIT 100;
    """)

    return render_template(
        "discount_dependency.html",
        customers=customers
    )


@main.route("/margin-leakage")
def margin_leakage():
    products = fetch_all("""
        SELECT *
        FROM vw_margin_leakage
        ORDER BY total_revenue DESC, profit_margin_pct ASC
        LIMIT 100;
    """)

    return render_template(
        "margin_leakage.html",
        products=products
    )


@main.route("/retention")
def retention():
    customers = fetch_all("""
        SELECT *
        FROM vw_retention_analysis
        ORDER BY lifetime_profit DESC
        LIMIT 100;
    """)

    return render_template(
        "retention.html",
        customers=customers
    )


@main.route("/segments")
def segment_intelligence():
    segments = fetch_all("""
        SELECT *
        FROM vw_segment_intelligence
        ORDER BY total_profit DESC;
    """)

    return render_template(
        "segment_intelligence.html",
        segments=segments
    )


@main.route("/simulator")
def simulator():
    bands = fetch_all("""
        SELECT *
        FROM vw_discount_band_performance
        ORDER BY avg_discount_pct;
    """)

    return render_template(
        "simulator.html",
        bands=bands
    )

@main.route("/customers/search")
def search_customers():
    from flask import request

    search_term = request.args.get("q", "")

    customers = fetch_all("""
        SELECT
            customer_id,
            customer_name,
            segment_name,
            region,
            total_profit,
            profit_margin_pct,
            avg_discount_pct,
            retention_status,
            customer_value_type
        FROM vw_app_customer_profile
        WHERE LOWER(customer_name) LIKE LOWER(%s)
        ORDER BY total_profit DESC
        LIMIT 50;
    """, (f"%{search_term}%",))

    return render_template(
        "partials/customer_results.html",
        customers=customers
    )

@main.route("/simulator/run")
def run_simulator():
    from flask import request

    current_discount = float(request.args.get("current_discount", 20))
    new_discount = float(request.args.get("new_discount", 15))
    revenue = float(request.args.get("revenue", 1000000))
    cost_ratio = float(request.args.get("cost_ratio", 0.62))

    current_cost = revenue * cost_ratio
    current_profit = revenue - current_cost
    current_margin = (current_profit / revenue) * 100

    discount_change = new_discount - current_discount

    revenue_impact_pct = discount_change * 0.45
    projected_revenue = revenue * (1 + revenue_impact_pct / 100)

    projected_profit = projected_revenue - current_cost
    projected_margin = (projected_profit / projected_revenue) * 100

    profit_change_pct = ((projected_profit - current_profit) / current_profit) * 100

    if new_discount <= 10:
        retention_risk = "High"
        recommendation = "Reduce carefully. Add loyalty offer to prevent churn."
    elif new_discount <= 20:
        retention_risk = "Medium"
        recommendation = "Optimal zone. Profit improves without excessive retention damage."
    elif new_discount <= 30:
        retention_risk = "Low"
        recommendation = "Safe for retention, but monitor margin leakage."
    else:
        retention_risk = "Very Low"
        recommendation = "Too generous. Margin destruction risk is high."

    result = {
        "current_revenue": revenue,
        "current_profit": current_profit,
        "current_margin": current_margin,
        "projected_revenue": projected_revenue,
        "projected_profit": projected_profit,
        "projected_margin": projected_margin,
        "profit_change_pct": profit_change_pct,
        "retention_risk": retention_risk,
        "recommendation": recommendation
    }

    return render_template("partials/simulator_result.html", result=result)

@main.route("/recommendations")
def recommendations():
    customers = fetch_all("""
        SELECT *
        FROM vw_customer_recommendations
        ORDER BY total_profit DESC
        LIMIT 100;
    """)

    return render_template(
        "recommendations.html",
        customers=customers
    )

@main.route("/customer/<int:customer_id>")
def customer_detail(customer_id):
    customer = fetch_one("""
        SELECT *
        FROM vw_customer_recommendations
        WHERE customer_id = %s;
    """, (customer_id,))

    history = fetch_all("""
        SELECT
            d.date,
            o.discount_pct,
            SUM(oi.revenue) AS revenue,
            SUM(oi.profit) AS profit
        FROM fact_orders o
        JOIN fact_order_items oi
            ON o.order_id = oi.order_id
        JOIN dim_dates d
            ON o.date_id = d.date_id
        WHERE o.customer_id = %s
        GROUP BY d.date, o.discount_pct
        ORDER BY d.date DESC
        LIMIT 20;
    """, (customer_id,))

    return render_template(
        "customer_detail.html",
        customer=customer,
        history=history
    )

@main.route("/export/recommendations")
def export_recommendations():
    import csv
    from flask import Response

    customers = fetch_all("""
        SELECT *
        FROM vw_customer_recommendations
        ORDER BY total_profit DESC;
    """)

    def generate():
        data = []

        if customers:
            headers = customers[0].keys()
            data.append(",".join(headers))

            for row in customers:
                data.append(",".join([str(value) for value in row.values()]))

        return "\n".join(data)

    return Response(
        generate(),
        mimetype="text/csv",
        headers={
            "Content-Disposition": "attachment; filename=recommendations.csv"
        }
    )