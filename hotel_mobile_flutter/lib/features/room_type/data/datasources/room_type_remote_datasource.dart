import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/room_type_model.dart';

abstract class RoomTypeRemoteDataSource {
  Future<List<RoomTypeModel>> fetchRoomTypes();
  Future<RoomTypeModel> createRoomType(Map<String, dynamic> data);
  Future<RoomTypeModel> updateRoomType(int id, Map<String, dynamic> data);
  Future<void> deleteRoomType(int id);
}

class RoomTypeRemoteDataSourceImpl implements RoomTypeRemoteDataSource {
  final Dio dio;

  RoomTypeRemoteDataSourceImpl(this.dio);

  @override
  Future<List<RoomTypeModel>> fetchRoomTypes() async {
    try {
      final res = await dio.get(ApiConstants.roomTypeService);
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
      return items.map((e) => RoomTypeModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      // ignore: avoid_print
      print('❌ [RoomTypeRemoteDataSource] fetchRoomTypes error: $e');
      throw Exception('Lỗi lấy danh sách loại phòng: $e');
    }
  }

  @override
  Future<RoomTypeModel> createRoomType(Map<String, dynamic> data) async {
    try {
      final res = await dio.post(ApiConstants.roomTypeService, data: data);
      return RoomTypeModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      // ignore: avoid_print
      print('❌ [RoomTypeRemoteDataSource] createRoomType error: $e');
      throw Exception('Lỗi thêm loại phòng mới: $e');
    }
  }

  @override
  Future<RoomTypeModel> updateRoomType(int id, Map<String, dynamic> data) async {
    try {
      final res = await dio.put('${ApiConstants.roomTypeService}/$id', data: data);
      return RoomTypeModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      // ignore: avoid_print
      print('❌ [RoomTypeRemoteDataSource] updateRoomType error: $e');
      throw Exception('Lỗi cập nhật loại phòng: $e');
    }
  }

  @override
  Future<void> deleteRoomType(int id) async {
    try {
      await dio.delete('${ApiConstants.roomTypeService}/$id');
    } catch (e) {
      // ignore: avoid_print
      print('❌ [RoomTypeRemoteDataSource] deleteRoomType error: $e');
      throw Exception('Lỗi xóa loại phòng: $e');
    }
  }
}

