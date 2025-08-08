import 'package:driver_return/components.dart';
import 'package:driver_return/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gif/gif.dart';

class _GifSpeedControlScreen extends StatefulWidget {
  @override
  State createState() => _GifSpeedControlScreenState();
}

class _GifSpeedControlScreenState extends State<_GifSpeedControlScreen> with TickerProviderStateMixin {
  late final GifController _gifController;

  @override
  void initState() {
    super.initState();
    _gifController = GifController(vsync: this);
  }
  
  @override
  Widget build(BuildContext context) {
    return Gif(
      image: AssetImage('assets/ending.gif'),
      controller: _gifController,
      height: 400,
      width: 400,
      autostart: Autostart.once,
      placeholder: (context) => const Text('Loading...'),
    );
  }
}


class EndingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      children: [
        _GifSpeedControlScreen(),
        Expanded(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: "DESPACHO COMPLETADO",
              style: TextStyle(color: Colors.blueGrey, fontSize: 22, fontWeight: FontWeight.w500),
              children: [
                TextSpan(
                  text: "\n¡GRACIAS!",
                  style: TextStyle(color: Colors.red, fontSize: 22, fontWeight: FontWeight.w500)
                )
              ]
            )
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: ElevatedButton.icon(
            style: appButtonStyle,
            onPressed: () {
              Provider.of<AppState>(context, listen: false).advanceState();
              Navigator.of(context).pushNamed("/search");
            },
            icon: const Icon(
              Icons.keyboard_arrow_right,
              size: 32,
              color: Colors.white,
            ),
            label: const Text(
              "EMPEZAR DE NUEVO",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          )
        )
      ]
    );
  }

}