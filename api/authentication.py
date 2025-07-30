from os import getenv
import requests

auth_api = getenv("AUTH_API")

def login(data: dict):
    req = requests.post(auth_api + "/v1/login", json=data)
    body = req.json()

    if not req.ok:
        raise Exception(body["error"])
    else:
        return body
    
def get_user(token):
    req = requests.get(auth_api + "/v1/users", headers={"Authorization": f"Bearer {token}"})
    body = req.json()

    if not req.ok:
        raise Exception("Token inválido")
    else:
        return body