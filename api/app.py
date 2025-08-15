from fastapi import Depends, FastAPI, Response, status
from fastapi.security import OAuth2PasswordBearer
from authentication import login, get_user_data
import models

app = FastAPI(root_path="/v1")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/v1/login")

@app.get("/")
def get_ping():
    print("Hello world")

    return {
        "response": "Hello world"
    }

@app.get("/invoices")
def invoices(response: Response, token: str = Depends(oauth2_scheme)):
    try:
        user = get_user_data(token)
        driver_id = models.check_for_driver(user["username"][1:])

        return models.Invoice.get_by_driver_id(driver_id)
    except Exception as e:
        response.status_code = status.HTTP_403_FORBIDDEN

        return {
            "error": str(e)
        }

@app.get("/invoices/{id}")
def invoices_id():
    ...

@app.post("/invoices/{id}/confirm")
def invoices_id_confirm(id: int, response: Response, token: str = Depends(oauth2_scheme)):
    try:
        get_user_data(token)

        result = models.Invoice.confirm_invoice(id)

        if result:
            response.status_code = status.HTTP_201_CREATED

            return {
                "record_id": result
            }
        else:
            response.status_code = status.HTTP_400_BAD_REQUEST
    except Exception as e:
        response.status_code = status.HTTP_403_FORBIDDEN

        return {
            "error": str(e)
        }

@app.post("/invoices/{id}/confirm-delivery")
def invoices_id_confirm_delivery(id: int, response: Response, token: str = Depends(oauth2_scheme)):
    try:
        get_user_data(token)

        result = models.Invoice.confirm_deliveries(id)

        if result:
            response.status_code = status.HTTP_200_OK

            return result
        else:
            response.status_code = status.HTTP_204_NO_CONTENT
    except Exception as e:
        response.status_code = status.HTTP_403_FORBIDDEN

        return {
            "error": str(e)
        }

@app.post("/return")
def invoices_return(data: models.Return, response: Response, token: str = Depends(oauth2_scheme)):
    try:
        user = get_user_data(token)

        result = data.create(user["user_id"], user["name"])

        if result:
            response.status_code = status.HTTP_201_CREATED

            return {
                "record_id": result
            }
        else:
            response.status_code = status.HTTP_400_BAD_REQUEST
    except Exception as e:
        response.status_code = status.HTTP_403_FORBIDDEN

        return {
            "error": str(e)
        }
    
@app.post("/return/{id}/lines")
def invoices_return_lines(id: int, data: list[models.ReturnLine], response: Response, token: str = Depends(oauth2_scheme)):
    try:
        get_user_data(token)

        result = models.create_return_lines(id, data)

        if result:
            response.status_code = status.HTTP_201_CREATED

            return result
        else:
            response.status_code = status.HTTP_400_BAD_REQUEST
    except Exception as e:
        response.status_code = status.HTTP_403_FORBIDDEN

        return {
            "error": str(e)
        } 

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
def post_login(data: dict, response: Response):
    try:
        # El token de acceso y su fecha de expiracion
        driver = login(data)

        if driver and models.check_for_driver(data["username"][1:]):
            return driver
        else:
            raise Exception("No hay ningún chofer con esas credenciales")
    except Exception as e:
        response.status_code = status.HTTP_403_FORBIDDEN

        return {
            "error": str(e)
        }
    
@app.get("/user")
def get_user(response: Response, token: str = Depends(oauth2_scheme)):
    try:
        user = get_user_data(token)

        return user
    except Exception as e:
        response.status_code = status.HTTP_403_FORBIDDEN

        return {
            "error": str(e)
        }