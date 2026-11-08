import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/stay_model.dart';

abstract class StayRemoteDataSource {
  Future<List<StayModel>> fetchStays();
  Future<StayModel> checkIn(Map<String, dynamic> payload);
  Future<void> checkOut(int stayId, String paymentMethod, {int checkedOutByAccountId = 2});
}

class StayRemoteDataSourceImpl implements StayRemoteDataSource {
  final Dio dio;

  StayRemoteDataSourceImpl(this.dio);

  @override
  Future<List<StayModel>> fetchStays() async {
    try {
      final res = await dio.get(ApiConstants.stayService);
      dynamic data = res.data;
      if (data is Map && (data.containsKey('items') || data.containsKey('Items'))) {
        data = data['items'] ?? data['Items'];
      }
      if (data is List) {
        return data
            .map((e) => StayModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      // ignore: avoid_print
      print('❌ [StayRemoteDataSource] fetchStays error: $e');
      throw Exception('Không thể tải danh sách lưu trú từ máy chủ: $e');
    }
  }

  @override
  Future<StayModel> checkIn(Map<String, dynamic> payload) async {
    try {
      final res = await dio.post('${ApiConstants.stayService}/check-in', data: payload);
      return StayModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      // ignore: avoid_print
      print('❌ [StayRemoteDataSource] checkIn error: $e');
      throw Exception('Thực hiện nhận phòng (check-in) thất bại: $e');
    }
  }

  @override
  Future<void> checkOut(int stayId, String paymentMethod, {int checkedOutByAccountId = 2}) async {
    try {
      await dio.post(
        '${ApiConstants.stayService}/$stayId/check-out',
        data: {
          'checkedOutByAccountId': checkedOutByAccountId,
          'notes': 'Check-out & Thanh toán qua Mobile App ($paymentMethod)',
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('❌ [StayRemoteDataSource] checkOut error: $e');
      throw Exception('Thực hiện trả phòng (check-out) thất bại: $e');
    }
  }
}
