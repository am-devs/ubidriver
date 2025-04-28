import 'dart:collection';
import 'package:driver_return/models.dart';
import 'package:driver_return/services.dart';
import 'package:driver_return/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReturnArguments {
  final int invoiceId;
  final int bpartnerId;
  final List<InvoiceLine> lines;

  ReturnArguments({required this.bpartnerId, required this.lines, required this.invoiceId});
}

const List<String> reasons = ["Mercancia vencida", "Mercancía defectuosa"];

class _ReturnLineData {
  final int lineId;
  final int productId;
  final String reason;
  final double quantity;
  
  const _ReturnLineData(this.lineId, this.productId, this.reason, this.quantity);

  Map<String, dynamic> toMap() {
    return {
      "reason": reason,
      "quantity": quantity,
      "product_id": productId
    };
  }
}

class _ReturnLine extends StatefulWidget {
  final InvoiceLine _line;
  final Function(_ReturnLineData) onDataChanged;
  
  _ReturnLine(this._line, {required this.onDataChanged});
  
  @override
  State<StatefulWidget> createState() => _ReturnLineState();  
}

class _ReturnLineState extends State<_ReturnLine> {
  static final List<DropdownMenuEntry<String>> menuEntries = UnmodifiableListView<DropdownMenuEntry<String>>(
    reasons.map<DropdownMenuEntry<String>>((name) => DropdownMenuEntry(value: name, label: name)),
  );
  String reason = reasons.first;
  double quantity = 0;
  
  @override
  Widget build(BuildContext context) {
    var line = widget._line;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(line.product.name),
                Text(line.quantity.toString())
              ],
            ),
            DropdownMenu<String>(
              initialSelection: reasons.first,
              onSelected: (String? value) {
                setState(() {
                  reason = value!;
                  widget.onDataChanged(_ReturnLineData(line.id, line.product.id, reason, quantity));
                });
              },
              dropdownMenuEntries: menuEntries,
            ),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  quantity = double.tryParse(value) ?? 0;
                  widget.onDataChanged(_ReturnLineData(line.id, line.product.id, reason, quantity));
                });
              },
            )
          ]
        ),
      )
    );
  }
}

class ReturnPage extends StatefulWidget {
  final ReturnArguments args;

  ReturnPage(this.args);
  
  @override
  State<ReturnPage> createState() => _ReturnPageState();
}

class _ReturnPageState extends State<ReturnPage> {
  final Map<int, _ReturnLineData> _returnData = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Devolución")),
      body: ListView(
        children: widget.args.lines.map((l) => _ReturnLine(
          l,
          onDataChanged: (data) {
            setState(() {
              _returnData[data.lineId] = data;
            });
          },
        )).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final service = Provider.of<ApiService>(context, listen: false);
          
          try {
            final result = await service.post<Map<String, dynamic>>("return", body: {
              "c_bpartner_id": widget.args.bpartnerId
            }).then((value) => service.post<Map<String, dynamic>>(
              "return/${value["record_id"]}/lines", body: _returnData.values.map((l) => l.toMap()).toList()
            ));

            if(result.isNotEmpty && context.mounted) {
              Provider.of<InvoiceMap>(context, listen: false).get(widget.args.invoiceId)?.returnInvoice({ 
                for (var line in _returnData.values)
                  line.lineId: line.quantity
              });
              Navigator.of(context).pushNamed("/home");
            }
          } catch (e) {
            print(e);
          }
        },
        child: Icon(Icons.save),
      ),
    );
  }
}