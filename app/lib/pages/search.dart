import 'package:driver_return/models.dart';
import 'package:driver_return/components.dart';
import 'package:driver_return/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final List<Invoice> _invoices = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      children: [
        Padding(
          padding: EdgeInsets.all(24),
          child: SearchBar(
            controller: _searchController,
            backgroundColor: WidgetStatePropertyAll(Colors.grey.shade50),
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            trailing: [const Icon(Icons.search, size: 32,)],
            hintText: "BUSCAR FACTURA",
            onSubmitted: _onSubmitted,
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 24),
            shrinkWrap: true,
            itemCount: _invoices.length,
            itemBuilder: (context, index) => AppInvoiceCard(
              invoice: _invoices[index],
              isApproved: true,
              onTap: () {
                final state = Provider.of<AppState>(context, listen: false);

                state.setInvoice(_invoices[index]);
                state.advanceState();
                Navigator.of(context).pushNamed("/invoice");
              },
            ), 
            separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 4,),
          )
        )
      ]
    );
  }

  void _onSubmitted(String value) {
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
  }
}