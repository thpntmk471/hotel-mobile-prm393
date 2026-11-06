import '../../domain/entities/room.dart';
import '../../domain/repositories/room_repository.dart';
import '../datasources/room_remote_datasource.dart';

class RoomRepositoryImpl implements RoomRepository {
  final RoomRemoteDataSource remoteDataSource;

  RoomRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Room>> getRooms({
    String? searchRoomNumber,
    String? roomTypeName,
    int? floor,
    String? operationalStatus,
    String? housekeepingStatus,
  }) async {
    final models = await remoteDataSource.fetchRooms();
    var list = models.map((m) => m.toEntity()).toList();

    // Áp dụng bộ lọc
    if (searchRoomNumber != null && searchRoomNumber.isNotEmpty) {
      list = list
          .where((r) => r.roomNumber.toLowerCase().contains(searchRoomNumber.toLowerCase()))
          .toList();
    }
    if (roomTypeName != null && roomTypeName != 'Tất cả') {
      list = list.where((r) => r.roomTypeName == roomTypeName).toList();
    }
    if (floor != null && floor != 0) {
      list = list.where((r) => r.floor == floor).toList();
    }
    if (housekeepingStatus != null && housekeepingStatus != 'Tất cả') {
      list = list.where((r) => r.housekeepingStatus == housekeepingStatus).toList();
    }

    return list;
  }

  @override
  Future<void> updateHousekeepingStatus(int roomId, String newStatus) async {
    await remoteDataSource.updateHousekeepingStatus(roomId, newStatus);
  }
}
