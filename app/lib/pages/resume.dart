import 'dart:math';

import 'package:driver_return/models.dart';
import 'package:driver_return/components.dart';
import 'package:driver_return/services.dart';
import 'package:driver_return/state.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

const int _SafeDistance = 3;

double _calcularDistenciaHaversine((double, double) coord1, (double, double) coord2) {
  final (lat1, lon1) = coord1;
  final (lat2, lon2) = coord2;
  
  const double radioTierraKm = 6371.0;
  
  double gradosARadianes(double grados) => grados * pi / 180.0;
  
  final double lat1Rad = gradosARadianes(lat1);
  final double lon1Rad = gradosARadianes(lon1);
  final double lat2Rad = gradosARadianes(lat2);
  final double lon2Rad = gradosARadianes(lon2);
  
  final double dLat = lat2Rad - lat1Rad;
  final double dLon = lon2Rad - lon1Rad;
  
  final double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1Rad) * cos(lat2Rad) * sin(dLon / 2) * sin(dLon / 2);
  
  final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  
  return radioTierraKm * c;
}

class ResumePage extends StatelessWidget {
  Future<Position> _getPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the 
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale 
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately. 
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
    } 

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
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
        if (custom.coordinates != null)
          FutureBuilder(
            future: _getPosition(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final distance = _calcularDistenciaHaversine(
                  (snapshot.data!.latitude, snapshot.data!.longitude),
                  custom.coordinates!,
                );

                if (distance <= _SafeDistance) {
                  return Text("Estás a punto de confirmar una factura sin estar cerca del destino");
                }
              }

              return Container();
            },
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
                  TextSpan(text: invoice.lines.map((p)=> p.product.name).join(", ").toUpperCase(), style: redStyle),
                  TextSpan(text: "\n\nTOTAL DE BULTOS:\n", style: boldStyle),
                  TextSpan(text: invoice.totalQuantity.toString(), style: redStyle),
                ],
              ),
            )
          ),
        ),
        AppButton(
          onPressed: () async { 
            final api = Provider.of<ApiService>(context, listen: false);

            try {
              await api.post("/invoices/${invoice.id}/confirm");

              if (context.mounted) {
                final state = Provider.of<AppState>(context, listen: false);
                
                state.clearInvoice();
                state.advanceState();

                if (state.currentState == DeliveryState.approved) {
                  state.advanceState();
                }

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
          },
          label: "CONFIRMAR DESPACHO"
        )
      ],
    );
  }
}