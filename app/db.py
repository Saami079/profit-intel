import os
import psycopg2
from dotenv import load_dotenv

load_dotenv()


def get_db_connection():
    database_url = os.getenv("DATABASE_URL")

    if database_url:
        return psycopg2.connect(database_url)

    return psycopg2.connect(
        host=os.getenv("DB_HOST", "localhost"),
        database=os.getenv("DB_NAME", "customer_profitability_discount_db"),
        user=os.getenv("DB_USER", "postgres"),
        password=os.getenv("DB_PASSWORD"),
        port=os.getenv("DB_PORT", "5432")
    )


def fetch_all(query, params=None):
    connection = get_db_connection()
    cursor = connection.cursor()

    cursor.execute(query, params)
    columns = [desc[0] for desc in cursor.description]
    rows = cursor.fetchall()

    cursor.close()
    connection.close()

    return [dict(zip(columns, row)) for row in rows]


def fetch_one(query, params=None):
    connection = get_db_connection()
    cursor = connection.cursor()

    cursor.execute(query, params)
    columns = [desc[0] for desc in cursor.description]
    row = cursor.fetchone()

    cursor.close()
    connection.close()

    if row:
        return dict(zip(columns, row))

    return None