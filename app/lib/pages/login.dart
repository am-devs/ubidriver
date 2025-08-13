import 'package:flutter/material.dart';

class _LoginForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginFormState();
}


class _LoginFormState extends State<_LoginForm> {
  final _formGlobalKey = GlobalKey<FormState>();
  String _username = "";
  String _password = "";

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formGlobalKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            TextFormField(
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade50),
                  borderRadius: BorderRadius.circular(24)
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(24)
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(24)
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red.shade300),
                  borderRadius: BorderRadius.circular(24)
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(24)
                ),
                errorStyle: TextStyle(color: Colors.red.shade200),
                hintText: "Usuario",
                hintStyle: TextStyle(color: Colors.grey.shade300),
              ),
              cursorColor: Colors.white,
              style: TextStyle(color: Colors.white),
              onSaved: (value) {
                _username = value!;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "El usuario es obligatorio";
                }

                return null;
              },
            ),
            TextFormField(
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade50),
                  borderRadius: BorderRadius.circular(24)
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(24)
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red.shade300),
                  borderRadius: BorderRadius.circular(24)
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red.shade400),
                  borderRadius: BorderRadius.circular(24)
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(24)
                ),
                errorStyle: TextStyle(color: Colors.red.shade200),
                hintText: "Contraseña",
                hintStyle: TextStyle(color: Colors.grey.shade300),
              ),
              cursorColor: Colors.white,
              style: TextStyle(color: Colors.white),
              obscureText: true,
              onSaved: (value) {
                _password = value!;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "La contraseña es obligatoria";
                }

                return null;
              },
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 32),
                  backgroundColor: Colors.red
                ),
                onPressed: () async {
                    if (!_formGlobalKey.currentState!.validate()) {
                      return;
                    }

                    _formGlobalKey.currentState!.save();

                    try {
                      print("$_username - $_password");

                      if(context.mounted) {
                        Navigator.pushNamed(context, '/search');
                      }
                    } catch(e) {
                      print(e);

                      if(context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Ocurrió un error: $e'),
                        ));
                      }
                    }
                },
                child: const Text(
                  "INICIAR",
                  style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w400),
                ),
              ),

            ),
            Divider(
              height: 4,
              color: Colors.white,
            ),
          ]
        ),
      );
  }
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/login.png"),
            fit: BoxFit.cover,
            opacity: 0.5
          )
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 20,
            children: [
              Image(
                image: AssetImage("assets/logo.png"),
              ),
              const Text(
                "BIENVENIDO",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
              ),
              _LoginForm()
            ],
          )
        ),
      ),
    );
  }
}