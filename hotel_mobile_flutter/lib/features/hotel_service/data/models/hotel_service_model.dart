import '../../domain/entities/hotel_service_item.dart';

class HotelServiceItemModel {
  final int id;
  final String serviceCode;
  final String name;
  final String category;
  final double price;
  final String unit;
  final String description;
  final bool isAvailable;
  final String rowVersion;

  HotelServiceItemModel({
    required this.id,
    this.serviceCode = '',
    required this.name,
    required this.category,
    required this.price,
    required this.unit,
    required this.description,
    this.isAvailable = true,
    this.rowVersion = '',
  });

  factory HotelServiceItemModel.fromJson(Map<String, dynamic> json) {
    return HotelServiceItemModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      serviceCode: (json['serviceCode'] ?? json['ServiceCode'] ?? '').toString(),
      name: (json['name'] ?? json['serviceName'] ?? 'Dịch vụ').toString(),
      category: (json['category'] ?? json['type'] ?? 'Dịch vụ').toString(),
      price: (json['currentPrice'] ?? json['price'] ?? json['unitPrice'] ?? 0).toDouble(),
      unit: (json['unit'] ?? 'Lượt').toString(),
      description: (json['description'] ?? '').toString(),
      isAvailable: json['isActive'] ?? json['isAvailable'] ?? true,
      rowVersion: (json['rowVersion'] ?? json['RowVersion'] ?? '').toString(),
    );
  }

  HotelServiceItem toEntity() => HotelServiceItem(
        id: id,
        serviceCode: serviceCode.isNotEmpty ? serviceCode : 'SRV-$id',
        name: name,
        category: category,
        price: price,
        unit: unit,
        description: description,
        isAvailable: isAvailable,
        rowVersion: rowVersion,
      );
}

class ServiceUsageOrderModel {
  final int id;
  final int stayId;
  final String roomNumber;
  final int serviceId;
  final String serviceName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final DateTime orderTime;
  final String status;

  ServiceUsageOrderModel({
    required this.id,
    required this.stayId,
    required this.roomNumber,
    required this.serviceId,
    required this.serviceName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.orderTime,
    required this.status,
  });

  factory ServiceUsageOrderModel.fromJson(Map<String, dynamic> json) {
    final qty = (json['quantity'] is num)
        ? (json['quantity'] as num).toInt()
        : int.tryParse(json['quantity']?.toString() ?? '1') ?? 1;
    final uPrice = (json['unitPrice'] is num)
        ? (json['unitPrice'] as num).toDouble()
        : double.tryParse(json['unitPrice']?.toString() ?? '0') ?? 0.0;
    final tPrice = (json['amount'] is num)
        ? (json['amount'] as num).toDouble()
        : (json['totalPrice'] is num)
            ? (json['totalPrice'] as num).toDouble()
            : uPrice * qty;

    return ServiceUsageOrderModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      stayId: json['stayId'] is int ? json['stayId'] : int.tryParse(json['stayId']?.toString() ?? '0') ?? 0,
      roomNumber: json['roomNumber'] ?? 'Stay #${json['stayId'] ?? ''}',
      serviceId: json['hotelServiceId'] ?? json['serviceId'] ?? 0,
      serviceName: json['serviceNameSnapshot'] ?? json['serviceName'] ?? 'Dịch vụ',
      quantity: qty,
      unitPrice: uPrice,
      totalPrice: tPrice,
      orderTime: DateTime.tryParse(json['usedAt']?.toString() ?? json['orderTime']?.toString() ?? '') ?? DateTime.now(),
      status: json['status'] ?? 'Đã ghi nhận',
    );
  }

  ServiceUsageOrder toEntity() => ServiceUsageOrder(
        id: id,
        stayId: stayId,
        roomNumber: roomNumber,
        serviceId: serviceId,
        serviceName: serviceName,
        quantity: quantity,
        unitPrice: unitPrice,
        totalPrice: totalPrice,
        orderTime: orderTime,
        status: status,
      );
}

