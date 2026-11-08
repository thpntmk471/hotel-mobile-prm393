import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/reservation_model.dart';

abstract class ReservationRemoteDataSource {
  Future<List<ReservationModel>> fetchReservations();
  Future<ReservationModel> createReservation(Map<String, dynamic> payload);
  Future<void> updateStatus(String reservationId, String newStatus, {String rowVersion = '', String? reason});
}

class ReservationRemoteDataSourceImpl implements ReservationRemoteDataSource {
  final Dio dio;

  ReservationRemoteDataSourceImpl(this.dio);

  @override
  Future<List<ReservationModel>> fetchReservations() async {
    try {
      final response = await dio.get(ApiConstants.reservationService);
      dynamic data = response.data;
      if (data is Map && (data.containsKey('items') || data.containsKey('Items'))) {
        data = data['items'] ?? data['Items'];
      }
      if (data is List) {
        return data
            .map((e) => ReservationModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      // ignore: avoid_print
      print('❌ [ReservationRemoteDataSource] fetchReservations error: $e');
      throw Exception('Không thể tải danh sách đặt phòng từ máy chủ: $e');
    }
  }

  @override
  Future<ReservationModel> createReservation(Map<String, dynamic> payload) async {
    try {
      final response = await dio.post(ApiConstants.reservationService, data: payload);
      return ReservationModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      // ignore: avoid_print
      print('❌ [ReservationRemoteDataSource] createReservation DioException: ${e.response?.statusCode} - ${e.response?.data}');
      String message = 'Lỗi tạo đơn đặt phòng trên hệ thống.';
      if (e.response?.data != null) {
        final d = e.response!.data;
        if (d is Map) {
          if (d['message'] != null) {
            message = d['message'].toString();
          } else if (d['title'] != null) {
            message = d['title'].toString();
          } else if (d['errors'] != null) {
            message = d['errors'].toString();
          }
        } else if (d is String && d.isNotEmpty) {
          message = d;
        }
      }
      throw Exception(message);
    } catch (e) {
      // ignore: avoid_print
      print('❌ [ReservationRemoteDataSource] createReservation error: $e');
      throw Exception('Lỗi tạo đơn đặt phòng trên hệ thống: $e');
    }
  }

  @override
  Future<void> updateStatus(String reservationId, String newStatus, {String rowVersion = '', String? reason}) async {
    try {
      final idNum = int.tryParse(reservationId);
      if (idNum != null && (newStatus == 'Đã hủy' || newStatus == 'Cancelled')) {
        await dio.post(
          '${ApiConstants.reservationService}/$idNum/cancel',
          data: {
            'reason': (reason != null && reason.trim().isNotEmpty) ? reason.trim() : 'Khách yêu cầu hủy qua ứng dụng Mobile',
            'rowVersion': rowVersion,
          },
        );
      }
    } on DioException catch (e) {
      // ignore: avoid_print
      print('❌ [ReservationRemoteDataSource] updateStatus DioException: ${e.response?.data}');
      String msg = 'Lỗi cập nhật trạng thái đơn đặt.';
      if (e.response?.data is Map) {
        final d = e.response!.data as Map;
        msg = d['message']?.toString() ?? d['title']?.toString() ?? msg;
      }
      throw Exception(msg);
    } catch (e) {
      // ignore: avoid_print
      print('❌ [ReservationRemoteDataSource] updateStatus error: $e');
      throw Exception('Lỗi cập nhật trạng thái đơn đặt: $e');
    }
  }
}

