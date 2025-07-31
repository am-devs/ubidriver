import 'package:driver_return/models.dart';
import 'package:driver_return/services.dart';
import 'package:driver_return/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

final class _InvalidUserException implements Exception {
  @override
  String toString() => 'Usuario inválido';
}

class _LoginFormState extends State<LoginForm> {
  bool _isLoading = false;
  final _formGlobalKey = GlobalKey<FormState>();
  String _username = "";
  String _password = "";

  @override
  Widget build(BuildContext context) {
    if(_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

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
                setState(() {
                  _isLoading = true;
                });

                final service = context.read<ApiService>();
                final result = await service.authenticate(_username, _password);

                if(!result) throw _InvalidUserException();

                // final invoices = await service.get<List<dynamic>>("invoices");

                if(context.mounted) {
                  // if (invoices.isNotEmpty) {
                  //   Provider.of<InvoiceMap>(context, listen: false).initialize(invoices.map((json) => Invoice.fromJson(json)));
                  // }

                  Navigator.pushNamed(context, '/deliver');
                }
              } catch(e) {
                print(e);

                if(context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Ocurrió un error: $e'),
                  ));
                }
              } finally {
                setState(() {
                  _isLoading = false;
                });
              }
          },
          child: const Text("Iniciar sesión"),
        ),

        ],
      )
    );
  }
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoginForm(),
    );
  }
}