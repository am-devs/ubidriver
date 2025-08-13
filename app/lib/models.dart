import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

@JsonSerializable()
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

  factory Customer.fromJson(Map<String, dynamic> json) => _$CustomerFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerToJson(this);
}

@JsonSerializable()
class Product {
  final int id;
  final String name;

  const Product({required this.id, required this.name});

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

  Map<String, dynamic> toJson() => _$ProductToJson(this);
}

@JsonSerializable()
class ProductLine {
  final Product product;
  final double quantity;
  int get id => product.id;

  const ProductLine({required this.product, required this.quantity});

  factory ProductLine.fromJson(Map<String, dynamic> json) => _$ProductLineFromJson(json);

  Map<String, dynamic> toJson() => _$ProductLineToJson(this);
}

@JsonSerializable()
class InvoiceLine extends ProductLine {
  final String uom;

  const InvoiceLine({required this.uom, required super.product, required super.quantity});

  factory InvoiceLine.fromJson(Map<String, dynamic> json) => _$InvoiceLineFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$InvoiceLineToJson(this);
}

@JsonSerializable()
class ReturnLine extends ProductLine {
  final String reason;

  ReturnLine({required this.reason, required super.product, required super.quantity});
  
  factory ReturnLine.fromJson(Map<String, dynamic> json) => _$ReturnLineFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ReturnLineToJson(this);
}

@JsonSerializable()
class Invoice {
  static const int _limitQuantity = 30;

  final String code;
  final DateTime date;
  final int id;
  final String organization;
  final Customer customer;
  final List<InvoiceLine> _lines;
  Map<int, ReturnLine> returns = {};

  List<InvoiceLine> get lines => _lines;

  double get totalQuantity {
    final double totalInvoice = _lines.map((p) => p.quantity).reduce((value, element) => value + element);

    if (returns.isEmpty) {
      return totalInvoice;
    }

    final double totalReturn = returns.values.map((p) => p.quantity).reduce((value, element) => value + element);

    return totalInvoice - totalReturn;
  }

  bool get needsApproval => returns.isNotEmpty
    ? returns.values.map((value) => value.quantity).reduce((value, element) => value + element) > _limitQuantity
    : false;

  Invoice({
    required this.code,
    required this.date,
    required this.id,
    required this.organization,
    required this.customer,
    List<InvoiceLine>? lines,
  }): _lines = lines ?? [];

  factory Invoice.fromJson(Map<String, dynamic> json) => _$InvoiceFromJson(json);

  Map<String, dynamic> toJson() => _$InvoiceToJson(this);

  void addLine(InvoiceLine line) => _lines.add(line);
}