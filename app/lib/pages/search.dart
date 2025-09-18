import 'package:gdd/models.dart';
import 'package:gdd/components.dart';
import 'package:gdd/services.dart';
import 'package:gdd/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final List<Invoice> _invoices = [];
  final TextEditingController _searchController = TextEditingController();
  bool _loading = false;
  String _pattern = "";

  List<Invoice> get _filteredInvoices {
    if (_pattern.isEmpty) {
      return _invoices;
    } else {
      return _invoices.where((i) => i.code.toLowerCase().contains(_pattern)).toList();
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInvoices();
    });
  }

  Future<void> _fetchInvoices() async {
    try {
      setState(() {
        _loading = true;
      });

      final results = await Provider.of<ApiService>(context, listen: false).get<List<dynamic>>("/invoices");

      setState(() {
        _invoices.clear();
        _invoices.addAll(results.map((x) => Invoice.fromJson(x)));
        _searchController.clear();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Ocurrió un error: $e'),
        ));
      }
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

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
            onSubmitted: (String pattern) {
              setState(() {
                _pattern = pattern;
              });
            },
          ),
        ),
        if (_filteredInvoices.isNotEmpty)
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchInvoices,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 24),
                shrinkWrap: true,
                itemCount: _filteredInvoices.length,
                itemBuilder: (context, index) => AppInvoiceCard(
                  invoice: _filteredInvoices[index],
                  onTap: () {
                    final state = Provider.of<AppState>(context, listen: false);

                    state.setInvoice(_filteredInvoices[index]);

                    state.advanceState();

                    Navigator.of(context).pushNamed("/invoice");
                  },
                ), 
                separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 4,),
              ), 
            )
          )
        else if (_filteredInvoices.isEmpty && !_loading)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search, size: 128, color: Colors.grey,),
                const Text("No hay nada que mostrar", style: TextStyle(color: Colors.grey, fontSize: 24),)
              ],
            ),
          )
        else
          Center(child: CircularProgressIndicator(),),
        if (_filteredInvoices.isNotEmpty)
          SizedBox(
            height: 48,
            child: Center(child: Text("Facturas encontradas: ${_filteredInvoices.length}"),),
          )
      ]
    );
  }
}