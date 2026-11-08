import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/guest_model.dart';

abstract class GuestRemoteDataSource {
  Future<List<GuestModel>> fetchGuests({String? keyword});
  Future<GuestModel> createGuest(Map<String, dynamic> data);
  Future<GuestModel> updateGuest(int id, Map<String, dynamic> data);
  Future<void> archiveGuest(int id, String rowVersion);
}

class GuestRemoteDataSourceImpl implements GuestRemoteDataSource {
  final Dio dio;

  GuestRemoteDataSourceImpl(this.dio);

  @override
  Future<List<GuestModel>> fetchGuests({String? keyword}) async {
    try {
      final res = await dio.get(
        ApiConstants.guestService,
        queryParameters: {
          if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
          'page': 1,
          'pageSize': 50,
        },
      );
      List items = [];
      if (res.data is Map<String, dynamic>) {
        final map = res.data as Map<String, dynamic>;
        if (map['items'] is List) {
          items = map['items'] as List;
        } else if (map['Items'] is List) {
          items = map['Items'] as List;
        } else if (map['data'] is List) {
          items = map['data'] as List;
        }
      } else if (res.data is List) {
        items = res.data as List;
      }
      return items.map((e) => GuestModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      // ignore: avoid_print
      print('❌ [GuestRemoteDataSource] fetchGuests error: $e');
      throw Exception('Lỗi lấy danh sách khách hàng: $e');
    }
  }

  @override
  Future<GuestModel> createGuest(Map<String, dynamic> data) async {
    try {
      final res = await dio.post(ApiConstants.guestService, data: data);
      return GuestModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      // ignore: avoid_print
      print('❌ [GuestRemoteDataSource] createGuest error: $e');
      throw Exception('Lỗi lưu thông tin khách hàng: $e');
    }
  }

  @override
  Future<GuestModel> updateGuest(int id, Map<String, dynamic> data) async {
    try {
      final res = await dio.put('${ApiConstants.guestService}/$id', data: data);
      return GuestModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      // ignore: avoid_print
      print('❌ [GuestRemoteDataSource] updateGuest error: $e');
      throw Exception('Lỗi cập nhật thông tin khách: $e');
    }
  }

  @override
  Future<void> archiveGuest(int id, String rowVersion) async {
    try {
      await dio.delete(
        '${ApiConstants.guestService}/$id',
        queryParameters: {'rowVersion': rowVersion},
      );
    } catch (e) {
      // ignore: avoid_print
      print('❌ [GuestRemoteDataSource] archiveGuest error: $e');
      throw Exception('Lỗi xóa khách hàng: $e');
    }
  }
}

