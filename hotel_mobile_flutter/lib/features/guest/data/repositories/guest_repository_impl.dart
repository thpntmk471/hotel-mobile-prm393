import '../../domain/entities/guest.dart';
import '../../domain/repositories/guest_repository.dart';
import '../datasources/guest_remote_datasource.dart';

class GuestRepositoryImpl implements GuestRepository {
  final GuestRemoteDataSource remoteDataSource;

  GuestRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Guest>> getGuests({String? keyword}) async {
    final models = await remoteDataSource.fetchGuests(keyword: keyword);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Guest> createGuest({
    required String fullName,
    required String phoneNumber,
    String? email,
    required String documentNumber,
    String? address,
    String? notes,
  }) async {
    final payload = {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email ?? '${phoneNumber.replaceAll(' ', '')}@guest.hotelprm.com',
      'documentType': 1, // 1: CCCD
      'documentNumber': documentNumber,
      'documentCountryCode': 'VN',
      'address': address ?? 'Việt Nam',
      'notes': notes ?? 'Khách tạo từ Mobile App',
    };
    final model = await remoteDataSource.createGuest(payload);
    return model.toEntity();
  }

  @override
  Future<Guest> updateGuest({
    required int id,
    required String fullName,
    required String phoneNumber,
    String? email,
    required String documentNumber,
    String? address,
    String? notes,
    required String rowVersion,
  }) async {
    final payload = {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email ?? '${phoneNumber.replaceAll(' ', '')}@guest.hotelprm.com',
      'documentType': 1,
      'documentNumber': documentNumber,
      'documentCountryCode': 'VN',
      'address': address ?? 'Việt Nam',
      'notes': notes,
      'rowVersion': rowVersion,
    };
    final model = await remoteDataSource.updateGuest(id, payload);
    return model.toEntity();
  }

  @override
  Future<void> archiveGuest(int id, String rowVersion) async {
    await remoteDataSource.archiveGuest(id, rowVersion);
  }
}

