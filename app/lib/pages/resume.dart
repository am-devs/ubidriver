import 'package:driver_return/models.dart';
import 'package:driver_return/components.dart';
import 'package:driver_return/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ResumePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Invoice? invoice = Provider.of<AppState>(context, listen: false).invoice;

    if (invoice == null) {
      return Column(
        children: [
          const Text("No hay nada que mostrar")
        ],
      );
    }

    Customer custom = invoice.customer;

    const boldStyle = TextStyle(fontWeight: FontWeight.bold);
    final defaultStyle = DefaultTextStyle.of(context).style;

    return AppScaffold(
      children: [
        Center(child: const Icon(Icons.check_circle_rounded, size: 20,),),
        const Text(
          "VERIFIQUE SI LOS DATOS SON LOS CORRECTOS",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24),
        ),
        RichText(
          text: TextSpan(
            text: 'Número de factura',
            children: <TextSpan>[
              TextSpan(text: invoice.code, style: defaultStyle),
            ],
          ),
        ),
        RichText(
          text: TextSpan(
            text: 'CLIENTE',
            style: boldStyle,
            children: <TextSpan>[
              TextSpan(text: custom.name, style: defaultStyle),
              TextSpan(text: "\nRIF", style: boldStyle),
              TextSpan(text: custom.vat, style: defaultStyle),
              TextSpan(text: "\nDIRECCION", style: boldStyle),
              TextSpan(text: custom.address, style: defaultStyle),
              TextSpan(text: "\nTOTAL DE PRODUCTOS", style: boldStyle),
              TextSpan(text: invoice.lines.map((p)=> p.product.name).join(", "), style: defaultStyle),
              TextSpan(text: "\nTOTAL DE BULTOS", style: boldStyle),
              TextSpan(text: invoice.totalQuantity.toString(), style: defaultStyle),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Provider.of<AppState>(context, listen: false).advanceState();
            Navigator.of(context).pushNamed("/ending");
          },
          child: const Text("CONFIRMAR DESPACHO")
        )
      ],
    );
  }
}