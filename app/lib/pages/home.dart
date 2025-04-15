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
  int _currentPage = 0;
  int _pages = 0;

  @override
  Widget build(BuildContext context) {
    var service = context.read<ApiService>();
    const size = 10;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: service.get("invoices"),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
                  _pages = (snapshot.data!.length / size).ceil(); // Usa ceil en lugar de round para redondear hacia arriba
                  var slice = snapshot.data!.sublist(
                    _currentPage * size,
                    (_currentPage * size + size).clamp(0, snapshot.data!.length), // Agregado clamp para evitar errores de rango
                  );

                  return ListView.builder(
                    itemCount: slice.length,
                    itemBuilder: (context, index) {
                      return Text("Invoice ${slice[index]['customer_name']}");
                    },
                  );
                } else if (snapshot.hasError) {
                  print("Error invoices: ${snapshot.error}");
                  return const Text("Error al cargar los datos");
                }

                return const Center(child: CircularProgressIndicator());
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