import '../../domain/entities/room_type.dart';

abstract class RoomTypeRepository {
  Future<List<RoomType>> getRoomTypes();
  Future<RoomType> createRoomType({
    required String code,
    required String name,
    required String description,
    required int capacity,
    required double basePricePerNight,
  });
  Future<RoomType> updateRoomType({
    required int id,
    required String code,
    required String name,
    required String description,
    required int capacity,
    required double basePricePerNight,
    required String rowVersion,
  });
  Future<void> deleteRoomType(int id);
}
