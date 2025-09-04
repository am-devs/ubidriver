// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Customer _$CustomerFromJson(Map<String, dynamic> json) => Customer(
  name: json['name'] as String,
  customerId: (json['customer_id'] as num).toInt(),
  address: json['address'] as String,
  vat: json['vat'] as String,
  coordinates: _$recordConvertNullable(
    json['coordinates'],
    ($jsonValue) => (
      ($jsonValue[r'$1'] as num).toDouble(),
      ($jsonValue[r'$2'] as num).toDouble(),
    ),
  ),
);

Map<String, dynamic> _$CustomerToJson(Customer instance) => <String, dynamic>{
  'name': instance.name,
  'customer_id': instance.customerId,
  'address': instance.address,
  'vat': instance.vat,
  'coordinates':
      instance.coordinates == null
          ? null
          : <String, dynamic>{
            r'$1': instance.coordinates!.$1,
            r'$2': instance.coordinates!.$2,
          },
};

$Rec? _$recordConvertNullable<$Rec>(
  Object? value,
  $Rec Function(Map) convert,
) => value == null ? null : convert(value as Map<String, dynamic>);

Product _$ProductFromJson(Map<String, dynamic> json) =>
    Product(id: (json['id'] as num).toInt(), name: json['name'] as String);

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
};

ProductLine _$ProductLineFromJson(Map<String, dynamic> json) => ProductLine(
  product: Product.fromJson(json['product'] as Map<String, dynamic>),
  quantity: (json['quantity'] as num).toDouble(),
);

Map<String, dynamic> _$ProductLineToJson(ProductLine instance) =>
    <String, dynamic>{
      'product': instance.product,
      'quantity': instance.quantity,
    };

InvoiceLine _$InvoiceLineFromJson(Map<String, dynamic> json) => InvoiceLine(
  uom: json['uom'] as String,
  product: Product.fromJson(json['product'] as Map<String, dynamic>),
  quantity: (json['quantity'] as num).toDouble(),
);

Map<String, dynamic> _$InvoiceLineToJson(InvoiceLine instance) =>
    <String, dynamic>{
      'product': instance.product,
      'quantity': instance.quantity,
      'uom': instance.uom,
    };

ReturnLine _$ReturnLineFromJson(Map<String, dynamic> json) => ReturnLine(
  reason: DevolutionType.fromJson(json['reason'] as Map<String, dynamic>),
  product: Product.fromJson(json['product'] as Map<String, dynamic>),
  quantity: (json['quantity'] as num).toDouble(),
);

Map<String, dynamic> _$ReturnLineToJson(ReturnLine instance) =>
    <String, dynamic>{
      'product': instance.product,
      'quantity': instance.quantity,
      'reason': instance.reason,
    };

Invoice _$InvoiceFromJson(Map<String, dynamic> json) => Invoice(
  code: json['code'] as String,
  date: DateTime.parse(json['date_invoice'] as String),
  id: (json['invoice_id'] as num).toInt(),
  organization: json['organization'] as String,
  customer: Customer.fromJson(json['customer'] as Map<String, dynamic>),
  saleId: (json['order_id'] as num).toInt(),
  lines:
      (json['lines'] as List<dynamic>?)
          ?.map((e) => InvoiceLine.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$InvoiceToJson(Invoice instance) => <String, dynamic>{
  'code': instance.code,
  'date_invoice': instance.date.toIso8601String(),
  'invoice_id': instance.id,
  'order_id': instance.saleId,
  'organization': instance.organization,
  'customer': instance.customer,
  'lines': instance.lines,
};

DevolutionType _$DevolutionTypeFromJson(Map<String, dynamic> json) =>
    DevolutionType(
      json['name'] as String,
      (json['devolution_type_id'] as num).toInt(),
    );

Map<String, dynamic> _$DevolutionTypeToJson(DevolutionType instance) =>
    <String, dynamic>{'name': instance.name, 'devolution_type_id': instance.id};
