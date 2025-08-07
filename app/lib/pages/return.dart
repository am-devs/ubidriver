import 'package:driver_return/models.dart';
import 'package:driver_return/components.dart';
import 'package:driver_return/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Debug only
const List<String> selections = ["M-1", "M-2", "M-3"];

class _ProductStep extends StatefulWidget {
  final double maxQuantity;
  final Function(String, double, String) onSave;
  final Key? stepKey;  // Cambiado de 'key' a 'stepKey' para evitar conflicto

  const _ProductStep(this.maxQuantity, this.onSave, {this.stepKey}) : super(key: stepKey);

  @override
  __ProductStepState createState() => __ProductStepState();
}

class __ProductStepState extends State<_ProductStep> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedReason;
  double? _quantity;
  String _batchNumber = '';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            hint: const Text("Motivo de devolución"),
            value: _selectedReason,
            items: selections.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedReason = value;
              });
            },
            validator: (value) => value == null ? 'Seleccione un motivo' : null,
          ),
          TextFormField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Cantidad a devolver",
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingrese una cantidad';
              }
              final qty = double.tryParse(value);
              if (qty == null) {
                return 'Ingrese un número válido';
              }
              if (qty > widget.maxQuantity) {
                return "La cantidad no puede superar a la original";
              }
              return null;
            },
            onSaved: (value) => _quantity = double.tryParse(value ?? '0'),
          ),
          TextFormField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Número de lote",
            ),
            validator: (value) => value?.isEmpty ?? true ? 'Ingrese el lote' : null,
            onSaved: (value) => _batchNumber = value ?? '',
          ),
        ],
      ),
    );
  }

  bool saveForm() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      if (_selectedReason != null && _quantity != null) {
        widget.onSave(_selectedReason!, _quantity!, _batchNumber);

        return true;
      }
    }

    return false;
  }
}

class _ReturnPageState extends State<ReturnPage> {
  int _index = 0;
  final List<InvoiceLine> _lines = [];
  final Map<int, ReturnLine> _returnData = {};
  final List<GlobalKey<__ProductStepState>> _stepKeys = [];

  @override
  void initState() {
    super.initState();

    _lines.addAll(Provider.of<AppState>(context, listen: false).getReturnLines());
    _stepKeys.addAll(List.generate(_lines.length, (index) => GlobalKey()));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      children: [ 
        Stepper(
          currentStep: _index,
          onStepCancel: () {
            if (_index > 0) {
              setState(() {
                _index -= 1;
              });
            } else {
              Navigator.of(context).pop();
            }
          },
          onStepContinue: () {
            // Validar y guardar el formulario actual
            if (_stepKeys[_index].currentState?.saveForm() ?? false) {
              if (_index < _lines.length - 1) {
                setState(() {
                  _index += 1;
                });
              } else {
                Provider.of<AppState>(context, listen: false).returnInvoice(_returnData);
                Navigator.of(context).pop();
              }
            }
          },
          onStepTapped: (int index) {
            setState(() {
              _index = index;
            });
          },
          steps: _lines.asMap().entries.map((entry) {
            final index = entry.key;
            final line = entry.value;
            
            return Step(
              title: Text(line.product.name),
              content: _ProductStep(
                line.quantity,
                (reason, quantity, batchNumber) {
                  _returnData[_lines[index].product.id] = ReturnLine(
                    product: _lines[index].product,
                    reason: reason,
                    quantity: quantity,
                    lote: batchNumber
                  );
                },
                stepKey: _stepKeys[index],
              ),
            );
          }).toList(),
        ),
      ]
    );
  }
}

class ReturnPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ReturnPageState();
}