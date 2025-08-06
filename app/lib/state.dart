import 'package:driver_return/models.dart';
import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class AppState extends ChangeNotifier {
  Invoice? _invoice;
  
  void setInvoice(Invoice inv) {
    _invoice = inv;

    notifyListeners();
  }

  void clearInvoice() {
    _invoice = null;

    notifyListeners();
  }

  Invoice? get invoice => _invoice;
}