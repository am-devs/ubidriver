class Customer {
  final String name;
  final int id;

  Customer(this.name, this.id);
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

  InvoiceLine.fromJson(Map<String, dynamic> json)
    : product = Product(id: json["product"]["id"], name: json["product"]["name"] as String),
      quantity = json["quantity"] as double,
      uom = json["uom"] as String,
      id = json["line_id"] as int;
}

class Invoice {
  final String code;
  final DateTime date;
  final int id;
  final String organization;
  final Customer customer;
  bool confirm = false;
  Map<int, InvoiceLine> lines = {};

  Invoice({required this.code, required this.date, required this.id, required this.organization, required this.customer});

  factory Invoice.fromJson(Map<String, dynamic> json) {
    var instance = Invoice(
      code: json["code"] as String,
      date: DateTime.parse(json['date_invoice'] as String),
      id: json["invoice_id"] as int,
      organization: json["organization"] as String,
      customer: Customer(json["customer_name"] as String, json["customer_id"] as int),
    );

    for(var data in (json["lines"] as List)) {
      var line = InvoiceLine.fromJson(data);

      instance.lines[line.id] = line;
    }

    return instance;
  }

  void returnInvoice(Map<int, double> data) {
    for(var MapEntry(key: id, value: quantity) in data.entries) {
      lines[id]!.quantity -= quantity;
    }
  }
}