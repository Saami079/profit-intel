import os
import random
from datetime import datetime, timedelta

import pandas as pd


OUTPUT_DIR = "data/generated"
os.makedirs(OUTPUT_DIR, exist_ok=True)

random.seed(42)


CUSTOMER_COUNT = 1200
PRODUCT_COUNT = 150
ORDER_COUNT = 12000


segments = [
    (1, "Premium Loyalists", "High profit, low discount dependency"),
    (2, "Discount Hunters", "Buy heavily during discounts"),
    (3, "Seasonal Buyers", "Purchase during campaigns and holidays"),
    (4, "Margin Drainers", "High revenue but weak profit"),
    (5, "At Risk Customers", "Declining repeat purchase behavior"),
    (6, "New Customers", "Recently acquired customers"),
]


categories = [
    "Electronics",
    "Home & Kitchen",
    "Fashion",
    "Beauty",
    "Fitness",
    "Office Supplies",
    "Grocery",
    "Accessories",
]


regions = [
    "West",
    "North",
    "South",
    "East",
    "Central",
]


def generate_segments():
    df = pd.DataFrame(
        segments,
        columns=["segment_id", "segment_name", "segment_description"]
    )
    df.to_csv(f"{OUTPUT_DIR}/dim_segments.csv", index=False)


def generate_customers():
    customers = []

    for customer_id in range(1, CUSTOMER_COUNT + 1):
        segment = random.choices(
            segments,
            weights=[18, 24, 18, 12, 16, 12],
            k=1
        )[0]

        signup_date = datetime(2022, 1, 1) + timedelta(days=random.randint(0, 900))

        customers.append({
            "customer_id": customer_id,
            "customer_name": f"Customer_{customer_id:04d}",
            "segment_id": segment[0],
            "region": random.choice(regions),
            "signup_date": signup_date.date(),
            "acquisition_channel": random.choice(
                ["Organic", "Paid Ads", "Referral", "Marketplace", "Email Campaign"]
            )
        })

    df = pd.DataFrame(customers)
    df.to_csv(f"{OUTPUT_DIR}/dim_customers.csv", index=False)


def generate_products():
    products = []

    for product_id in range(1, PRODUCT_COUNT + 1):
        category = random.choice(categories)

        base_cost = round(random.uniform(80, 1200), 2)
        markup = random.uniform(1.25, 2.8)
        list_price = round(base_cost * markup, 2)

        products.append({
            "product_id": product_id,
            "product_name": f"{category}_Product_{product_id:03d}",
            "category": category,
            "unit_cost": base_cost,
            "list_price": list_price
        })

    df = pd.DataFrame(products)
    df.to_csv(f"{OUTPUT_DIR}/dim_products.csv", index=False)


def generate_dates():
    start_date = datetime(2022, 1, 1)
    end_date = datetime(2025, 12, 31)

    dates = []
    current_date = start_date
    date_id = 1

    while current_date <= end_date:
        dates.append({
            "date_id": date_id,
            "date": current_date.date(),
            "year": current_date.year,
            "month": current_date.month,
            "month_name": current_date.strftime("%B"),
            "quarter": f"Q{((current_date.month - 1) // 3) + 1}"
        })

        date_id += 1
        current_date += timedelta(days=1)

    df = pd.DataFrame(dates)
    df.to_csv(f"{OUTPUT_DIR}/dim_dates.csv", index=False)


def get_discount_by_segment(segment_id):
    if segment_id == 1:
        return random.choices([0, 5, 10, 15], weights=[45, 30, 20, 5], k=1)[0]
    if segment_id == 2:
        return random.choices([15, 20, 25, 30, 35, 40], weights=[10, 15, 25, 25, 15, 10], k=1)[0]
    if segment_id == 3:
        return random.choices([5, 10, 15, 20, 25], weights=[10, 20, 25, 25, 20], k=1)[0]
    if segment_id == 4:
        return random.choices([20, 25, 30, 35, 40, 45], weights=[10, 15, 20, 25, 20, 10], k=1)[0]
    if segment_id == 5:
        return random.choices([10, 15, 20, 25, 30], weights=[10, 20, 25, 25, 20], k=1)[0]

    return random.choices([0, 5, 10, 15, 20], weights=[20, 25, 25, 20, 10], k=1)[0]


def generate_orders_and_items():
    customers = pd.read_csv(f"{OUTPUT_DIR}/dim_customers.csv")
    products = pd.read_csv(f"{OUTPUT_DIR}/dim_products.csv")
    dates = pd.read_csv(f"{OUTPUT_DIR}/dim_dates.csv")

    orders = []
    order_items = []

    for order_id in range(1, ORDER_COUNT + 1):
        customer = customers.sample(1).iloc[0]
        order_date = dates.sample(1).iloc[0]

        discount_pct = get_discount_by_segment(customer["segment_id"])

        order_status = random.choices(
            ["Completed", "Returned", "Cancelled"],
            weights=[88, 8, 4],
            k=1
        )[0]

        item_count = random.randint(1, 5)

        orders.append({
            "order_id": order_id,
            "customer_id": int(customer["customer_id"]),
            "date_id": int(order_date["date_id"]),
            "discount_pct": discount_pct,
            "order_status": order_status
        })

        for item_no in range(1, item_count + 1):
            product = products.sample(1).iloc[0]
            quantity = random.randint(1, 4)

            unit_cost = float(product["unit_cost"])
            list_price = float(product["list_price"])

            discounted_price = round(list_price * (1 - discount_pct / 100), 2)

            revenue = round(discounted_price * quantity, 2)
            cost = round(unit_cost * quantity, 2)
            profit = round(revenue - cost, 2)

            order_items.append({
                "order_item_id": len(order_items) + 1,
                "order_id": order_id,
                "product_id": int(product["product_id"]),
                "quantity": quantity,
                "unit_cost": unit_cost,
                "list_price": list_price,
                "discount_pct": discount_pct,
                "selling_price": discounted_price,
                "revenue": revenue,
                "cost": cost,
                "profit": profit
            })

    pd.DataFrame(orders).to_csv(f"{OUTPUT_DIR}/fact_orders.csv", index=False)
    pd.DataFrame(order_items).to_csv(f"{OUTPUT_DIR}/fact_order_items.csv", index=False)


def main():
    generate_segments()
    generate_customers()
    generate_products()
    generate_dates()
    generate_orders_and_items()

    print("Synthetic dataset generated successfully.")
    print(f"Files saved in: {OUTPUT_DIR}")


if __name__ == "__main__":
    main()