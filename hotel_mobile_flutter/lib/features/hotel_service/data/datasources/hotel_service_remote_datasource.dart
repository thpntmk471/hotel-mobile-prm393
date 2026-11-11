import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/hotel_service_model.dart';

abstract class HotelServiceRemoteDataSource {
  Future<List<HotelServiceItemModel>> fetchServices();
  Future<List<ServiceUsageOrderModel>> fetchOrders();
  Future<ServiceUsageOrderModel> orderService(Map<String, dynamic> payload);
  Future<HotelServiceItemModel> createService(Map<String, dynamic> payload);
  Future<HotelServiceItemModel> updateService(int id, Map<String, dynamic> payload);
  Future<HotelServiceItemModel> updateStatus(int id, bool isActive, String rowVersion);
}

class HotelServiceRemoteDataSourceImpl implements HotelServiceRemoteDataSource {
  final Dio dio;

  HotelServiceRemoteDataSourceImpl(this.dio);

  @override
  Future<List<HotelServiceItemModel>> fetchServices() async {
    final res = await dio.get(
      ApiConstants.hotelService,
      queryParameters: {'pageSize': 100},
    );
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
  Future<HotelServiceItemModel> createService(Map<String, dynamic> payload) async {
    try {
      final res = await dio.post(ApiConstants.hotelService, data: payload);
      return HotelServiceItemModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      String msg = 'Không thể tạo dịch vụ.';
      if (e.response?.data is Map) {
        final d = e.response!.data as Map;
        msg = d['message']?.toString() ?? d['title']?.toString() ?? msg;
      }
      throw Exception(msg);
    }
  }

  @override
  Future<HotelServiceItemModel> updateService(int id, Map<String, dynamic> payload) async {
    try {
      final res = await dio.put('${ApiConstants.hotelService}/$id', data: payload);
      return HotelServiceItemModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      String msg = 'Không thể cập nhật dịch vụ.';
      if (e.response?.data is Map) {
        final d = e.response!.data as Map;
        msg = d['message']?.toString() ?? d['title']?.toString() ?? msg;
      }
      throw Exception(msg);
    }
  }

  @override
  Future<HotelServiceItemModel> updateStatus(int id, bool isActive, String rowVersion) async {
    try {
      final res = await dio.patch(
        '${ApiConstants.hotelService}/$id/status',
        data: {
          'isActive': isActive,
          'rowVersion': rowVersion,
        },
      );
      return HotelServiceItemModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      String msg = 'Không thể cập nhật trạng thái dịch vụ.';
      if (e.response?.data is Map) {
        final d = e.response!.data as Map;
        msg = d['message']?.toString() ?? d['title']?.toString() ?? msg;
      }
      throw Exception(msg);
    }
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
