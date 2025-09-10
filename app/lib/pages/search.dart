import 'package:driver_return/models.dart';
import 'package:driver_return/components.dart';
import 'package:driver_return/services.dart';
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

  Future<void> _onSubmitted(String value) async {
    var results = await Provider.of<ApiService>(context, listen: false).get<List<dynamic>>("/invoices?pattern=$value");

    setState(() {
      _invoices.clear();
      _invoices.addAll(results.map((x) => Invoice.fromJson(x)));
    });

    _searchController.clear();
  }
}