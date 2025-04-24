import 'package:driver_return/models.dart';
import 'package:flutter/material.dart';

class ReturnPageArguments {
  final int bpartnerId;
  final List<InvoiceLine> lines;

  ReturnPageArguments(this.bpartnerId, this.lines);
}

class ReturnPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Devolución"),),
    );
  }

}