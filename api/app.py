from fastapi import FastAPI, Response, status
import models

app = FastAPI(root_path="/v1")

@app.get("/invoices")
def invoices():
    ...

@app.get("/invoices/{id}")
def invoices_id():
    ...

@app.post("/invoices/confirm")
def invoices_confirm():
    ...

@app.post("/invoices/return")
def invoices_return():
    ...

@app.get("/authorizations")
def authorizations():
    ...

@app.get("/authorizations/{id}")
def authorizations_id():
    ...

@app.post("/authorizations/{id}/accept")
def authorizations_id_accept():
    ...

@app.post("/authorizations/{id}/reject")
def authorizations_id_reject():
    ...

@app.websocket("/notifications")
def notifications():
    ...

@app.post("/login")
def post_login(login: models.Login, response: Response):
    try:
        # El token de acceso y su fecha de expiracion
        return login.login()
    except Exception as e:
        response.status_code = status.HTTP_403_FORBIDDEN

        return {
            "error": str(e)
        }