import 'package:driver_return/models.dart';
import 'package:driver_return/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Debug only
const List<String> selections = ["M-1", "M-2", "M-3"];

class _ProductStep extends StatelessWidget {
  final double maxQuantity;

  const _ProductStep(this.maxQuantity);

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          DropdownButtonFormField(
            hint: const Text("Motivo de devolución"),
            items: selections.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (value) {

            },
          ),
          TextFormField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Cantidad a devolver"),
            validator: (value) {
              if (value != null && double.parse(value) > maxQuantity) {
                return "La cantidad no puede superar a la original";
              }

              return null;
            },
          ),
          TextFormField(
            decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Número de lote"),
          ),
        ],
      ),
    );
  }

}

class _ReturnPageState extends State<ReturnPage>  {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    List<InvoiceLine> lines = Provider.of<AppState>(context).invoice!.lines;

    return Scaffold(
      body: Stepper(
        currentStep: _index,
        onStepCancel: () {
          if (_index > 0) {
            setState(() {
              _index -= 1;
            });
          }
        },
        onStepContinue: () {
          if (_index < lines.length) {
            setState(() {
              _index += 1;
            });
          } else {
            // Final
            Navigator.of(context).pop();
          }
        },
        onStepTapped: (int index) {
          setState(() {
            _index = index;
          });
        },
        steps: lines.map((l) => Step(
          title: Text(l.product.name), 
          content: _ProductStep(l.quantity)
        )).toList(),
      ),
    );
  }
}

class ReturnPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ReturnPageState();
}