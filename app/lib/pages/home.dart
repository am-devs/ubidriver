import 'package:driver_return/models.dart';
import 'package:driver_return/pages/invoice.dart';
import 'package:driver_return/services.dart';
import 'package:driver_return/state.dart';
import 'package:flutter/material.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:provider/provider.dart';

class _InvoiceTile extends StatelessWidget {
  final Invoice invoice;

  const _InvoiceTile(this.invoice);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        onTap: () {
          Navigator.pushNamed(context, '/invoice', arguments: InvoiceArguments(invoice.id));
        },  
        title: Text(invoice.code),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(invoice.customer.name),
            Text(invoice.organization, style: const TextStyle(fontSize: 12)),
          ]),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _size = 10;
  int _currentPage = 0;
  String _pattern = "";

  @override
  Widget build(BuildContext context) {
    final allInvoices = Provider.of<InvoiceMap>(context).toList();

    final invoices = _pattern != "" 
      ? allInvoices.where((i) => i.code.contains(_pattern))
      : allInvoices;

    final pages = (invoices.length / _size).ceil();
    List<Invoice> slice = [];

    if (invoices.isNotEmpty) {
      final start = _currentPage * _size;

      slice = invoices.toList().sublist(
        start,
        (start + _size).clamp(0, invoices.length),
      );
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "Chofer",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
            onPressed: () {
              Provider.of<ApiService>(context, listen: false).unauthenticated();
              Navigator.pushNamed(context, "/login");
            },
            icon: Icon(Icons.logout)
          ), 
      ),
      body: (invoices.isNotEmpty)
        ? Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Buscar factura"
                ),
                onChanged: (value) => setState(() {
                  _pattern = value;
                }),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: slice.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      _InvoiceTile(slice[index]),
                      const Divider(height: 0),
                    ]
                  );
                },
              )
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: NumberPaginator(
                numberPages: pages,
                onPageChange: (n) {
                  setState(() {
                    _currentPage = n;
                  });
                },
              ),
            )
          ])
        : Center(child: Text("No hay nada que mostrar"),)
    );
  }
}