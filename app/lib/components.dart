
import 'package:driver_return/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum _OperationStatus {
  incomplete,
  processing,
  waiting,
  complete
}

class _AppHeader extends StatelessWidget {
  const _AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    return Container(
      height: 128,
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))
      ),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStep("1", state.currentState == DeliveryState.searchingInvoice ? _OperationStatus.processing : _OperationStatus.complete),
            _buildConnector(),
            _buildStep("2", switch (state.currentState) {
              DeliveryState.searchingInvoice => _OperationStatus.incomplete,
              DeliveryState.editingInvoice => _OperationStatus.processing,
              DeliveryState.waitingForApproval => _OperationStatus.waiting,
              _ => _OperationStatus.complete,
            }),
            _buildConnector(),
            _buildStep("3", switch (state.currentState) {
              DeliveryState.confirmed => _OperationStatus.complete,
              DeliveryState.approved => _OperationStatus.processing,
              _ => _OperationStatus.incomplete
            }),
          ],
        ),
    );
  }

  // Función auxiliar para construir cada paso (círculo)
  Widget _buildStep(String text, _OperationStatus status) {
    Color color, backgroundColor;
    Widget child;

    switch (status) {
      case _OperationStatus.processing:
        backgroundColor = Colors.transparent;
        color = Colors.white;
        child = Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            color: color,
            fontWeight: FontWeight.bold
          )
        );
        break;
      case _OperationStatus.incomplete:
        backgroundColor = Colors.white;
        color = Colors.red;
        child = Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            color: color,
            fontWeight: FontWeight.bold
          )
        );
        break;
      case _OperationStatus.complete:
        backgroundColor = Colors.white;
        color = Colors.red;
        child = Icon(Icons.check, color: color);
        break;
      case _OperationStatus.waiting:
        backgroundColor = Colors.white;
        color = Colors.red;
        child = Icon(Icons.sync, color: color);
        break;
    }

    return Container(
      width: 32.0,
      height: 32.0,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(width: 2, color: color),
      ),
      child: child,
    );
  }

  // Función auxiliar para construir el conector (la línea entre los círculos)
  Widget _buildConnector() {
    return Expanded(
      child: Container(
        height: 2.0,
        color: Colors.white,
      ),
    );
  }
}

class AppScaffold extends StatelessWidget {
  final List<Widget> children;

  const AppScaffold({required this.children});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Column(
          children: [
            _AppHeader(),
            ...children,
          ],
        ),
      )
    );
  }

}