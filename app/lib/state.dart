import 'package:driver_return/models.dart';
import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class InvoiceMap extends ChangeNotifier {
  Map<int, Invoice> _invoices = {};

  int get size => _invoices.length;

  void initialize(Iterable<Invoice> list) {
    if(_invoices.isNotEmpty) {
      _invoices.clear();
    }

    for(var inv in list) {
      _invoices[inv.id] = inv;
    }
  }

  void add(Invoice inv) {
    _invoices[inv.id] = inv;
  }

  void remove(int id) {
    _invoices.remove(id);
  }

  void clear() {
    _invoices.clear();
  }

  Invoice? get(int id) {
    return _invoices[id];
  }

  List<Invoice> toList() {
    return _invoices.values.toList();
  }
}