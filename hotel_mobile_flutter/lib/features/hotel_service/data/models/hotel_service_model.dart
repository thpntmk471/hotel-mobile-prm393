import '../../domain/entities/hotel_service_item.dart';

class HotelServiceItemModel {
  final int id;
  final String name;
  final String category;
  final double price;
  final String unit;
  final String description;
  final bool isAvailable;

  HotelServiceItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.unit,
    required this.description,
    this.isAvailable = true,
  });

  factory HotelServiceItemModel.fromJson(Map<String, dynamic> json) {
    return HotelServiceItemModel(
      id: json['id'] ?? 1,
      name: json['name'] ?? json['serviceName'] ?? 'Dịch vụ',
      category: json['category'] ?? json['type'] ?? 'F&B',
      price: (json['price'] ?? json['unitPrice'] ?? 50000).toDouble(),
      unit: json['unit'] ?? 'Lượt',
      description: json['description'] ?? 'Mô tả dịch vụ khách sạn',
      isAvailable: json['isAvailable'] ?? json['isActive'] ?? true,
    );
  }

  HotelServiceItem toEntity() => HotelServiceItem(
        id: id,
        name: name,
        category: category,
        price: price,
        unit: unit,
        description: description,
        isAvailable: isAvailable,
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
    return ServiceUsageOrderModel(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch % 10000,
      stayId: json['stayId'] ?? 1,
      roomNumber: json['roomNumber'] ?? 'DEV-101',
      serviceId: json['serviceId'] ?? 1,
      serviceName: json['serviceName'] ?? 'Ăn sáng Buffet',
      quantity: json['quantity'] ?? 1,
      unitPrice: (json['unitPrice'] ?? 60000).toDouble(),
      totalPrice: (json['totalPrice'] ?? 60000).toDouble(),
      orderTime: DateTime.tryParse(json['orderTime'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? 'Đang giao',
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

