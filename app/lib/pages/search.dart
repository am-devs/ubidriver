import 'package:driver_return/models.dart';
import 'package:driver_return/components.dart';
import 'package:driver_return/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class _SearchInvoiceState extends State<_SearchInvoice> {
  final List<Invoice> _invoices = [];

  @override
  Widget build(BuildContext context) {
    Invoice inv;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: SearchBar(
            leading: const Icon(Icons.search),
            hintText: "Buscar factura",
            onSubmitted: (value) {
              final invoice = Invoice(
                code: "123",
                date: DateTime.now(),
                id: 0,
                organization: "Iancarina",
                customer: const Customer(name: "David Linarez", id: 1, address: "Hello world", vat: "123"),
              );

              invoice.lines.add(InvoiceLine(
                product: const Product(id: 1, name: "Product"), 
                quantity: 100, 
                uom: "Bultos"
              ));

              invoice.lines.add(InvoiceLine(
                product: const Product(id: 2, name: "Productos"), 
                quantity: 50,
                uom: "Bultos"
              ));

              invoice.lines.add(InvoiceLine(
                product: const Product(id: 3, name: "Producto"), 
                quantity: 150,
                uom: "Bultos"
              ));

              setState(() {
                _invoices.add(invoice);
              });
            },
          )
        ),
        if (_invoices.isNotEmpty)
          Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _invoices.length,
                itemBuilder: (context, index) {
                  inv = _invoices[index];

                  return Card(
                    child: ListTile(
                      leading: FlutterLogo(size: 72.0),
                      title: Text(inv.code),
                      subtitle: Text('CLIENTE: ${inv.customer.name}'),
                      trailing: Icon(Icons.keyboard_arrow_right_sharp),
                      onTap: () {
                        var state = Provider.of<AppState>(context, listen: false);
                        
                        state.setInvoice(inv);
                        state.advanceState();
                        Navigator.of(context).pushNamed("/invoice");
                      },
                    ),
                  );
                },
              )
            ),
      ],
    );
  }
}

class _SearchInvoice extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SearchInvoiceState();
}

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      children: [
        _SearchInvoice()
      ]
    );
  }
}