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
          children: [
            TextFormField(
              decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Usuario"),
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
              obscureText: true,
              decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Clave"),
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
            ElevatedButton(
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
              child: const Text("Iniciar sesión"),
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
      body: _LoginForm(),
    );
  }
}