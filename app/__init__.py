from flask import Flask


def format_currency(value):
    if value is None:
        return "$0"

    value = float(value)

    if abs(value) >= 1_000_000:
        return f"${value / 1_000_000:.2f}M"

    return f"${value:,.2f}"


def format_currency_full(value):
    if value is None:
        return "$0.00"

    return f"${float(value):,.2f}"


def format_number(value):
    if value is None:
        return "0"

    return f"{int(value):,}"


def format_percent(value):
    if value is None:
        return "0.00%"

    return f"{float(value):.2f}%"


def status_class(value):
    if value is None:
        return "badge-neutral"

    value = str(value).lower()

    positive_words = [
        "healthy",
        "highly retained",
        "retained",
        "sustainable",
        "organic loyal",
        "high value sustainable",
        "low discount"
    ]

    warning_words = [
        "at risk",
        "monitor",
        "moderate",
        "acceptable",
        "discount sensitive",
        "neutral",
        "insufficient"
    ]

    negative_words = [
        "pure discount",
        "margin drainer",
        "loss",
        "churn",
        "critical",
        "destructive",
        "over discounted",
        "high discount dependency"
    ]

    if any(word in value for word in positive_words):
        return "badge-positive"

    if any(word in value for word in negative_words):
        return "badge-negative"

    if any(word in value for word in warning_words):
        return "badge-warning"

    return "badge-neutral"


def create_app():
    app = Flask(__name__)

    app.jinja_env.filters["currency"] = format_currency
    app.jinja_env.filters["currency_full"] = format_currency_full
    app.jinja_env.filters["number"] = format_number
    app.jinja_env.filters["percent"] = format_percent
    app.jinja_env.filters["status_class"] = status_class

    from app.routes import main
    app.register_blueprint(main)

    return app