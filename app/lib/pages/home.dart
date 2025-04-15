import 'package:driver_return/services.dart';
import 'package:flutter/material.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _invoices = [];
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
      var result = await Provider.of<ApiService>(context, listen: false).get("invoices");

      setState(() {
        _invoices.addAll(result);
        _pages = (result.length / _size).ceil();
      });
    } catch(e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> slice = [];

    if (_invoices.isNotEmpty) {
      slice = _invoices.sublist(
        _currentPage * _size,
        (_currentPage * _size + _size).clamp(0, _invoices.length),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: slice.length,
              itemBuilder: (context, index) {
                return Text("Invoice ${slice[index]['customer_name']}");
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