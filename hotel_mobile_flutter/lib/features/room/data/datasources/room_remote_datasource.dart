import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/room_model.dart';

abstract class RoomRemoteDataSource {
  Future<List<RoomModel>> fetchRooms();
  Future<void> updateHousekeepingStatus(int roomId, String newStatus, {String rowVersion = ''});
  Future<RoomModel> createRoom(Map<String, dynamic> data);
  Future<RoomModel> updateRoom(int roomId, Map<String, dynamic> data);
  Future<void> deleteRoom(int roomId);
}

class RoomRemoteDataSourceImpl implements RoomRemoteDataSource {
  final Dio dio;

  RoomRemoteDataSourceImpl(this.dio);

  @override
  Future<List<RoomModel>> fetchRooms() async {
    try {
      final List<RoomModel> allRooms = [];
      int currentPage = 1;
      int totalPages = 1;

      do {
        final response = await dio.get(
          ApiConstants.roomService,
          queryParameters: {
            'page': currentPage,
            'pageSize': 100,
          },
        );
        dynamic data = response.data;
        if (data is Map) {
          totalPages = (data['totalPages'] ?? data['TotalPages'] ?? 1) as int;
          if (data.containsKey('items') || data.containsKey('Items')) {
            data = data['items'] ?? data['Items'];
          }
        }
        if (data is List) {
          allRooms.addAll(
            data.map((json) => RoomModel.fromJson(json as Map<String, dynamic>)),
          );
        } else {
          break;
        }
        currentPage++;
      } while (currentPage <= totalPages);

      return allRooms;
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

      String finalRowVersion = rowVersion;
      if (finalRowVersion.trim().isEmpty) {
        try {
          final res = await dio.get('${ApiConstants.roomService}/$roomId');
          if (res.data is Map && res.data['rowVersion'] != null) {
            finalRowVersion = res.data['rowVersion'].toString();
          }
        } catch (_) {}
      }

      await dio.patch(
        '${ApiConstants.roomService}/$roomId/status',
        data: {
          'housekeepingStatus': hkByte,
          'rowVersion': finalRowVersion,
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('❌ [RoomRemoteDataSource] updateHousekeepingStatus error: $e');
      throw Exception('Cập nhật trạng thái phòng thất bại: $e');
    }
  }

  @override
  Future<RoomModel> createRoom(Map<String, dynamic> data) async {
    try {
      final res = await dio.post(ApiConstants.roomService, data: data);
      return RoomModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      // ignore: avoid_print
      print('❌ [RoomRemoteDataSource] createRoom error: $e');
      throw Exception('Lỗi thêm phòng mới: $e');
    }
  }

  @override
  Future<RoomModel> updateRoom(int roomId, Map<String, dynamic> data) async {
    try {
      final res = await dio.put('${ApiConstants.roomService}/$roomId', data: data);
      return RoomModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      // ignore: avoid_print
      print('❌ [RoomRemoteDataSource] updateRoom error: $e');
      throw Exception('Lỗi cập nhật phòng: $e');
    }
  }

  @override
  Future<void> deleteRoom(int roomId) async {
    try {
      await dio.delete('${ApiConstants.roomService}/$roomId');
    } catch (e) {
      // ignore: avoid_print
      print('❌ [RoomRemoteDataSource] deleteRoom error: $e');
      throw Exception('Lỗi xóa phòng: $e');
    }
  }
}
