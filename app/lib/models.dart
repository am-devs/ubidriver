import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

List<dynamic>? _recordToJson((double, double)? record) => record == null ? null : [record.$1, record.$2];
(double, double)? _recordFromJson(List<dynamic>? jsonList) => jsonList == null ? null : (jsonList[0] as double, jsonList[1] as double);

@JsonSerializable()
class Customer {
  final String name;
  @JsonKey(name: 'customer_id')
  final int customerId;
  final String address;
  final String vat;
  @JsonKey(toJson: _recordToJson, fromJson: _recordFromJson, includeIfNull: false)
  final (double, double)? coordinates;

  const Customer({
    required this.name,
    required this.customerId,
    required this.address,
    required this.vat,
    required this.coordinates
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
  @JsonKey(name: "line_id")
  final int lineId;
  final Product product;
  final double quantity;
  int get id => product.id;

  const ProductLine({
    required this.lineId,
    required this.product,
    required this.quantity
  });

  factory ProductLine.fromJson(Map<String, dynamic> json) => _$ProductLineFromJson(json);

  Map<String, dynamic> toJson() => _$ProductLineToJson(this);
}

@JsonSerializable(explicitToJson: true)
class InvoiceLine extends ProductLine {
  final String uom;

  const InvoiceLine({required this.uom, required super.lineId, required super.product, required super.quantity});

  factory InvoiceLine.fromJson(Map<String, dynamic> json) => _$InvoiceLineFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$InvoiceLineToJson(this);
}

@JsonSerializable()
class ReturnLine extends ProductLine {
  final DevolutionType reason;

  ReturnLine({required this.reason, required super.product, required super.lineId, required super.quantity});
  
  factory ReturnLine.fromJson(Map<String, dynamic> json) => _$ReturnLineFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ReturnLineToJson(this);
}

@JsonSerializable()
class ReturnStatus {
  final int id;
  @JsonKey(name: 'approval_status')
  final String approvalStatus;

  ReturnStatus({required this.id, required this.approvalStatus});

  factory ReturnStatus.fromJson(Map<String, dynamic> json) => _$ReturnStatusFromJson(json);

  Map<String, dynamic> toJson() => _$ReturnStatusToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Invoice {
  final String code;
  @JsonKey(name: 'date_invoice')
  final DateTime date;
  @JsonKey(name: 'invoice_id')
  final int id;
  @JsonKey(name: 'order_id')
  final int saleId;
  final String organization;
  final Customer customer;
  final List<InvoiceLine> _lines;
  @JsonKey(includeFromJson: false)
  Map<int, ReturnLine> returns = {};
  ReturnStatus? returnStatus;

  bool get isApproved => returnStatus == null ? true : returnStatus!.approvalStatus == "approved";

  List<InvoiceLine> get lines => _lines;

  double get totalQuantity {
    final double totalInvoice = _lines.map((p) => p.quantity).reduce((value, element) => value + element);

    if (returns.isEmpty) {
      return totalInvoice;
    }

    final double totalReturn = returns.values.map((p) => p.quantity).reduce((value, element) => value + element);

    return totalInvoice - totalReturn;
  }

  Invoice({
    required this.code,
    required this.date,
    required this.id,
    required this.organization,
    required this.customer,
    required this.saleId,
    this.returnStatus,
    List<InvoiceLine>? lines,
  }): _lines = lines ?? [];

  factory Invoice.fromJson(Map<String, dynamic> json) => _$InvoiceFromJson(json);

  Map<String, dynamic> toJson() => _$InvoiceToJson(this);

  void addLine(InvoiceLine line) => _lines.add(line);
}

@JsonSerializable()
class DevolutionType {
  final String name;
  @JsonKey(name: 'devolution_type_id')
  final int id;

  const DevolutionType(this.name, this.id);

  factory DevolutionType.fromJson(Map<String, dynamic> json) => _$DevolutionTypeFromJson(json);

  Map<String, dynamic> toJson() => _$DevolutionTypeToJson(this);
}