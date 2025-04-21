import 'package:driver_return/models.dart';
import 'package:driver_return/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InvoiceArguments {
  final int id;

  InvoiceArguments(this.id);
}

class InvoicePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as InvoiceArguments;
    var invoice = Provider.of<InvoiceMap>(context, listen: false).get(args.id)!;
    InvoiceLine line;

    return Scaffold(
      appBar: AppBar(title: const Text("Factura")),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 0,
              bottom: 10
            ), 
            child: Column(
              children: [
                Row(
                  children: [
                    const Text("Factura:", style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(child: Text(invoice.code, textAlign: TextAlign.end,)),
                  ]
                ),
                Row(
                  children: [
                    const Text("Organización:", style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(child: Text(invoice.organization, textAlign: TextAlign.end,)),
                  ]
                ),
                Row(
                  children: [
                    const Text("Cliente:", style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(child: Text(invoice.customer.name, textAlign: TextAlign.end,)),
                  ]
                ),
                Row(
                  children: [
                    const Text("Fecha:", style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(child: Text(invoice.date.toString(), textAlign: TextAlign.end,)),
                  ]
                ),
              ]
            )
          ),
          const Divider(height: 0,),
          Expanded(
            child: ListView.builder(
              itemCount: invoice.lines.length,
              itemBuilder: (context, index) {
                line = invoice.lines[index];

                return Column(
                  children: [
                    ListTile(
                      title: Text(line.product.name),
                      subtitle: Text("${line.quantity} - ${line.uom}"),
                    ),
                    const Divider(height: 0,)
                  ]
                );
              }
            )
          )
        ],
      ),
    );
  }

}