import os
import psycopg2
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")

if not DATABASE_URL:
    raise ValueError("DATABASE_URL not found in .env")


files = [
    ("dim_customers", "data/generated/dim_customers.csv"),
    ("dim_products", "data/generated/dim_products.csv"),
    ("dim_dates", "data/generated/dim_dates.csv"),
    ("fact_orders", "data/generated/fact_orders.csv"),
    ("fact_order_items", "data/generated/fact_order_items.csv"),
]


def load_csv(cursor, table_name, file_path):
    with open(file_path, "r", encoding="utf-8") as file:
        cursor.copy_expert(
            f"COPY {table_name} FROM STDIN WITH CSV HEADER DELIMITER ','",
            file
        )
    print(f"Loaded {table_name}")


def main():
    connection = psycopg2.connect(DATABASE_URL)
    cursor = connection.cursor()

    for table_name, file_path in files:
        load_csv(cursor, table_name, file_path)

    connection.commit()
    cursor.close()
    connection.close()

    print("Render database loaded successfully.")


if __name__ == "__main__":
    main()