import '../entities/room.dart';

abstract class RoomRepository {
  Future<List<Room>> getRooms({
    String? searchRoomNumber,
    String? roomTypeName,
    int? floor,
    String? operationalStatus,
    String? housekeepingStatus,
  });

  Future<void> updateHousekeepingStatus(int roomId, String newStatus);
}

