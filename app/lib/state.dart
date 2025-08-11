import 'package:driver_return/models.dart';
import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

enum DeliveryState {
  searchingInvoice,
  editingInvoice,
  waitingForApproval,
  approved,
  confirmed,
}

class _InvoiceApproval {
  bool approved = false;
}

class AppState extends ChangeNotifier {
  final List<InvoiceLine> _returnLines = [];
  Invoice? _invoice;
  _InvoiceApproval? _approval;

  bool get isApproved => _approval == null || _approval?.approved == true;

  DeliveryState _status = DeliveryState.searchingInvoice;

  Invoice? get invoice => _invoice;
  DeliveryState get currentState => _status;

  void revertState() {
    _status = switch (_status) {
      DeliveryState.confirmed => DeliveryState.approved,
      DeliveryState.approved => DeliveryState.waitingForApproval,
      DeliveryState.waitingForApproval => DeliveryState.editingInvoice,
      _ => _status = DeliveryState.searchingInvoice
    };

    notifyListeners();
  }

  void advanceState() {
    // State is a loop
    _status = switch (_status) {
      DeliveryState.searchingInvoice => DeliveryState.editingInvoice,
      DeliveryState.editingInvoice => DeliveryState.waitingForApproval,
      DeliveryState.waitingForApproval => DeliveryState.approved,
      DeliveryState.approved => DeliveryState.confirmed,
      DeliveryState.confirmed => DeliveryState.searchingInvoice,
    };

    print("State $_status");

    notifyListeners();
  }

  void resetState() {
    _status = DeliveryState.searchingInvoice;
    _invoice = null;
    _returnLines.clear();

    notifyListeners();
  }

  void setReturnLines(List<InvoiceLine> lines) {
    _returnLines.clear();
    _returnLines.addAll(lines);

    notifyListeners();
  }

  Iterable<InvoiceLine> getReturnLines() sync * {
    for (var line in _returnLines) {
      yield line;
    }
  }

  void setInvoice(Invoice inv) {
    _invoice = inv;

    notifyListeners();
  }

  void clearInvoice() {
    _invoice = null;

    notifyListeners();
  }

  void returnInvoice(Map<int, ReturnLine> lines) {
    _returnLines.clear();

    if (_invoice != null) {
      _invoice!.returns = lines;
    }

    notifyListeners();
  }

  void setInvoiceApproval() {
    _approval = _InvoiceApproval();

    notifyListeners();
  }

  void approveInvoice() {
    _approval!.approved = true;

    notifyListeners();
  }
}