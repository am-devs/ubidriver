from fastapi import Depends, FastAPI, Response, status
from fastapi.security import OAuth2PasswordBearer
from authentication import login, get_user_data
import models
import logging

app = FastAPI(root_path="/v1")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/v1/login")

logger = logging.getLogger(__name__)

@app.get("/")
def get_ping():
    print("Hello world")

    return {
        "response": "Hello world"
    }

@app.get("/invoices")
def get_invoices(response: Response, token: str = Depends(oauth2_scheme)):
    try:
        user = get_user_data(token)
        driver_id = models.check_for_driver(user["username"][1:])

        return models.Invoice.get_by_driver(driver_id)
    except Exception as e:
        print(e)

        response.status_code = status.HTTP_403_FORBIDDEN

        return {
            "error": str(e)
        }

@app.post("/invoices/{id}/confirm")
def post_invoices_id_confirm(id: int, response: Response, coordinates: models.Point = None, token: str = Depends(oauth2_scheme)):
    try:
        get_user_data(token)

        logger.info(coordinates)

        models.Invoice.confirm_invoice(id, coordinates)
    except Exception as e:
        logger.exception("Error")

        response.status_code = status.HTTP_403_FORBIDDEN

        return {
            "error": str(e)
        }
    
@app.post("/invoices/{id}/return")
def post_return(id: int, data: models.ReturnInvoice, response: Response, token: str = Depends(oauth2_scheme)):
    try:
        get_user_data(token)

        result = data.return_invoice(id)

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
    
@app.get("/invoices/{id}/return")
def get_invoice_return_id(id: int, response: Response, token: str = Depends(oauth2_scheme)):
    try:
        get_user_data(token)

        result = models.ReturnStatus.search_for_invoice_id(id)

        if result:
            response.status_code = status.HTTP_201_CREATED

            return result
        else:
            response.status_code = status.HTTP_404_NOT_FOUND
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
def get_devolution_types(response: Response):
    try:
        return models.DevolutionType.get_all()
    except Exception as e:
        response.status_code = status.HTTP_403_FORBIDDEN

        return {
            "error": str(e)
        }
    
@app.get("/export/devolution-types")
def get_export_devolution_types(response: Response):
    try:
        return models.DevolutionType.to_export()
    except Exception as e:
        response.status_code = status.HTTP_400_BAD_REQUEST

        return {
            "error": str(e)
        }
    
@app.get("/export/partner-coordinates")
def get_partner_coordinates(response: Response):
    try:
        return models.Point.export_from_customer()
    except Exception as e:
        response.status_code = status.HTTP_400_BAD_REQUEST

        return {
            "error": str(e)
        }