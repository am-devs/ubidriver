from fastapi import WebSocket
import requests
from psycopg_pool import ConnectionPool
from os import getenv
import time

CONNECTION = "dbname={} user={} password={} host={} port={}".format(
    getenv("DB_NAME"),
    getenv("DB_USER"),
    getenv("DB_PASS"),
    getenv("DB_HOST"),
    getenv("DB_PORT"),
)

# Variable global para el pool
pool = None

def create_pool():
    """Crea un nuevo connection pool"""
    global pool
    if pool is not None:
        try:
            pool.close()
        except:
            pass  # Ignorar errores al cerrar el pool viejo
    
    pool = ConnectionPool(
        CONNECTION,
        open=True,
        check=ConnectionPool.check_connection,
        max_idle=300,
        num_workers=1, 
    )
    return pool

# Crear el pool inicial
create_pool()

class Database:
    "Facade hecho para facilitar la conexion a la base de datos"

    def __init__(self):
        self._connection = None
        self._get_connection()

    def _get_connection(self):
        """Obtiene una conexión, recreando el pool si es necesario"""
        global pool
        max_retries = 3
        retry_delay = 1  # segundos
        
        for attempt in range(max_retries):
            try:
                # Verificar si el pool existe y está saludable
                if pool is None or pool.closed:
                    print("Pool no existe o está cerrado, creando uno nuevo...")
                    create_pool()
                
                # Intentar obtener conexión
                self._connection = pool.getconn()
                
                # Verificar si la conexión es válida
                with self._connection.cursor() as cursor:
                    cursor.execute("SELECT 1")
                
                return  # Conexión exitosa
                
            except Exception as e:
                print(f"Error al obtener conexión (intento {attempt + 1}/{max_retries}): {e}")
                
                if attempt < max_retries - 1:
                    print(f"Reintentando en {retry_delay} segundos...")
                    time.sleep(retry_delay)
                    
                    # Recrear el pool para el próximo intento
                    print("Recreando connection pool...")
                    create_pool()
                else:
                    # Último intento falló
                    raise Exception(f"No se pudo establecer conexión después de {max_retries} intentos: {e}")

    def __enter__(self):
        if self._connection is None:
            self._get_connection()
        self._cursor = self._connection.cursor()
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        if exc_type is not None:
            info = (exc_type, exc_val, exc_tb)
            print("Exception occurred: ", info)
            if self._connection:
                self._connection.rollback()
        else:
            if self._connection:
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
        global pool
        
        if self._cursor:
            self._cursor.close()
            self._cursor = None
        
        if self._connection and pool:
            try:
                pool.putconn(self._connection)
            except Exception as e:
                print(f"Error al devolver conexión al pool: {e}")
                # Si hay error al devolver la conexión, recrear el pool
                print("Recreando connection pool debido a error...")
                create_pool()
        
        self._connection = None

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
        response = requests.post(ODOO_DATA["url"], json={
            "jsonrpc": "2.0",
            "id": 0,
            "method": "call",
            "params": {
                "service": "common",
                "method": "login",
                "args": [ODOO_DATA["db"], ODOO_DATA["user"], ODOO_DATA["pass"]]
            }
        })

        result = response.json()

        return result["result"]
    
    def search_ids(self, models: str, domain: list):
        response = requests.post(ODOO_DATA["url"], json={
            "jsonrpc": "2.0",
            "id": 0,
            "method": "call",
            "params": {
                "service": "object",
                "method": "execute",
                "args": [
                    ODOO_DATA["db"], self._uid, ODOO_DATA["pass"],
                    models, 
                    "search_read", domain, [], []
                ]
            }
        })

        response.raise_for_status()

        data = response.json()

        print(data)

        if "error" in data:
            return tuple()

        return tuple(r["id"] for r in data["result"])

    def execute(self, model: str, method: str, *arguments):
        response = requests.post(ODOO_DATA["url"], json={
            "jsonrpc": "2.0",
            "id": 0,
            "method": "call",
            "params": {
                "service": "object",
                "method": "execute",
                "args": [
                    ODOO_DATA["db"], self._uid, ODOO_DATA["pass"],
                    model, 
                    method,
                    *arguments
                ]
            }
        })

        response.raise_for_status()

        data = response.json()

        print(data)

        if "error" in data:
            return None

        return data["result"]
    
class SocketManager:
    "Pequeno broker hecho para manejar las conexiones por Websocket en la API"

    def __init__(self):
        self._active_connections: list[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self._active_connections.append(websocket)

    def disconnect(self, websocket: WebSocket):
        print(f"Disconnected from channel")

        self._active_connections.remove(websocket)

    async def broadcast(self, json: dict):
        for conn in self._active_connections:
            print("Sending JSON to subscriber")

            await conn.send_json(json)