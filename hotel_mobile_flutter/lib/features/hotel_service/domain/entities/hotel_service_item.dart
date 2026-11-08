class HotelServiceItem {
  final int id;
  final String serviceCode;
  final String name; // Ví dụ: Ăn sáng Buffet, Giặt ủi nhanh, Nước suối / Minibar, Dịch vụ Spa
  final String category; // F&B, Laundry, Spa, Transportation
  final double price;
  final String unit; // Suất, Lượt, Chai, Gói
  final String description;
  final bool isAvailable;
  final String rowVersion;

  const HotelServiceItem({
    required this.id,
    this.serviceCode = '',
    required this.name,
    this.category = 'Dịch vụ',
    required this.price,
    required this.unit,
    required this.description,
    this.isAvailable = true,
    this.rowVersion = '',
  });

  HotelServiceItem copyWith({
    int? id,
    String? serviceCode,
    String? name,
    String? category,
    double? price,
    String? unit,
    String? description,
    bool? isAvailable,
    String? rowVersion,
  }) {
    return HotelServiceItem(
      id: id ?? this.id,
      serviceCode: serviceCode ?? this.serviceCode,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      description: description ?? this.description,
      isAvailable: isAvailable ?? this.isAvailable,
      rowVersion: rowVersion ?? this.rowVersion,
    );
  }
}

class ServiceUsageOrder {
  final int id;
  final int stayId;
  final String roomNumber;
  final int serviceId;
  final String serviceName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final DateTime orderTime;
  final String status; // Pending (Đang giao), Completed (Đã phục vụ)

  const ServiceUsageOrder({
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
}

