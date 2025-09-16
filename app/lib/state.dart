import 'dart:convert';
import 'dart:io';

import 'package:gdd/models.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

enum DeliveryState {
  searchingInvoice,
  editingInvoice,
  waitingForApproval,
  approved,
  confirmed,
}

abstract class Memento {
  void loadFromSnapshot(AppSnapshot snapshot);
  Map<String, dynamic> toJson();
}

class AppSnapshot {
  final Map<String, dynamic> data;

  AppSnapshot(this.data);

  AppSnapshot.fromMemento(Memento object) : data = object.toJson();

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;

    return File('$path/data.json');
  }

  AppSnapshot withData(Memento object) {
      data.addAll(object.toJson());

      return this;
  }

  Future<File?> saveSnapshot() async {
    try {

      print(data);

      final file = await _localFile;

      print("Guardando archivo...");

      return file.writeAsString(jsonEncode(data));
    } catch(e) {
      print(e);

      return null;
    }
  }

  static Future<File> clear() async {
    final file = await _localFile;

    print("Borrando archivo!");

    return file.writeAsString("");
  }

  static Future<AppSnapshot?> tryToLoad() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();
      final data =  jsonDecode(contents);

      print("Archivo cargado!");
      print(data);

      return AppSnapshot(data);
    } catch (e) {
      print("Error loading state: $e");

      return null;
    }
  }
}

class AppState extends ChangeNotifier implements Memento {
  final List<InvoiceLine> _returnLines = [];
  Invoice? _invoice;
  DeliveryState _status = DeliveryState.searchingInvoice;
  Map<int, DevolutionType> _devolutionTypes = {};

  Invoice? get invoice => _invoice;
  DeliveryState get currentState => _status;
  Map<int, DevolutionType> get devolutionTypes => _devolutionTypes;

  void setDevolutionTypes(List<dynamic> array) {
    for (var json in array) {
      final value = DevolutionType.fromJson(json);

      _devolutionTypes[value.id] = value;
    }

    notifyListeners();
  }

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

  @override
  void loadFromSnapshot(AppSnapshot snapshot) {
      if (snapshot.data.isEmpty) {
        return;
      }

      _invoice = snapshot.data["invoice"] != null ? Invoice.fromJson(snapshot.data["invoice"]) : null;
      _status = DeliveryState.values[snapshot.data["status"] ?? 0];

      print("Estado cargado exitosamente");
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
    print("Setting invoice!");
    print(inv.toJson());
    print(inv.lines.map((l) => l.toJson()));

    _invoice = inv;

    notifyListeners();
  }

  void clearInvoice() {
    _invoice = null;

    notifyListeners();
  }

  void setReturnStatus(ReturnStatus status) {
    _invoice!.returnStatus = status;

    notifyListeners();
  }

  void returnInvoice(Map<int, ReturnLine> lines) {
    _returnLines.clear();

    if (_invoice != null) {
      _invoice!.returns = lines;
    }

    notifyListeners();
  }

  @override
  Map<String, dynamic> toJson() => {
    "invoice": _invoice?.toJson(),
    "status": _status.index,
  };
}