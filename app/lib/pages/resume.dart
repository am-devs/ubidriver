import 'package:gdd/models.dart';
import 'package:gdd/components.dart';
import 'package:gdd/services.dart';
import 'package:gdd/state.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class ResumePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context, listen: false);
    
    final Invoice? invoice = state.invoice;

    if (invoice == null) {
      return Column(
        children: [
          const Text("No hay nada que mostrar")
        ],
      );
    }

    final Customer custom = invoice.customer;
    final isApproved = state.currentState == DeliveryState.approved;

    const boldStyle = TextStyle(fontWeight: FontWeight.bold, color: Colors.black);
    final defaultStyle = TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w400);
    const redStyle = TextStyle(fontWeight: FontWeight.bold, color: Colors.red);

    final returns = <TextSpan>[
      TextSpan(text: "\n\nTOTAL A DEVOLVER:\n", style: boldStyle),
      TextSpan(text: invoice.returnQuantity.toString(), style: redStyle),
    ];

    return AppScaffold(
      children: [
        if (!isApproved)
          Align(
            alignment: Alignment.topLeft,
            child: AppBackButton(),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Center(
            child: const Icon(
              Icons.check_circle_rounded,
              size: 96,
              color: Colors.green,
            ),
          )
        ),
        if (!isApproved)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: const Text(
              "VERIFIQUE SI LOS DATOS SON LOS CORRECTOS",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: RichText(
            text: TextSpan(
              text: 'Número de factura ',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 20),
              children: <TextSpan>[
                TextSpan(text: invoice.code, style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        SizedBox(
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height * 0.32,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: RichText(
              textAlign: TextAlign.justify,
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
                  TextSpan(text: custom.address.toUpperCase(), style: defaultStyle),
                  TextSpan(text: "\n\nTOTAL DE PRODUCTOS:\n", style: boldStyle),
                  TextSpan(text: invoice.lines.map((p)=> p.product.name).join(", ").toUpperCase(), style: redStyle,),
                  TextSpan(text: "\n\nTOTAL DE BULTOS:\n", style: boldStyle),
                  TextSpan(text: invoice.totalQuantity.toString(), style: redStyle),
                  if (invoice.returns.isNotEmpty)
                    ...returns
                ],
              ),
            )
          ),
        ),
        _AppConfirmButton(),
      ],
    );
  }
}

class _AppConfirmButton extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AppConfirmButtonState();
}

class _AppConfirmButtonState extends State<_AppConfirmButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    return AppButton(
      onPressed: _loading ? null : () async {
        // When loading
        if (state.currentState == DeliveryState.approved) {
          state.advanceState();
          state.clearInvoice();
          AppSnapshot.clear();
          Navigator.of(context).pushNamed("/ending");
          return;
        }

        final api = Provider.of<ApiService>(context, listen: false);

        setState(() {
          _loading = true;
        });

        Map<String, double>? body;

        try {
          Position coordinates = await getPosition();

          body = {
            "latitude": coordinates.latitude,
            "longitude": coordinates.longitude,
          };
        } catch(e) {
          print(e);
        }
        
        if (state.invoice!.returns.isNotEmpty && state.invoice!.returnStatus == null) {
          try {
            final json = await api.post<Map<String, dynamic>>(
              "/invoices/${state.invoice!.id}/return",
              body: {
                "lines": state.invoice!.returns.values.map((line) => {
                  "line_id": line.lineId,
                  "devolution_type_id": line.reason.id,
                  "quantity": line.quantity,
                }).toList(),
                "coordinates": body
              }
            );

            ReturnStatus status = ReturnStatus.fromJson(json);

            state.setReturnStatus(status);

            // Falta aprobacion
            if (context.mounted) {
              if (status.approvalStatus == "waiting") {
                AppSnapshot.fromMemento(state).withData(api).saveSnapshot();

                await api.post("/invoices/${state.invoice!.id}/confirm", body: body);

                Navigator.of(context).pushNamed("/approval");

                return;
              }
            }
          } catch(e) {
            print(e);

            if(context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Ocurrió un error: $e'),
              ));
            }

            setState(() {
              _loading = false;
            });

            return;
          } 
        }

        state.advanceState();

        // Finalize everything
        try {
          await api.post("/invoices/${state.invoice!.id}/confirm", body: body);

          if (state.currentState != DeliveryState.confirmed) {
            state.advanceState();
          }

          state.clearInvoice();
          AppSnapshot.clear();

          if (context.mounted) {
            Navigator.of(context).pushNamed("/ending");
          }
        } catch(e) {
          print(e);

          if(context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Ocurrió un error: $e'),
            ));
          }
        }

        setState(() {
          _loading = false;
        });
      },
      label: state.currentState == DeliveryState.approved ? "FINALIZAR" : "CONFIRMAR DESPACHO"
    );
  }

}