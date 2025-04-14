import 'package:driver_return/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    var service = context.read<ApiService>();

    return Scaffold(
      body: FutureBuilder(
        future: service.get("invoices"),
        builder: (context, snapshot) {
          if(snapshot.hasData  && snapshot.connectionState == ConnectionState.done) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Text("Invoice $index");
              }
            );
          } else if(snapshot.hasError) {
            print("Error invoices: ${snapshot.error}");
            return const Text("Hello world");
          }
      
          return const CircularProgressIndicator();
        }
      ),
    );
  }
}
