from datetime import datetime, timedelta, timezone
from os import getenv
import os
import jwt
import pytz

SECRET_KEY = getenv("SECRET_KEY")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60

# Muy importante
tz = pytz.timezone(os.environ["TZ"])

def create_access_token(data: dict):
    "Retorna el token de acceso y el tiempo de vida del token en segundos"

    expiration =  ACCESS_TOKEN_EXPIRE_MINUTES * 60
    now = datetime.now(tz=timezone.utc)

    if not data.get("exp"):
        # JWT trabaja con UTC y la fecha llega con la zona horaria del cliente
        data["exp"] = now + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    else:
        if data["exp"] <= now:
            raise Exception("La fecha de expiracion debe ser mayor a la fecha actual")

        expiration = int((data["exp"] - now).total_seconds())

    encoded_jwt = jwt.encode(data, SECRET_KEY, algorithm=ALGORITHM)

    return {
        # 1 hour
        "expiration": expiration,
        "token": encoded_jwt
    }

def decode_token(token: str):
    return jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])