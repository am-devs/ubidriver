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

class ProductLine {
  final Product product;
  final double quantity;
  int get id => product.id;

  const ProductLine({required this.product, required this.quantity});
}

class InvoiceLine extends ProductLine {
  final String uom;

  const InvoiceLine({required this.uom, required super.product, required super.quantity});
}

class ReturnLine extends ProductLine {
  final String reason;

  ReturnLine({required this.reason, required super.product, required super.quantity});
}

class Invoice {
  final String code;
  final DateTime date;
  final int id;
  final String organization;
  final Customer customer;
  bool confirm = false;
  List<InvoiceLine> lines = [];
  Map<int, ReturnLine> returns = {};

  double get totalQuantity {
    final double totalInvoice = lines.map((p) => p.quantity).reduce((value, element) => value + element);

    if (returns.isEmpty) {
      return totalInvoice;
    }

    final double totalReturn = returns.values.map((p) => p.quantity).reduce((value, element) => value + element);

    return totalInvoice - totalReturn;
  }

  Invoice({required this.code, required this.date, required this.id, required this.organization, required this.customer});
}