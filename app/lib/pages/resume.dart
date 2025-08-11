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

    const boldStyle = TextStyle(fontWeight: FontWeight.bold, color: Colors.black);
    final defaultStyle = TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w400);
    const redStyle = TextStyle(fontWeight: FontWeight.bold, color: Colors.red);

    return AppScaffold(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: AppBackButton(),
        ),
        Center(
          child: const Icon(
            Icons.check_circle_rounded,
            size: 128,
            color: Colors.green,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: const Text(
            "VERIFIQUE SI LOS DATOS SON LOS CORRECTOS",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: RichText(
            text: TextSpan(
              text: 'Número de factura ',
              style: TextStyle(color: Colors.grey.shade400, fontSize:24),
              children: <TextSpan>[
                TextSpan(text: invoice.code, style: TextStyle(color: Colors.red, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        SizedBox(
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height * 0.35,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: RichText(
              text: TextSpan(
                text: 'CLIENTE: ',
                style: boldStyle,
                children: <TextSpan>[
                  TextSpan(text: custom.name.toUpperCase(), style: defaultStyle),
                  TextSpan(text: "\nRIF: ", style: boldStyle),
                  TextSpan(text: custom.vat.toUpperCase(), style: defaultStyle),
                  TextSpan(text: "\nDIRECCION: ", style: boldStyle),
                  TextSpan(text: custom.address.toUpperCase(), style: defaultStyle),
                  TextSpan(text: "\n\nTOTAL DE PRODUCTOS:\n", style: boldStyle),
                  TextSpan(text: invoice.lines.map((p)=> p.product.name).join(", ").toUpperCase(), style: redStyle),
                  TextSpan(text: "\n\nTOTAL DE BULTOS:\n", style: boldStyle),
                  TextSpan(text: invoice.totalQuantity.toString(), style: redStyle),
                ],
              ),
            )
          ),
        ),
        AppButton(
          onPressed: () {
            Provider.of<AppState>(context, listen: false).advanceState();
            Navigator.of(context).pushNamed("/ending");
          },
          label: "CONFIRMAR DESPACHO"
        )
      ],
    );
  }
}