import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/hotel_service_model.dart';

abstract class HotelServiceRemoteDataSource {
  Future<List<HotelServiceItemModel>> fetchServices();
  Future<List<ServiceUsageOrderModel>> fetchOrders();
  Future<ServiceUsageOrderModel> orderService(Map<String, dynamic> payload);
}

class HotelServiceRemoteDataSourceImpl implements HotelServiceRemoteDataSource {
  final Dio dio;

  HotelServiceRemoteDataSourceImpl(this.dio);

  @override
  Future<List<HotelServiceItemModel>> fetchServices() async {
    final res = await dio.get(ApiConstants.hotelService);
    final raw = res.data;
    List items = [];
    if (raw is List) {
      items = raw;
    } else if (raw is Map<String, dynamic> && raw['items'] is List) {
      items = raw['items'] as List;
    } else if (raw is Map<String, dynamic> && raw['data'] is List) {
      items = raw['data'] as List;
    }
    return items.map((e) => HotelServiceItemModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<ServiceUsageOrderModel>> fetchOrders() async {
    final res = await dio.get(ApiConstants.serviceUsage);
    final raw = res.data;
    List items = [];
    if (raw is List) {
      items = raw;
    } else if (raw is Map<String, dynamic> && raw['items'] is List) {
      items = raw['items'] as List;
    } else if (raw is Map<String, dynamic> && raw['data'] is List) {
      items = raw['data'] as List;
    }
    return items.map((e) => ServiceUsageOrderModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<ServiceUsageOrderModel> orderService(Map<String, dynamic> payload) async {
    final body = {
      'stayId': payload['stayId'] ?? 1,
      'hotelServiceId': payload['serviceId'] ?? payload['hotelServiceId'] ?? 1,
      'quantity': payload['quantity'] ?? 1,
      'notes': payload['notes'] ?? 'Order via Mobile App',
      'usedAt': DateTime.now().toIso8601String(),
    };
    final res = await dio.post(ApiConstants.serviceUsage, data: body);
    if (res.data is Map<String, dynamic>) {
      return ServiceUsageOrderModel.fromJson(res.data as Map<String, dynamic>);
    }
    throw Exception('Phản hồi tạo đơn dịch vụ không hợp lệ');
  }
}
