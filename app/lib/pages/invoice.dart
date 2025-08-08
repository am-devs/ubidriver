import 'package:driver_return/models.dart';
import 'package:driver_return/components.dart';
import 'package:driver_return/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class _InvoiceLineTableState extends State<_InvoiceLineTable> {
  Set<int> _selections = {};

  @override
  Widget build(BuildContext context) {
    const buttonStyle = TextStyle(color: Colors.white, fontWeight: FontWeight.bold);

    return Column(
      children: [
        ListView.builder(
          padding: EdgeInsets.only(bottom: 32),
          shrinkWrap: true,
          itemCount: widget.lines.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 1,
              color: Color.fromRGBO(255, 248, 248, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: Colors.red
                )
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                selected: _selections.contains(index),
                title: Text(
                  widget.lines[index].product.name.toUpperCase(),
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
                ),
                enabled: widget.lines[index] is InvoiceLine,
                trailing: Text(
                  widget.lines[index].quantity.toString(),
                  style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                ),
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
              style: appButtonStyle,
              child: const Text("CONFIRMAR", style: buttonStyle,),
              onPressed: () {
                final state = Provider.of<AppState>(context, listen: false);

                state.advanceState();
                state.advanceState();

                Navigator.of(context).pushNamed("/resume");
              },
            ),
            ElevatedButton(   
              style: appButtonStyle,     
              onPressed: _selections.isEmpty ? null : () {
                // Selected lines will always be InvoiceLine
                Provider.of<AppState>(context, listen: false).setReturnLines(_selections.map((s) => widget.lines[s] as InvoiceLine).toList());

                setState(() {
                  _selections.clear();
                });

                Navigator.of(context).pushNamed("/return");
              },
              child: const Text("DEVOLUCION", style: buttonStyle,)
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

      const boldStyle = TextStyle(fontWeight: FontWeight.bold, color: Colors.black);
      final defaultStyle = TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w400);

      return AppScaffold(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppBackButton(),
              Padding(
                padding: EdgeInsets.only(right: 16),
                child: Text(
                  invoice.code,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 24,
                    fontWeight: FontWeight.bold
                  ),
                )
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24, horizontal: 32),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: SizedBox(
                    width: MediaQuery.sizeOf(context).width,
                    child: RichText(
                      text: TextSpan(
                        text: 'CLIENTE: ',
                        style: boldStyle,
                        children: <TextSpan>[
                          TextSpan(text: custom.name.toUpperCase(), style: defaultStyle),
                          TextSpan(text: "\nRIF: ", style: boldStyle),
                          TextSpan(text: custom.vat.toUpperCase(), style: defaultStyle),
                          TextSpan(text: "\nDIRECCION: ", style: boldStyle),
                          TextSpan(text: custom.address.toUpperCase(), style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                        ]
                      )
                    ),
                  ),
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("PRODUCTO", style: boldStyle,),
                    Text("CANTIDAD", style: boldStyle,)
                  ],
                ),
                if (lines.isNotEmpty)
                  _InvoiceLineTable(lines: lines)
              ],
            )
          )
        ]
      );
  }

}