import 'package:driver_return/models.dart';
import 'package:driver_return/components.dart';
import 'package:driver_return/services.dart';
import 'package:driver_return/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class _ReturningLineCard extends StatelessWidget {
  final ReturnLine line;

  _ReturningLineCard({required this.line});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.blueGrey.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
        title: Text(
          line.product.name.toUpperCase(),
          style: TextStyle(color:Colors.black, fontWeight: FontWeight.w400),
        ),
        trailing: Text(
          "-${line.quantity.toString()}",
          style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        )
      )
    );
  }

}

class _InvoiceLineTableState extends State<_InvoiceLineTable> {
  Set<int> _selections = {};

  @override
  Widget build(BuildContext context) {
    ProductLine line;
    bool isSelected;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 300,
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: widget.lines.length,
            itemBuilder: (context, index) {
              line = widget.lines[index];

              if (line is ReturnLine) {
                return _ReturningLineCard(line: line as ReturnLine,);
              }
      
              isSelected = _selections.contains(index);

              return Card(
                elevation: 1,
                color: isSelected ? Colors.red : Color.fromRGBO(255, 248, 248, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: Colors.red
                  )
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  selected: isSelected,
                  title: Text(
                    line.product.name.toUpperCase(),
                    style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.w400),
                  ),
                  enabled: widget.canSelect && line is InvoiceLine,
                  trailing: Text(
                    line.quantity.toString(),
                    style: TextStyle(color: isSelected ? Colors.white : Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
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
          )
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 16, top: 8, right: 16),
          child: Text(
            widget.total.toString(),
            textAlign: TextAlign.end,
            style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16,
          children: [
            AppButton(
              label: "CONFIRMAR",
              onPressed: () {
                final state = Provider.of<AppState>(context, listen: false);

                state.advanceState();

                AppSnapshot.fromMemento(state).withData(Provider.of<ApiService>(context, listen: false)).saveSnapshot();

                Navigator.of(context).pushNamed("/resume");
              },
            ),
            if (widget.canSelect)
              AppButton(
                onPressed: _selections.isEmpty ? null : () {
                  // Selected lines will always be InvoiceLine
                  Provider.of<AppState>(context, listen: false).setReturnLines(_selections.map((s) => widget.lines[s] as InvoiceLine).toList());

                  setState(() {
                    _selections.clear();
                  });

                  Navigator.of(context).pushNamed("/return");
                },
                label: "DEVOLUCION"
              )
            ],
          )
      ],
    );
  }
}

class _InvoiceLineTable extends StatefulWidget {
  final List<ProductLine> lines;
  final double total;
  final bool canSelect;

  _InvoiceLineTable(this.lines, this.total, this.canSelect);

  @override
  State<StatefulWidget> createState() => _InvoiceLineTableState();
}

class InvoicePage extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      final state = Provider.of<AppState>(context);

      Invoice invoice = state.invoice!;
      final custom = invoice.customer;
      List<ProductLine> lines = [...invoice.lines, ...invoice.returns.values];

      const boldStyle = TextStyle(fontWeight: FontWeight.bold, color: Colors.black);
      final defaultStyle = TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w400);

      return AppScaffold(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              state.currentState == DeliveryState.approved 
                ? IconButton(
                  onPressed: () {
                    state.resetState();
                    Navigator.of(context).pushNamed("/search");
                  },
                  icon: const Icon(Icons.close, size: 48,)
                )
                : AppBackButton(),
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
                Align(
                  alignment: Alignment.topLeft,
                  child: Image(
                    image: AssetImage("assets/logo2.png"),
                    width: 128,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: SizedBox(
                    width: MediaQuery.sizeOf(context).width,
                    child: RichText(
                      text: TextSpan(
                        text: 'FECHA: ',
                        style: boldStyle,
                        children: <TextSpan>[
                          TextSpan(text: invoice.date.toString().split(' ')[0], style: defaultStyle),
                          TextSpan(text: "\nCLIENTE: ", style: boldStyle),
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
                  _InvoiceLineTable(
                    lines,
                    invoice.totalQuantity,
                    invoice.isApproved
                  )
              ],
            )
          )
        ]
      );
  }

}