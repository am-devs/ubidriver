import 'dart:async';

import 'package:gdd/components.dart';
import 'package:gdd/models.dart';
import 'package:gdd/services.dart';
import 'package:gdd/state.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class ApprovalPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ApprovalPageState();
}

const int _pollingTime = 10;

class _ApprovalPageState extends State<ApprovalPage> {
  Timer? _pollingTimer;
  bool _isLoading = false;
  bool _approved = false;

  @override
  void initState() {
    super.initState();

    _pollingTimer = Timer.periodic(Duration(seconds: _pollingTime), (timer) async {
        try {
          final state = Provider.of<AppState>(context, listen: false);
          final api = Provider.of<ApiService>(context, listen: false);

          final response = await api.get<Map<String, dynamic>>('/invoices/${state.invoice!.id}/return');

          final status = ReturnStatus.fromJson(response);

          if (status.approvalStatus != "waiting") {
            state.setReturnStatus(status);
            state.advanceState();
            AppSnapshot.fromMemento(state).withData(api).saveSnapshot();

            setState(() {
              _approved = true;
            });

            timer.cancel();
            
          }
        } catch (error) {
          print('Error en polling: $error');
        }
      });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AppState>(context);

    if (state.invoice == null) {
      return AppScaffold(
        children: [
          Center(child: CircularProgressIndicator(),)
        ]
      );
    }

    return AppScaffold(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(
            !_approved ? "PENDIENTE POR CONFIRMAR" : "CONFIRMADA",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 24, fontWeight: FontWeight.bold),
          )
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: AppInvoiceCard(
            invoice: state.invoice!,
            onTap: _isLoading ? null : () {
            
              // Finalize everything
              try {
                setState(() {
                  _isLoading = true;
                });

                state.advanceState();
                state.clearInvoice();
                AppSnapshot.clear();

                Navigator.of(context).pushNamed("/ending");
              } catch(e) {
                print(e);

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Ocurrió un error: $e'),
                ));
              } finally {
                setState(() {
                  _isLoading = false;
                });
              }
            },
          ),
        )
      ]
    );
  }
}