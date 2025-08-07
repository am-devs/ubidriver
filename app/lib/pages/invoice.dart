import 'package:driver_return/models.dart';
import 'package:driver_return/components.dart';
import 'package:driver_return/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class _InvoiceLineTableState extends State<_InvoiceLineTable> {
  Set<int> _selections = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListView.builder(
          shrinkWrap: true,
          itemCount: widget.lines.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                selected: _selections.contains(index),
                title: Text(widget.lines[index].product.name),
                enabled: widget.lines[index] is InvoiceLine,
                trailing: Text(widget.lines[index].quantity.toString()),
                onTap: () {
                  setState(() {
                    if (_selections.contains(index)) {
                      _selections.remove(index);
                    } else {
                      _selections.add(index);
                    }
                  });
                },
              ),
            );
          }
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16,
          children: [
            ElevatedButton(
              child: const Text("CONFIRMAR"),
              onPressed: () {
                var state = Provider.of<AppState>(context, listen: false);

                state.advanceState();
                state.advanceState();

                Navigator.of(context).pushNamed("/resume");
              },
            ),
            ElevatedButton(        
              onPressed: _selections.isEmpty ? null : () {
                var state = Provider.of<AppState>(context, listen: false);
                
                // Selected lines will always be InvoiceLine
                state.setReturnLines(_selections.map((s) => widget.lines[s] as InvoiceLine).toList());
                state.advanceState();

                setState(() {
                  _selections.clear();
                });

                Navigator.of(context).pushNamed("/return");
              },
              child: const Text("DEVOLUCION")
            )
          ],
        )
      ],
    );
  }
}

class _InvoiceLineTable extends StatefulWidget {
  final List<ProductLine> lines;

  _InvoiceLineTable({required this.lines});

  @override
  State<StatefulWidget> createState() => _InvoiceLineTableState();
}

class InvoicePage extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      Invoice? invoice = Provider.of<AppState>(context).invoice!;
      final custom = invoice.customer;
      List<ProductLine> lines = [...invoice.lines, ...invoice.returns.values];

      const boldStyle = TextStyle(fontWeight: FontWeight.bold);
      final defaultStyle = DefaultTextStyle.of(context).style;

      return AppScaffold(
        children: [
          RichText(
            text: TextSpan(
              text: 'CLIENTE',
              style: boldStyle,
              children: <TextSpan>[
                TextSpan(text: custom.name, style: defaultStyle),
                TextSpan(text: "\nRIF", style: boldStyle),
                TextSpan(text: custom.vat, style: defaultStyle),
                TextSpan(text: "\nDIRECCION", style: boldStyle),
                TextSpan(text: custom.address, style: defaultStyle)
              ]
            )
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("PRODUCTO"),
              const Text("CANTIDAD")
            ],
          ),
          if (lines.isNotEmpty)
            _InvoiceLineTable(lines: lines)
        ]
      );
  }

}