class Customer {
  final String name;
  final int id;
  final String address;
  final String vat;

  const Customer({
    required this.name,
    required this.id,
    required this.address,
    required this.vat
  });
}

class Product {
  final int id;
  final String name;

  const Product({required this.id, required this.name});
}

class InvoiceLine {
  final int id;
  final Product product;
  final String uom;
  double quantity;

  InvoiceLine({required this.id, required this.product, required this.quantity, required this.uom});
}

class ReturnLine {
  final double quantity;
  final String lote;
  final String reason;

  const ReturnLine({required this.quantity, required this.lote, required this.reason});
}

class Invoice {
  final String code;
  final DateTime date;
  final int id;
  final String organization;
  final Customer customer;
  bool confirm = false;
  List<InvoiceLine> lines = [];

  double get totalQuantity => lines.map((p) => p.quantity).reduce((value, element) => value + element);

  Invoice({required this.code, required this.date, required this.id, required this.organization, required this.customer});

  void returnInvoice(Map<int, double> data) {
    for(var MapEntry(key: id, value: quantity) in data.entries) {
      lines[id]!.quantity -= quantity;
    }
  }
}