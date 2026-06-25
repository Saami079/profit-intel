import psycopg2
from config import Config


def get_db_connection():
    connection = psycopg2.connect(
        host=Config.DB_HOST,
        database=Config.DB_NAME,
        user=Config.DB_USER,
        password=Config.DB_PASSWORD,
        port=Config.DB_PORT
    )
    return connection


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