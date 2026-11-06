import '../../domain/entities/hotel_service_item.dart';
import '../../domain/repositories/hotel_service_repository.dart';
import '../datasources/hotel_service_remote_datasource.dart';

class HotelServiceRepositoryImpl implements HotelServiceRepository {
  final HotelServiceRemoteDataSource remoteDataSource;

  HotelServiceRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<HotelServiceItem>> getServices({String? category, String? search}) async {
    final models = await remoteDataSource.fetchServices();
    var list = models.map((m) => m.toEntity()).toList();

    if (category != null && category != 'Tất cả') {
      list = list.where((s) => s.category == category).toList();
    }
    if (search != null && search.isNotEmpty) {
      final s = search.toLowerCase();
      list = list.where((item) =>
          item.name.toLowerCase().contains(s) ||
          item.description.toLowerCase().contains(s)).toList();
    }
    return list;
  }

  @override
  Future<List<ServiceUsageOrder>> getServiceOrders({int? stayId}) async {
    final models = await remoteDataSource.fetchOrders();
    var list = models.map((m) => m.toEntity()).toList();
    if (stayId != null) {
      list = list.where((o) => o.stayId == stayId).toList();
    }
    return list;
  }

  @override
  Future<ServiceUsageOrder> orderService({
    required int stayId,
    required String roomNumber,
    required HotelServiceItem service,
    required int quantity,
  }) async {
    final payload = {
      'stayId': stayId,
      'roomNumber': roomNumber,
      'serviceId': service.id,
      'serviceName': service.name,
      'quantity': quantity,
      'unitPrice': service.price,
      'totalPrice': service.price * quantity,
    };
    final model = await remoteDataSource.orderService(payload);
    return model.toEntity();
  }
}
