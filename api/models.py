from pydantic import BaseModel, Field, computed_field, conlist

class Login(BaseModel):
    cedula: str

    def login(self):
        with Database() as db:
            db.execute(
                "SELECT password, user_id FROM users WHERE username = %s",
                self.username,
            )

            result = db.fetchone()

            if result == None:
                raise Exception("Usuario invalido")
            
            # Comprobar hash de la clave
            if pwd_context.verify(self.password, result[0]):
                db.execute(
                    "UPDATE users SET last_login_date = %s WHERE user_id = %s",
                    datetime.datetime.now(),
                    result[1],
                )

                return create_access_token({
                    "sub": str(result[1]),
                    "exp": self.expiration
                })
            else:
                raise Exception("Contrasena incorrecta")