import 'package:driver_return/components.dart';
import 'package:driver_return/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EndingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      children: [
        const Icon(
          Icons.local_shipping,
          size: 128,
          color: Colors.blueGrey,
        ),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: "DESPACHO COMPLETADO",
            style: TextStyle(color: Colors.blueGrey),
            children: [
              TextSpan(
                text: "\nGRACIAS!",
                style: TextStyle(color: Colors.red)
              )
            ]
          )
        ),
        ElevatedButton.icon(
          onPressed: () {
            Provider.of<AppState>(context, listen: false).advanceState();
            Navigator.of(context).pushNamed("/search");
          },
          icon: const Icon(
            Icons.keyboard_arrow_right,
            size: 48,
          ),
          label: const Text("EMPEZAR DE NUEVO"),
        )
      ]
    );
  }

}