import '../entities/hotel_service_item.dart';

abstract class HotelServiceRepository {
  Future<List<HotelServiceItem>> getServices({String? category, String? search});
  Future<List<ServiceUsageOrder>> getServiceOrders({int? stayId});
  Future<ServiceUsageOrder> orderService({
    required int stayId,
    required String roomNumber,
    required HotelServiceItem service,
    required int quantity,
  });
}

