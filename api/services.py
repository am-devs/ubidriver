import requests
from psycopg_pool import ConnectionPool
from os import getenv
from templates import get_record_id_from_response

CONNECTION = "dbname={} user={} password={} host={} port={}".format(
    getenv("DB_NAME"),
    getenv("DB_USER"),
    getenv("DB_PASS"),
    getenv("DB_HOST"),
    getenv("DB_PORT"),
)

pool = ConnectionPool(CONNECTION, open=True)

class Database:
    "Facade hecho para facilitar la conexion a la base de datos"

    def __init__(self):
        self._connection = pool.getconn()

    def __enter__(self):
        self._cursor = self._connection.cursor()

        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        if exc_type is not None:
            info = (exc_type, exc_val, exc_tb)
            print("Exception occurred: ", info)
            self._connection.rollback()
        else:
            self._connection.commit()

        self._close_connection()

        return False
    
    def execute(self, query: str, *args):
        print("Executing a query: ", query, *args)

        return self._cursor.execute(query, tuple(args))

    def fetchone(self):
        return self._cursor.fetchone()
    
    def fetchall(self):
        return self._cursor.fetchall()
    
    def _close_connection(self):
        self._cursor.close()
        self._cursor = None
        pool.putconn(self._connection)

URL = getenv("AD_URL")

def sent_record_and_get_id(data: str):
    response = requests.post(URL, headers={"Content-Type": "application/xml; charset=utf-8"}, data=data)

    response.raise_for_status()

    record = 0

    if response.status_code == 200:
        record = get_record_id_from_response(response.content)

    return record