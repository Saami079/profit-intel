import os
import psycopg2
from psycopg2.pool import SimpleConnectionPool
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")

pool = None


def init_pool():
    global pool

    if pool is None:
        if DATABASE_URL:
            pool = SimpleConnectionPool(
                minconn=1,
                maxconn=8,
                dsn=DATABASE_URL
            )
        else:
            pool = SimpleConnectionPool(
                minconn=1,
                maxconn=8,
                host=os.getenv("DB_HOST", "localhost"),
                database=os.getenv("DB_NAME", "customer_profitability_discount_db"),
                user=os.getenv("DB_USER", "postgres"),
                password=os.getenv("DB_PASSWORD"),
                port=os.getenv("DB_PORT", "5432")
            )


def get_db_connection():
    init_pool()
    return pool.getconn()


def release_db_connection(connection):
    if pool and connection:
        pool.putconn(connection)


def fetch_all(query, params=None):
    connection = get_db_connection()
    cursor = connection.cursor()

    try:
        cursor.execute(query, params)
        columns = [desc[0] for desc in cursor.description]
        rows = cursor.fetchall()
        return [dict(zip(columns, row)) for row in rows]
    finally:
        cursor.close()
        release_db_connection(connection)


def fetch_one(query, params=None):
    connection = get_db_connection()
    cursor = connection.cursor()

    try:
        cursor.execute(query, params)
        columns = [desc[0] for desc in cursor.description]
        row = cursor.fetchone()

        if row:
            return dict(zip(columns, row))

        return None
    finally:
        cursor.close()
        release_db_connection(connection)