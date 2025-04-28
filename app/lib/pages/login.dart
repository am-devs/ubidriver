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
              final service = context.read<ApiService>();
              final result = await service.authenticate(myController.text);

              if(!result) return;

              final invoices = await service.get<List<dynamic>>("invoices");

              if(context.mounted) {
                Provider.of<InvoiceMap>(context, listen: false).initialize(invoices.map((json) => Invoice.fromJson(json)));
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