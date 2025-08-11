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
  static const int _limitQuantity = 30;

  final String code;
  final DateTime date;
  final int id;
  final String organization;
  final Customer customer;
  final List<InvoiceLine> lines = [];
  Map<int, ReturnLine> returns = {};

  double get totalQuantity {
    final double totalInvoice = lines.map((p) => p.quantity).reduce((value, element) => value + element);

    if (returns.isEmpty) {
      return totalInvoice;
    }

    final double totalReturn = returns.values.map((p) => p.quantity).reduce((value, element) => value + element);

    return totalInvoice - totalReturn;
  }

  bool get needsApproval => returns.isNotEmpty
    ? returns.values.map((value) => value.quantity).reduce((value, element) => value + element) > _limitQuantity
    : false;

  Invoice({required this.code, required this.date, required this.id, required this.organization, required this.customer});
}