import 'dart:async';

import 'package:driver_return/components.dart';
import 'package:driver_return/models.dart';
import 'package:driver_return/services.dart';
import 'package:driver_return/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ApprovalPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ApprovalPageState();
}

class _ApprovalPageState extends State<ApprovalPage> {
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
 
    _pollingTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
        try {
          final state = Provider.of<AppState>(context, listen: false);
          final api = Provider.of<ApiService>(context, listen: false);

          final response = await api.get<Map<String, dynamic>>('/invoice/${state.invoice!.id}/return');

          final status = ReturnStatus.fromJson(response);
          
          if (status.approvalStatus != "waiting") {
            state.approveInvoice(status);
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

    return AppScaffold(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(
            "PENDIENTE POR CONFIRMAR",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 24, fontWeight: FontWeight.bold),
          )
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: AppInvoiceCard(
            invoice: state.invoice!,
            onTap: () {
              Navigator.of(context).pushNamed("/invoice");
            },
          ),
        )
      ]
    );
  }
}