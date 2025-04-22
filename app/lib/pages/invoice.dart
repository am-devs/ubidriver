import 'package:driver_return/models.dart';
import 'package:driver_return/services.dart';
import 'package:driver_return/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:provider/provider.dart';

class InvoiceArguments {
  final int id;

  InvoiceArguments(this.id);
}

class InvoicePage extends StatefulWidget {
  final int invoiceId;

  InvoicePage(this.invoiceId);

  @override
  InvoicePageState createState() => InvoicePageState();
}

class InvoicePageState extends State<InvoicePage> {
  Invoice? _invoice;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      _invoice = Provider.of<InvoiceMap>(context, listen: false).get(widget.invoiceId);
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _getFab() {
    return ExpandableFab(
      type: ExpandableFabType.up,
      childrenAnimation: ExpandableFabAnimation.none,
      distance: 70,
      overlayStyle: ExpandableFabOverlayStyle(
        color: Colors.white.withValues(alpha: 0.9),
      ),
      children: [
        Row(
          children: [
            Text('Confirmar'),
            SizedBox(width: 20),
            FloatingActionButton.small(
              heroTag: null,
              onPressed: _confirmInvoice,
              child: Icon(Icons.check),
            ),
          ],
        ),
        Row(
          children: [
            Text('Retornar'),
            SizedBox(width: 20),
            FloatingActionButton.small(
              heroTag: null,
              onPressed: _returnInvoice,
              child: Icon(Icons.repeat_rounded),
            ),
          ],
        ),
      ],    );
  }

  void _confirmInvoice() async {
    try {
      final service = Provider.of<ApiService>(context, listen: false);
      
      await service.post<Map<String, int>>("/invoice/${widget.invoiceId}/confirm");
      await service.post<Map<String, int>>("/invoice/${widget.invoiceId}/confirm-delivery");

      if(mounted) {
        Provider.of<InvoiceMap>(context, listen: false).remove(widget.invoiceId);
        Navigator.of(context).pushNamed("/home");
      }
    } catch(e) {
      print(e);
    }
  }

  void _returnInvoice() async {}

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _invoice == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Factura")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Factura")),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 0,
              bottom: 10
            ), 
            child: Column(
              children: [
                Row(
                  children: [
                    const Text("Factura:", style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(child: Text(_invoice!.code, textAlign: TextAlign.end,)),
                  ]
                ),
                Row(
                  children: [
                    const Text("Factura:", style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(child: Text(_invoice!.code, textAlign: TextAlign.end,)),
                  ]
                ),
                Row(
                  children: [
                    const Text("Organización:", style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(child: Text(_invoice!.organization, textAlign: TextAlign.end,)),
                  ]
                ),
                Row(
                  children: [
                    const Text("Cliente:", style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(child: Text(_invoice!.customer.name, textAlign: TextAlign.end,)),
                  ]
                ),
                Row(
                  children: [
                    const Text("Fecha:", style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(child: Text(_invoice!.date.toString(), textAlign: TextAlign.end,)),
                  ]
                ),
              ]
            )
          ),
          const Divider(height: 0,),
          Expanded(
            child: ListView.builder(
              itemCount: _invoice!.lines.length,
              itemBuilder: (context, index) {
                final line = _invoice!.lines[index];

                return Column(
                  children: [
                    ListTile(
                      title: Text(line.product.name),
                      subtitle: Text("${line.quantity} - ${line.uom}"),
                    ),
                    const Divider(height: 0,)
                  ]
                );
              }
            )
          )
        ],
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: !_invoice!.confirm ? _getFab() : Container(),
    );
  }
}