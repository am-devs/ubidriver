import 'package:driver_return/models.dart';
import 'package:driver_return/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class _InvoicePageState extends State<InvoicePage> {
  Set<int> selections = {};

  @override
  Widget build(BuildContext context) {
    Invoice? invoice = Provider.of<AppState>(context).invoice;

    if (invoice == null) {
      return Scaffold(body: const Text("No hay nada que mostrar"));
    }

    List<InvoiceLine> lines = invoice.lines;

    const boldStyle = TextStyle(fontWeight: FontWeight.bold);
    final defaultStyle = DefaultTextStyle.of(context).style;
    final custom = invoice.customer;

    return Scaffold(
      body: Column(
        children: [
            RichText(
            text: TextSpan(
              text: 'CLIENTE',
              style: boldStyle,
              children: <TextSpan>[
                TextSpan(text: custom.name, style: defaultStyle),
                TextSpan(text: "\nRIF", style: boldStyle),
                TextSpan(text: custom.vat, style: defaultStyle),
                TextSpan(text: "\nDIRECCION", style: boldStyle),
                TextSpan(text: custom.address, style: defaultStyle)
              ]
            )
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("PRODUCTO"),
              const Text("CANTIDAD")
            ],
          ),
          if (lines.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              itemCount: lines.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    selected: selections.contains(index),
                    title: Text(lines[index].product.name),
                    trailing: Text(lines[index].quantity.toString()),
                    onTap: () {
                      if (selections.contains(index)) {
                        selections.remove(index);
                      } else {
                        selections.add(index);
                      }
                    },
                  ),
                );
              }
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16,
            children: [
              ElevatedButton(
                child: const Text("CONFIRMAR"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed("/return");
                },
                child: const Text("DEVOLUCION")
              )
            ],
          )
        ],
      )
    );
  }
}

class InvoicePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _InvoicePageState();
}