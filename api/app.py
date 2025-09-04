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
def get_invoices(response: Response, pattern: str, token: str = Depends(oauth2_scheme)):
    try:
        user = get_user_data(token)
        driver_id = models.check_for_driver(user["username"][1:])

        return models.Invoice.get_by_driver_and_pattern(driver_id, pattern)
    except Exception as e:
        print(e)

        response.status_code = status.HTTP_403_FORBIDDEN

        return {
            "error": str(e)
        }

@app.post("/invoices/{id}/confirm")
def invoices_id_confirm(id: int, data: models.InvoiceConfirm, response: Response, token: str = Depends(oauth2_scheme)):
    try:
        get_user_data(token)

        result = models.Invoice.confirm_invoice(id, data)

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
    
@app.get("/devolution-types")
def get_user(response: Response):
    try:
        return models.DevolutionType.get_all()
    except Exception as e:
        response.status_code = status.HTTP_403_FORBIDDEN

        return {
            "error": str(e)
        }