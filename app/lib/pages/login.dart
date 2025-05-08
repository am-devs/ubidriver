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
  final myController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
          child: TextField(
            controller: myController,
            decoration: InputDecoration(border: OutlineInputBorder(), labelText: "C.I"),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
              setState(() {
                _isLoading = true;
              });

              final service = context.read<ApiService>();

              try {
                final result = await service.authenticate(myController.text);

                if(!result) throw _InvalidUserException();

                final invoices = await service.get<List<dynamic>>("invoices");

                if(context.mounted) {
                  Provider.of<InvoiceMap>(context, listen: false).initialize(invoices.map((json) => Invoice.fromJson(json)));
                  Navigator.pushNamed(context, '/home');
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
      ]
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