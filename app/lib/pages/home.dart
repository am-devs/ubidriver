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
  int _currentPage = 0;
  int _pages = 1;
  static const _size = 10;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  _fetchData() async {
    try {
      var result = await Provider.of<ApiService>(context, listen: false).get<List<dynamic>>("invoices");


      setState(() {
        if(result.isEmpty) {
          return Navigator.of(context).pop();
        }

        Provider.of<InvoiceMap>(context, listen: false).initialize(result.map((json) => Invoice.fromJson(json)));
        _pages = (result.length / _size).ceil();
      });
    } catch(e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    var invoices = Provider.of<InvoiceMap>(context, listen: false).toList();
    List<Invoice> slice = [];

    if (invoices.isNotEmpty) {
      final int start = _currentPage * _size;

      slice = invoices.sublist(
        start,
        (start + _size).clamp(0, invoices.length),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chofer"),
      ),
      body: Column(
        children: [
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
          NumberPaginator(
            numberPages: _pages,
            onPageChange: (n) {
              setState(() {
                _currentPage = n;
              });
            },
          ),
        ]
      )
    );
  }
}