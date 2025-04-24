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
  final double quantity;
  final String uom;

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
  List<InvoiceLine> lines = [];

  Invoice({required this.code, required this.date, required this.id, required this.organization, required this.customer});

  Invoice.fromJson(Map<String, dynamic> json) 
    : code = json["code"] as String,
      date = DateTime.parse(json['date_invoice'] as String),
      id = json["invoice_id"] as int,
      organization = json["organization"] as String,
      customer = Customer(json["customer_name"] as String, json["customer_id"] as int),
      lines = (json["lines"] as List).map((str) => InvoiceLine.fromJson(str)).toList();
}