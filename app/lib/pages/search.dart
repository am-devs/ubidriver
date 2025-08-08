import 'package:driver_return/models.dart';
import 'package:driver_return/components.dart';
import 'package:driver_return/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class _SearchInvoiceState extends State<_SearchInvoice> {
  final List<Invoice> _invoices = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SearchBar(
            controller: _searchController,
            backgroundColor: WidgetStatePropertyAll(Colors.grey.shade50),
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            trailing: [const Icon(Icons.search, size: 32,)],
            hintText: "BUSCAR FACTURA",
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

              _searchController.clear();
            },
          ),
          if (_invoices.isNotEmpty)
            _buildInvoiceList()
        ],
      )
    );
  }

  Widget _buildInvoiceList() {
    Invoice inv;

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.7,
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: _invoices.length,
        itemBuilder: (context, index) {
          inv = _invoices[index];

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                width: 2.0,
                color: Colors.red
              )
            ),
            color: Colors.white,
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              leading: FlutterLogo(size: 72.0),
              title: Text(
                inv.code,
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: RichText(
                text: TextSpan(
                  text: "CLIENTE: ",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  children: [
                    TextSpan(text: inv.customer.name.toUpperCase(), style: TextStyle(color: Colors.red))
                  ]
                )
              ),
              trailing: Icon(
                Icons.keyboard_arrow_right,
                size: 48,
                color: Colors.red.shade700,
              ),
              onTap: () {
                final state = Provider.of<AppState>(context, listen: false);
                
                state.setInvoice(inv);
                state.advanceState();
                Navigator.of(context).pushNamed("/invoice");
              },
            ),
          );
        }, 
        separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 16,),
      )
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