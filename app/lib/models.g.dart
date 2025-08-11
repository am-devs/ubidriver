// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Customer _$CustomerFromJson(Map<String, dynamic> json) => Customer(
  name: json['name'] as String,
  id: (json['id'] as num).toInt(),
  address: json['address'] as String,
  vat: json['vat'] as String,
);

Map<String, dynamic> _$CustomerToJson(Customer instance) => <String, dynamic>{
  'name': instance.name,
  'id': instance.id,
  'address': instance.address,
  'vat': instance.vat,
};

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
  reason: json['reason'] as String,
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
    date: DateTime.parse(json['date'] as String),
    id: (json['id'] as num).toInt(),
    organization: json['organization'] as String,
    customer: Customer.fromJson(json['customer'] as Map<String, dynamic>),
  )
  ..returns = (json['returns'] as Map<String, dynamic>).map(
    (k, e) =>
        MapEntry(int.parse(k), ReturnLine.fromJson(e as Map<String, dynamic>)),
  );

Map<String, dynamic> _$InvoiceToJson(Invoice instance) => <String, dynamic>{
  'code': instance.code,
  'date': instance.date.toIso8601String(),
  'id': instance.id,
  'organization': instance.organization,
  'customer': instance.customer,
  'returns': instance.returns.map((k, e) => MapEntry(k.toString(), e)),
};
