import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/room_model.dart';

abstract class RoomRemoteDataSource {
  Future<List<RoomModel>> fetchRooms();
  Future<void> updateHousekeepingStatus(int roomId, String newStatus, {String rowVersion = ''});
}

class RoomRemoteDataSourceImpl implements RoomRemoteDataSource {
  final Dio dio;

  RoomRemoteDataSourceImpl(this.dio);

  @override
  Future<List<RoomModel>> fetchRooms() async {
    try {
      final response = await dio.get(ApiConstants.roomService);
      dynamic data = response.data;
      if (data is Map && (data.containsKey('items') || data.containsKey('Items'))) {
        data = data['items'] ?? data['Items'];
      }
      if (data is List) {
        return data
            .map((json) => RoomModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      // ignore: avoid_print
      print('❌ [RoomRemoteDataSource] fetchRooms error: $e');
      throw Exception('Không thể tải danh sách phòng từ máy chủ: $e');
    }
  }

  @override
  Future<void> updateHousekeepingStatus(int roomId, String newStatus, {String rowVersion = ''}) async {
    try {
      // Byte mapping chuẩn theo Backend .NET:
      // 1: Cần dọn (Dirty), 2: Đang dọn (InProgress), 3: Sạch (Clean), 4: Đã kiểm tra (Inspected)
      int hkByte = 3;
      if (newStatus == 'Cần dọn' || newStatus.toLowerCase().contains('bẩn') || newStatus.toLowerCase().contains('cần')) {
        hkByte = 1;
      } else if (newStatus == 'Đang dọn') {
        hkByte = 2;
      } else if (newStatus == 'Sạch') {
        hkByte = 3;
      } else if (newStatus == 'Đã kiểm tra') {
        hkByte = 4;
      }

      await dio.patch(
        '${ApiConstants.roomService}/$roomId/status',
        data: {
          'housekeepingStatus': hkByte,
          'rowVersion': rowVersion,
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('❌ [RoomRemoteDataSource] updateHousekeepingStatus error: $e');
      throw Exception('Cập nhật trạng thái phòng thất bại: $e');
    }
  }
}
