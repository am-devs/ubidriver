import 'package:driver_return/models.dart';
import 'package:driver_return/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class _SearchInvoiceState extends State<_SearchInvoice> {
  List<Invoice> _invoices = [];

  @override
  Widget build(BuildContext context) {
    Invoice inv;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: SearchBar(
            leading: const Icon(Icons.search),
            hintText: "Buscar factura",
            onSubmitted: (value) {
              setState(() {
                final invoice = Invoice(
                  code: "123",
                  date: DateTime.now(),
                  id: 0,
                  organization: "Iancarina",
                  customer: const Customer(name: "David Linarez", id: 1, address: "Hello world", vat: "123"),
                );

                invoice.lines.add(InvoiceLine(
                  id: 1, 
                  product: const Product(id: 1, name: "Product"), 
                  quantity: 100, 
                  uom: "Bultos"
                ));

                invoice.lines.add(InvoiceLine(
                  id: 2, 
                  product: const Product(id: 2, name: "Productos"), 
                  quantity: 50,
                  uom: "Bultos"
                ));

                invoice.lines.add(InvoiceLine(
                  id: 3, 
                  product: const Product(id: 3, name: "Producto"), 
                  quantity: 150,
                  uom: "Bultos"
                ));

                _invoices.add(invoice);
              });
            },
          )
        ),
        if (_invoices.isNotEmpty)
          Expanded(
              child: ListView.builder(
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
                        Provider.of<AppState>(context, listen: false).setInvoice(inv);
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
    return Scaffold(
      body: _SearchInvoice()
    );
  }
}