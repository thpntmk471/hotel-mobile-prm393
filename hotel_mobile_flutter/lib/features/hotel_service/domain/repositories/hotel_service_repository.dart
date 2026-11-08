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
  Future<HotelServiceItem> createService({
    required String serviceCode,
    required String name,
    required String unit,
    required double price,
    String? description,
    bool isActive = true,
  });
  Future<HotelServiceItem> updateService({
    required int id,
    required String serviceCode,
    required String name,
    required String unit,
    required double price,
    required String rowVersion,
    String? description,
    bool isActive = true,
  });
  Future<HotelServiceItem> updateStatus({
    required int id,
    required bool isActive,
    required String rowVersion,
  });
}

