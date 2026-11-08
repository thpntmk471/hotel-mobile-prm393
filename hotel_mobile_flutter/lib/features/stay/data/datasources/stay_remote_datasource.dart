import 'dart:math';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/stay_model.dart';

abstract class StayRemoteDataSource {
  Future<List<StayModel>> fetchStays();
  Future<Map<String, dynamic>?> getStayDetail(int stayId);
  Future<StayModel> checkIn(int reservationId, int accountId, {String? notes});
  Future<Map<String, dynamic>?> getStayInvoice(int stayId);
  Future<Map<String, dynamic>> draftInvoice(int stayId, int accountId, {String? notes});
  Future<Map<String, dynamic>> finalizeInvoice(int stayId, int accountId);
  Future<Map<String, dynamic>> recordPayment({
    required int invoiceId,
    required double amount,
    required int method,
    required int accountId,
    String? notes,
  });
  Future<void> checkOut(int stayId, int accountId, {String? notes});
  Future<List<Map<String, dynamic>>> fetchServiceUsages(int stayId);
  Future<Map<String, dynamic>> createServiceUsage({
    required int stayId,
    required int hotelServiceId,
    required double quantity,
    required int accountId,
    String? notes,
  });
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
  Future<Map<String, dynamic>?> getStayDetail(int stayId) async {
    try {
      final res = await dio.get('${ApiConstants.stayService}/$stayId');
      if (res.data is Map<String, dynamic>) {
        return res.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('❌ [StayRemoteDataSource] getStayDetail error: $e');
      return null;
    }
  }

  @override
  Future<StayModel> checkIn(int reservationId, int accountId, {String? notes}) async {
    try {
      final res = await dio.post(
        '${ApiConstants.stayService}/check-in',
        data: {
          'reservationId': reservationId,
          'checkedInByAccountId': accountId > 0 ? accountId : 2,
          'notes': notes ?? 'Nhận phòng từ ứng dụng Mobile',
        },
      );
      return StayModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      // ignore: avoid_print
      print('❌ [StayRemoteDataSource] checkIn DioException: ${e.response?.data}');
      String msg = 'Thực hiện nhận phòng (check-in) thất bại.';
      if (e.response?.data is Map) {
        final d = e.response!.data as Map;
        msg = d['message']?.toString() ?? d['title']?.toString() ?? msg;
      }
      throw Exception(msg);
    } catch (e) {
      // ignore: avoid_print
      print('❌ [StayRemoteDataSource] checkIn error: $e');
      throw Exception('Thực hiện nhận phòng (check-in) thất bại: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getStayInvoice(int stayId) async {
    try {
      final res = await dio.get('${ApiConstants.stayService}/$stayId/invoice');
      if (res.data is Map<String, dynamic>) {
        return res.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('❌ [StayRemoteDataSource] getStayInvoice: $e');
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>> draftInvoice(int stayId, int accountId, {String? notes}) async {
    try {
      final res = await dio.post(
        '${ApiConstants.stayService}/$stayId/invoice',
        data: {
          'createdByAccountId': accountId > 0 ? accountId : 2,
          'notes': notes ?? 'Lập hóa đơn nháp từ Mobile',
        },
      );
      return (res.data as Map<String, dynamic>?) ?? {};
    } on DioException catch (e) {
      String msg = 'Lập hóa đơn nháp thất bại.';
      if (e.response?.data is Map) {
        final d = e.response!.data as Map;
        msg = d['message']?.toString() ?? d['title']?.toString() ?? msg;
      }
      throw Exception(msg);
    } catch (e) {
      throw Exception('Lập hóa đơn nháp thất bại: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> finalizeInvoice(int stayId, int accountId) async {
    try {
      final res = await dio.post(
        '${ApiConstants.stayService}/$stayId/invoice/finalize',
        data: {
          'finalizedByAccountId': accountId > 0 ? accountId : 2,
        },
      );
      return (res.data as Map<String, dynamic>?) ?? {};
    } on DioException catch (e) {
      String msg = 'Chốt hóa đơn thất bại.';
      if (e.response?.data is Map) {
        final d = e.response!.data as Map;
        msg = d['message']?.toString() ?? d['title']?.toString() ?? msg;
      }
      throw Exception(msg);
    } catch (e) {
      throw Exception('Chốt hóa đơn thất bại: $e');
    }
  }

  String _generateGuid() {
    final random = Random();
    String hex(int len) => List.generate(len, (_) => random.nextInt(16).toRadixString(16)).join();
    return '${hex(8)}-${hex(4)}-4${hex(3)}-${(8 + random.nextInt(4)).toRadixString(16)}${hex(3)}-${hex(12)}';
  }

  @override
  Future<Map<String, dynamic>> recordPayment({
    required int invoiceId,
    required double amount,
    required int method,
    required int accountId,
    String? notes,
  }) async {
    try {
      // Route chuẩn của PaymentsController: api/invoices/{invoiceId}/payments
      final url = '${ApiConstants.host}:5006/api/invoices/$invoiceId/payments';
      final res = await dio.post(
        url,
        data: {
          'idempotencyKey': _generateGuid(),
          'amount': amount,
          'method': method, // 1: Tiền mặt, 2: Chuyển khoản, 3: Thẻ
          'recordedByAccountId': accountId > 0 ? accountId : 2,
          'notes': notes ?? 'Thanh toán qua ứng dụng Mobile',
        },
      );
      return (res.data as Map<String, dynamic>?) ?? {};
    } on DioException catch (e) {
      String msg = 'Ghi nhận thanh toán thất bại.';
      if (e.response?.data is Map) {
        final d = e.response!.data as Map;
        msg = d['message']?.toString() ?? d['title']?.toString() ?? msg;
      }
      throw Exception(msg);
    } catch (e) {
      throw Exception('Ghi nhận thanh toán thất bại: $e');
    }
  }

  @override
  Future<void> checkOut(int stayId, int accountId, {String? notes}) async {
    try {
      await dio.post(
        '${ApiConstants.stayService}/$stayId/check-out',
        data: {
          'checkedOutByAccountId': accountId > 0 ? accountId : 2,
          'notes': notes ?? 'Check-out qua ứng dụng Mobile',
        },
      );
    } on DioException catch (e) {
      // ignore: avoid_print
      print('❌ [StayRemoteDataSource] checkOut DioException: ${e.response?.data}');
      String msg = 'Thực hiện trả phòng (check-out) thất bại.';
      if (e.response?.data is Map) {
        final d = e.response!.data as Map;
        msg = d['message']?.toString() ?? d['title']?.toString() ?? msg;
      }
      throw Exception(msg);
    } catch (e) {
      // ignore: avoid_print
      print('❌ [StayRemoteDataSource] checkOut error: $e');
      throw Exception('Thực hiện trả phòng (check-out) thất bại: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchServiceUsages(int stayId) async {
    try {
      final res = await dio.get(
        ApiConstants.serviceUsage,
        queryParameters: {'stayId': stayId, 'page': 1, 'pageSize': 100},
      );
      dynamic data = res.data;
      if (data is Map && (data.containsKey('items') || data.containsKey('Items'))) {
        data = data['items'] ?? data['Items'];
      }
      if (data is List) {
        return data.map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      // ignore: avoid_print
      print('❌ [StayRemoteDataSource] fetchServiceUsages error: $e');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> createServiceUsage({
    required int stayId,
    required int hotelServiceId,
    required double quantity,
    required int accountId,
    String? notes,
  }) async {
    try {
      final res = await dio.post(
        ApiConstants.serviceUsage,
        data: {
          'stayId': stayId,
          'hotelServiceId': hotelServiceId,
          'quantity': quantity,
          'usedAt': DateTime.now().toUtc().toIso8601String(),
          'recordedByAccountId': accountId > 0 ? accountId : 2,
          'notes': notes,
        },
      );
      return (res.data as Map<String, dynamic>?) ?? {};
    } on DioException catch (e) {
      String msg = 'Thêm dịch vụ thất bại.';
      if (e.response?.data is Map) {
        final d = e.response!.data as Map;
        msg = d['message']?.toString() ?? d['title']?.toString() ?? msg;
      }
      throw Exception(msg);
    } catch (e) {
      throw Exception('Thêm dịch vụ thất bại: $e');
    }
  }
}
