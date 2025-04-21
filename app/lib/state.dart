import 'package:driver_return/models.dart';
import 'package:flutter/material.dart';

class InvoiceMap extends ChangeNotifier {
  Map<int, Invoice> _invoices = {};

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