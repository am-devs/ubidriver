import 'package:driver_return/models.dart';
import 'package:driver_return/pages/return.dart';
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

class _InvoiceLineWidget extends StatelessWidget {
  final InvoiceLine _line;
  final bool _enabled;
  final bool _selected;
  final VoidCallback _onTap;

  _InvoiceLineWidget(this._line, this._enabled, this._selected, this._onTap);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: _enabled,
      selected: _selected,
      onTap: _onTap,
      title: Text(_line.product.name),
      subtitle: Text("${_line.quantity} - ${_line.uom}"),
      textColor: WidgetStateColor.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.primaries.first.shade500;
        } else {
          return Colors.black;
        }
      }),
    );
  }
}

class InvoicePageState extends State<InvoicePage> {
  final _key = GlobalKey<ExpandableFabState>();
  Invoice? _invoice;
  Map<int, bool> _selectedLines = {};
  bool _isLoading = true;
  bool _enabled = false;

  int get _selectedLinesCount => _selectedLines.values.where((l) => l).length;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      setState(() {
        _invoice = Provider.of<InvoiceMap>(context, listen: false).get(widget.invoiceId);
        _selectedLines.addAll({ for (var i in _invoice!.lines) i.id: false});
        _isLoading = false;
      });
    }
  }

  Widget _getFab() {
    return ExpandableFab(
      key: _key,
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
      
      await service.post<Map<String, dynamic>>("invoices/${widget.invoiceId}/confirm").then((_) =>
        service.post<Map<String, dynamic>>("invoices/${widget.invoiceId}/confirm-delivery")
      );

      if(mounted) {
        Provider.of<InvoiceMap>(context, listen: false).remove(widget.invoiceId);
        Navigator.of(context).pushNamed("/home");
      }
    } catch(e) {
      print(e);
    }
  }

  void _returnInvoice() async {
    final state = _key.currentState;
    
    if(state != null) {
      state.toggle();
    }

    setState(() {
      _enabled = true;
    });
  }

  void _disable() {
    setState(() {
      _enabled = false;

      for (var k in _selectedLines.keys) {
        _selectedLines[k] = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final defaultBar = AppBar(title: const Text("Factura"));

    if (_isLoading || _invoice == null) {
      return Scaffold(
        appBar: defaultBar,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: !_enabled
        ? defaultBar
        : AppBar(
          title: Text("$_selectedLinesCount lineas seleccionadas"),
          leading: IconButton(onPressed: _disable, icon: Icon(Icons.close)),
          centerTitle: true,
          actions: [
            Visibility(
              visible: _selectedLinesCount > 0,
              child: IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/return", arguments: ReturnArguments(
                    _invoice!.customer.id,
                    _invoice!.lines.where((l) => _selectedLines[l.id] == true).toList()
                  ));
                },
                icon: Icon(Icons.arrow_forward_rounded)
              ), 
            )
          ],
        ),
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
                  key: Key(line.id.toString()),
                  children: [
                    _InvoiceLineWidget(
                      line,
                      _enabled,
                      _selectedLines[line.id]!,
                      () => setState(() {
                        _selectedLines[line.id] = !_selectedLines[line.id]!;
                      })
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