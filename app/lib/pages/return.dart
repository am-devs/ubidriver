import 'dart:collection';
import 'package:driver_return/models.dart';
import 'package:driver_return/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReturnArguments {
  final int bpartnerId;
  final List<InvoiceLine> lines;

  ReturnArguments(this.bpartnerId, this.lines);
}

const List<String> reasons = ["Mercancia vencida", "Mercancía defectuosa"];

class ReturnLineData {
  final int productId;
  final String reason;
  final int quantity;
  
  const ReturnLineData(this.productId, this.reason, this.quantity);

  Map<String, dynamic> toMap() => {
    "reason": reason,
    "quantity": quantity,
    "product_id": productId
  };
}

class _ReturnLine extends StatefulWidget {
  final InvoiceLine _line;
  final Function(ReturnLineData) onDataChanged;
  
  _ReturnLine(this._line, {required this.onDataChanged});
  
  @override
  State<StatefulWidget> createState() => _ReturnLineState();  
}

class _ReturnLineState extends State<_ReturnLine> {
  static final List<DropdownMenuEntry<String>> menuEntries = UnmodifiableListView<DropdownMenuEntry<String>>(
    reasons.map<DropdownMenuEntry<String>>((name) => DropdownMenuEntry(value: name, label: name)),
  );
  String reason = reasons.first;
  int quantity = 0;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget._line.product.name),
                Text(widget._line.quantity.toString())
              ],
            ),
            DropdownMenu<String>(
              initialSelection: reasons.first,
              onSelected: (String? value) {
                setState(() {
                  reason = value!;
                  widget.onDataChanged(ReturnLineData(widget._line.id, reason, quantity));
                });
              },
              dropdownMenuEntries: menuEntries,
            ),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  quantity = int.tryParse(value) ?? 0;
                  widget.onDataChanged(ReturnLineData(widget._line.id, reason, quantity));
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
  final Map<int, ReturnLineData> _returnData = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Devolución")),
      body: ListView(
        children: widget.args.lines.map((l) => _ReturnLine(
          l,
          onDataChanged: (data) {
            setState(() {
              _returnData[data.productId] = data;
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

            print(result);

            if(context.mounted) {
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