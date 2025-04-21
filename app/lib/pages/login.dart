import 'package:driver_return/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final myController = TextEditingController();

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(4),
          child: TextField(
            controller: myController,
            decoration: InputDecoration(border: OutlineInputBorder(), labelText: "C.I"),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
              var service = context.read<ApiService>();
              var result = await service.authenticate(myController.text);

              if(result && context.mounted) {
                Navigator.pushNamed(context, '/home');
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
      body: LoginForm()
    );
  }
}