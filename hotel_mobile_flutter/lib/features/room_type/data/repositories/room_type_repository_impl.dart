import '../../domain/entities/room_type.dart';
import '../../domain/repositories/room_type_repository.dart';
import '../datasources/room_type_remote_datasource.dart';

class RoomTypeRepositoryImpl implements RoomTypeRepository {
  final RoomTypeRemoteDataSource remoteDataSource;

  RoomTypeRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<RoomType>> getRoomTypes() async {
    final models = await remoteDataSource.fetchRoomTypes();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<RoomType> createRoomType({
    required String code,
    required String name,
    required String description,
    required int capacity,
    required double basePricePerNight,
  }) async {
    final payload = {
      'code': code,
      'name': name,
      'description': description,
      'capacity': capacity,
      'basePricePerNight': basePricePerNight,
    };
    final model = await remoteDataSource.createRoomType(payload);
    return model.toEntity();
  }

  @override
  Future<RoomType> updateRoomType({
    required int id,
    required String code,
    required String name,
    required String description,
    required int capacity,
    required double basePricePerNight,
    required String rowVersion,
  }) async {
    final payload = {
      'code': code,
      'name': name,
      'description': description,
      'capacity': capacity,
      'basePricePerNight': basePricePerNight,
      'rowVersion': rowVersion,
    };
    final model = await remoteDataSource.updateRoomType(id, payload);
    return model.toEntity();
  }

  @override
  Future<void> deleteRoomType(int id) async {
    await remoteDataSource.deleteRoomType(id);
  }
}
