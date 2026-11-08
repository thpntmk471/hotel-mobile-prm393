import '../entities/room.dart';

abstract class RoomRepository {
  Future<List<Room>> getRooms({
    String? searchRoomNumber,
    String? roomTypeName,
    int? floor,
    String? operationalStatus,
    String? housekeepingStatus,
  });

  Future<void> updateHousekeepingStatus(int roomId, String newStatus, {String rowVersion = ''});

  Future<Room> createRoom({
    required String roomCode,
    required int roomTypeId,
    required int floorNumber,
    String description = '',
  });

  Future<Room> updateRoom({
    required int roomId,
    required String roomCode,
    required int roomTypeId,
    required int floorNumber,
    String description = '',
    required String rowVersion,
  });

  Future<void> deleteRoom(int roomId);
}
