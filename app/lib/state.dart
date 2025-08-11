import 'dart:convert';
import 'dart:io';

import 'package:driver_return/models.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path_provider/path_provider.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

enum DeliveryState {
  searchingInvoice,
  editingInvoice,
  waitingForApproval,
  approved,
  confirmed,
}

@JsonSerializable()
class _InvoiceApproval {
  bool approved;

  _InvoiceApproval(this.approved);

  factory _InvoiceApproval.fromJson(Map<String, dynamic> json) => _InvoiceApproval(json["approved"]);

  Map<String, dynamic> toJson() => {
    "approved": approved
  };
}

class SnapShot {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;

    return File('$path/data.json');
  }

  static Future<File> saveSnapshot(String data) async {
    final file = await _localFile;

    return file.writeAsString(data);
  }

  static Future<Map<String, dynamic>> loadState() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();

      return jsonDecode(contents);
    } catch (e) {
      print("Error loading state: $e");

      return {};
    }
  }
}

@JsonSerializable()
class AppState extends ChangeNotifier {
  final List<InvoiceLine> _returnLines = [];
  Invoice? _invoice;
  _InvoiceApproval? _approval;
  DeliveryState _status = DeliveryState.searchingInvoice;

  bool get isApproved => _approval == null || _approval?.approved == true;
  Invoice? get invoice => _invoice;
  DeliveryState get currentState => _status;

  AppState();

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

    SnapShot.saveSnapshot(jsonEncode(toJson()));

    print("State $_status");

    notifyListeners();
  }

  void resetState() {
    _status = DeliveryState.searchingInvoice;
    _invoice = null;
    _returnLines.clear();

    SnapShot.saveSnapshot(jsonEncode(toJson()));

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
    _approval = _InvoiceApproval(false);

    notifyListeners();
  }

  void approveInvoice() {
    _approval!.approved = true;

    notifyListeners();
  }

  factory AppState.fromJson(Map<String, dynamic> json) {
    final instance = AppState();

    instance._invoice = Invoice.fromJson(json["invoice"]);
    instance._status = json["status"] as DeliveryState;
    instance._approval = _InvoiceApproval.fromJson(json["approval"]);

    return instance;
  }

  Map<String, dynamic> toJson() => {
    "invoice": _invoice?.toJson(),
    "status": _status.index,
    "approval": _approval?.toJson()
  };
}