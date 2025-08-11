import 'package:driver_return/components.dart';
import 'package:driver_return/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ApprovalPage extends StatelessWidget {
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
            isApproved: state.isApproved,
            onTap: () {
              Navigator.of(context).pushNamed("/invoice");
            },
          ),
        )
      ]
    );
  }
}
