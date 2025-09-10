import 'package:driver_return/models.dart';
import 'package:driver_return/components.dart';
import 'package:driver_return/services.dart';
import 'package:driver_return/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class _ProductStep extends StatefulWidget {
  final double maxQuantity;
  final Function(String, double) onSave;
  final Key? stepKey;  // Cambiado de 'key' a 'stepKey' para evitar conflicto

  const _ProductStep(this.maxQuantity, this.onSave, {this.stepKey}) : super(key: stepKey);

  @override
  _ProductStepState createState() => _ProductStepState();
}

class _ProductStepState extends State<_ProductStep> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedReason;
  double? _quantity;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        spacing: 16,
        children: [
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: "Motivo de devolución",
              border: OutlineInputBorder()
            ),
            value: _selectedReason,
            isExpanded: true,
            items: Provider.of<AppState>(context).devolutionTypes.values.map<DropdownMenuItem<String>>((DevolutionType value) {
              return DropdownMenuItem<String>(value: value.id.toString(), child: Text(value.name));
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
                return "La cantidad no puede ser mayor que ${widget.maxQuantity}";
              }

              return null;
            },
            onSaved: (value) => _quantity = double.tryParse(value ?? '0'),
          ),
        ],
      ),
    );
  }

  bool saveForm() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      if (_selectedReason != null && _quantity != null) {
        widget.onSave(_selectedReason!, _quantity!);

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
  final List<GlobalKey<_ProductStepState>> _stepKeys = [];

  @override
  void initState() {
    super.initState(); 

    final state = Provider.of<AppState>(context, listen: false);

    _lines.addAll(state.getReturnLines());
    _stepKeys.addAll(List.generate(_lines.length, (index) => GlobalKey()));

    if (state.devolutionTypes.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchDevolutionTypes();
      });
    }
  }

  _fetchDevolutionTypes() async {
    final api = Provider.of<ApiService>(context, listen: false);

    final results = await api.get<List<dynamic>>("/devolution-types");

    if (mounted) {
      Provider.of<AppState>(context, listen: false).setDevolutionTypes(results);
    }
  }
      
  @override
  Widget build(BuildContext context) {
    final types = Provider.of<AppState>(context).devolutionTypes;

    return AppScaffold(
      children: [ 
        Stepper(
          connectorColor: WidgetStateProperty.all(Colors.red),
          connectorThickness: 2,
          currentStep: _index,
          controlsBuilder: (context, details) {
            return Padding(
              padding: EdgeInsets.only(top: 8),
              child: Row(
                spacing: 8,
                children: [
                  AppButton(
                    onPressed: details.onStepContinue,
                    label: "CONTINUAR",
                  ),
                  AppButton(
                    onPressed: details.onStepCancel,
                    backgroundColor: Colors.blue,
                    label: "CANCELAR"
                  )
                ],
              )
            );
          },
          onStepCancel: () {
            if (_index > 0) {
              setState(() {
                _index -= 1;
              });
            } else {
              Navigator.of(context).pop();
            }
          },
          onStepContinue: () async {
            // Validar y guardar el formulario actual
            if (_stepKeys[_index].currentState?.saveForm() ?? false) {
              if (_index < _lines.length - 1) {
                setState(() {
                  _index += 1;
                });

                return;
              } 

              final api = Provider.of<ApiService>(context, listen: false);
              final state = Provider.of<AppState>(context, listen: false);

              try {
                final json = await api.post<Map<String, dynamic>>(
                  "/invoices/${state.invoice!.id}/return",
                  body: {
                    "lines": _returnData.values.map((line) => {
                      "line_id": line.lineId,
                      "devolution_type_id": line.reason.id,
                      "quantity": line.quantity,
                    }).toList()
                  }
                );

                ReturnStatus status = ReturnStatus.fromJson(json);

                state.returnInvoice(_returnData, status);

                if (status.approvalStatus == "waiting") {
                  state.advanceState();
                  AppSnapshot.fromMemento(state).withData(api).saveSnapshot();

                  if (context.mounted) {
                    Navigator.of(context).pushNamed("/approval");
                  }
                } else {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                }
              } catch(e) {
                print(e);

                if(context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Ocurrió un error: $e'),
                  ));
                }
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
              stepStyle: StepStyle(
                color: Colors.red.shade800,
                indexStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
              ),
              content: Padding(
                padding: EdgeInsets.only(top: 8),
                child: _ProductStep(
                line.quantity,
                (reason, quantity) {
                  _returnData[_lines[index].product.id] = ReturnLine(
                    lineId: _lines[index].lineId,
                    product: _lines[index].product,
                    reason: types[int.parse(reason)]!,
                    quantity: quantity,
                  );
                },
                stepKey: _stepKeys[index],
              ),
              )
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