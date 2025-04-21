import 'package:flutter/material.dart';

class InvoiceArguments {
  final int id;

  InvoiceArguments(this.id);
}

class InvoicePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Factura"),),
    );
  }

}