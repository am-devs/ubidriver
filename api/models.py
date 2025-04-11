from pydantic import BaseModel
from database import Database
from authentication import create_access_token
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

class Login(BaseModel):
    cedula: str

    def login(self):
        with Database() as db:
            db.execute("""
SELECT 
    fta_driver_id,
    name
FROM fta_driver
WHERE value = %s""", self.cedula)

            result = db.fetchone()

            if result == None:
                raise Exception("Usuario invalido")
            
            # Comprobar hash de la cedula
            if pwd_context.verify(self.cedula, result[0]):
                return create_access_token({
                    "sub": str(result[1]),
                    "exp": self.expiration
                })
            else:
                raise Exception("Usuario invalido")