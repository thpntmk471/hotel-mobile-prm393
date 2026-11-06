class HotelServiceItem {
  final int id;
  final String name; // Ví dụ: Ăn sáng Buffet, Giặt ủi nhanh, Nước suối / Minibar, Dịch vụ Spa
  final String category; // F&B, Laundry, Spa, Transportation
  final double price;
  final String unit; // Suất, Lượt, Chai, Gói
  final String description;
  final bool isAvailable;

  const HotelServiceItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.unit,
    required this.description,
    this.isAvailable = true,
  });
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

