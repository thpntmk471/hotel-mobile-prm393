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

  final List<HotelServiceItemModel> _mockServices = [
    HotelServiceItemModel(
      id: 1,
      name: 'Ăn sáng Buffet',
      category: 'F&B',
      price: 60000,
      unit: 'Suất',
      description: 'Buffet sáng tiêu chuẩn quốc tế từ 6:00 - 9:30 hàng ngày.',
    ),
    HotelServiceItemModel(
      id: 2,
      name: 'Giặt ủi lấy nhanh',
      category: 'Laundry',
      price: 45000,
      unit: 'Kg',
      description: 'Giặt sấy thơm và ủi phẳng giao tận phòng trong 3 giờ.',
    ),
    HotelServiceItemModel(
      id: 3,
      name: 'Dịch vụ Spa & Massage',
      category: 'Spa',
      price: 300000,
      unit: 'Liệu trình 60p',
      description: 'Thư giãn toàn thân với tinh dầu thảo mộc thiên nhiên.',
    ),
    HotelServiceItemModel(
      id: 4,
      name: 'Đưa đón sân bay',
      category: 'Transportation',
      price: 250000,
      unit: 'Chuyến',
      description: 'Xe 7 chỗ đón tiễn sân bay đúng giờ, tiện nghi và lịch sự.',
    ),
    HotelServiceItemModel(
      id: 5,
      name: 'Nước suối khoáng & Minibar',
      category: 'F&B',
      price: 20000,
      unit: 'Chai',
      description: 'Bổ sung nước khoáng mát lạnh tận phòng.',
    ),
  ];

  final List<ServiceUsageOrderModel> _mockOrders = [
    ServiceUsageOrderModel(
      id: 101,
      stayId: 1,
      roomNumber: 'DEV-101',
      serviceId: 1,
      serviceName: 'Ăn sáng Buffet',
      quantity: 2,
      unitPrice: 60000,
      totalPrice: 120000,
      orderTime: DateTime.now().subtract(const Duration(hours: 4)),
      status: 'Đã phục vụ',
    ),
    ServiceUsageOrderModel(
      id: 102,
      stayId: 2,
      roomNumber: 'DEV-202',
      serviceId: 2,
      serviceName: 'Giặt ủi lấy nhanh',
      quantity: 3,
      unitPrice: 45000,
      totalPrice: 135000,
      orderTime: DateTime.now().subtract(const Duration(minutes: 30)),
      status: 'Đang giao',
    ),
  ];

  @override
  Future<List<HotelServiceItemModel>> fetchServices() async {
    try {
      final res = await dio.get(ApiConstants.hotelService);
      if (res.data is List) {
        return (res.data as List).map((e) => HotelServiceItemModel.fromJson(e)).toList();
      }
      return _mockServices;
    } catch (_) {
      return _mockServices;
    }
  }

  @override
  Future<List<ServiceUsageOrderModel>> fetchOrders() async {
    try {
      final res = await dio.get(ApiConstants.serviceUsage);
      if (res.data is List) {
        return (res.data as List).map((e) => ServiceUsageOrderModel.fromJson(e)).toList();
      }
      return _mockOrders;
    } catch (_) {
      return _mockOrders;
    }
  }

  @override
  Future<ServiceUsageOrderModel> orderService(Map<String, dynamic> payload) async {
    try {
      final res = await dio.post(ApiConstants.serviceUsage, data: payload);
      final model = ServiceUsageOrderModel.fromJson(res.data as Map<String, dynamic>);
      _mockOrders.insert(0, model);
      return model;
    } catch (_) {
      final model = ServiceUsageOrderModel(
        id: DateTime.now().millisecondsSinceEpoch % 10000,
        stayId: payload['stayId'] ?? 1,
        roomNumber: payload['roomNumber'] ?? 'DEV-101',
        serviceId: payload['serviceId'] ?? 1,
        serviceName: payload['serviceName'] ?? 'Dịch vụ phòng',
        quantity: payload['quantity'] ?? 1,
        unitPrice: (payload['unitPrice'] ?? 50000).toDouble(),
        totalPrice: (payload['totalPrice'] ?? 50000).toDouble(),
        orderTime: DateTime.now(),
        status: 'Đang giao',
      );
      _mockOrders.insert(0, model);
      return model;
    }
  }
}

