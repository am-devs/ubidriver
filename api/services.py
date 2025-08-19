import requests
from psycopg_pool import ConnectionPool
from os import getenv

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

ODOO_DATA = {
    "url": getenv("ODOO_URL"),
    "db": getenv("ODOO_DB"),
    "user": getenv("ODOO_USER"),
    "pass": getenv("ODOO_PASS"),
}

class OdooConnection:
    def __init__(self):
        self._uid = self._login_odoo()

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        if exc_type is not None:
            info = (exc_type, exc_val, exc_tb)
            print("Exception occurred: ", info)

    def _login_odoo(self):
        response = requests.post(ODOO_DATA("url"), json={
            "jsonrpc": "2.0",
            "id": 0,
            "method": "call",
            "params": {
                "service": "common",
                "method": "login",
                "args": [ODOO_DATA("db"), ODOO_DATA("user"), ODOO_DATA("pass")]
            }
        })

        result = response.json()

        return result["result"]