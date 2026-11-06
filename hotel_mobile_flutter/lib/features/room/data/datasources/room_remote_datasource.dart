import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/room_model.dart';

abstract class RoomRemoteDataSource {
  Future<List<RoomModel>> fetchRooms();
  Future<void> updateHousekeepingStatus(int roomId, String newStatus);
}

class RoomRemoteDataSourceImpl implements RoomRemoteDataSource {
  final Dio dio;

  RoomRemoteDataSourceImpl(this.dio);

  // Mock data bám sát 100% dữ liệu Web Backend (PRN232)
  final List<RoomModel> _mockRooms = [
    RoomModel(
      id: 1,
      roomNumber: 'DEV-101',
      floor: 1,
      roomTypeId: 1,
      roomTypeName: 'Phòng Standard',
      pricePerNight: 450000,
      operationalStatus: 'Hoạt động',
      housekeepingStatus: 'Sạch',
    ),
    RoomModel(
      id: 2,
      roomNumber: 'DEV-102',
      floor: 1,
      roomTypeId: 1,
      roomTypeName: 'Phòng Standard',
      pricePerNight: 450000,
      operationalStatus: 'Hoạt động',
      housekeepingStatus: 'Sạch',
    ),
    RoomModel(
      id: 3,
      roomNumber: 'DEV-201',
      floor: 2,
      roomTypeId: 2,
      roomTypeName: 'Phòng Deluxe',
      pricePerNight: 700000,
      operationalStatus: 'Hoạt động',
      housekeepingStatus: 'Cần dọn',
    ),
    RoomModel(
      id: 4,
      roomNumber: 'DEV-202',
      floor: 2,
      roomTypeId: 2,
      roomTypeName: 'Phòng Deluxe',
      pricePerNight: 700000,
      operationalStatus: 'Hoạt động',
      housekeepingStatus: 'Sạch',
    ),
    RoomModel(
      id: 5,
      roomNumber: 'DEV-301',
      floor: 3,
      roomTypeId: 3,
      roomTypeName: 'Phòng VIP Suite',
      pricePerNight: 1100000,
      operationalStatus: 'Hoạt động',
      housekeepingStatus: 'Sạch',
    ),
  ];

  @override
  Future<List<RoomModel>> fetchRooms() async {
    try {
      final response = await dio.get(ApiConstants.roomService);
      if (response.data is List) {
        return (response.data as List)
            .map((json) => RoomModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return _mockRooms;
    } catch (_) {
      // Mock Fallback an toàn khi chưa chạy API Backend
      return _mockRooms;
    }
  }

  @override
  Future<void> updateHousekeepingStatus(int roomId, String newStatus) async {
    try {
      await dio.put(
        '${ApiConstants.roomService}/$roomId/housekeeping',
        data: {'status': newStatus},
      );
    } catch (_) {
      final index = _mockRooms.indexWhere((r) => r.id == roomId);
      if (index != -1) {
        final r = _mockRooms[index];
        _mockRooms[index] = RoomModel(
          id: r.id,
          roomNumber: r.roomNumber,
          floor: r.floor,
          roomTypeId: r.roomTypeId,
          roomTypeName: r.roomTypeName,
          pricePerNight: r.pricePerNight,
          operationalStatus: r.operationalStatus,
          housekeepingStatus: newStatus,
        );
      }
    }
  }
}
