import '../../domain/entities/stay.dart';
import '../../domain/repositories/stay_repository.dart';
import '../datasources/stay_remote_datasource.dart';

class StayRepositoryImpl implements StayRepository {
  final StayRemoteDataSource remoteDataSource;

  StayRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Stay>> getStays({String? search, String? status}) async {
    final models = await remoteDataSource.fetchStays();
    var list = models.map((m) => m.toEntity()).toList();

    if (search != null && search.isNotEmpty) {
      final s = search.toLowerCase();
      list = list.where((stay) =>
          stay.stayCode.toLowerCase().contains(s) ||
          stay.guestName.toLowerCase().contains(s) ||
          stay.roomNumber.toLowerCase().contains(s)).toList();
    }

    if (status != null && status != 'Tất cả') {
      list = list.where((stay) => stay.status == status).toList();
    }

    return list;
  }

  @override
  Future<Stay> getStayById(int stayId) async {
    final list = await getStays();
    return list.firstWhere((s) => s.id == stayId);
  }

  @override
  Future<Stay> checkInFromReservation({
    required String reservationId,
    required String guestName,
    required String roomNumber,
    required String roomTypeName,
    required double roomTotal,
  }) async {
    final payload = {
      'reservationId': reservationId,
      'guestName': guestName,
      'roomNumber': roomNumber,
      'roomTypeName': roomTypeName,
      'roomTotal': roomTotal,
    };
    final model = await remoteDataSource.checkIn(payload);
    return model.toEntity();
  }

  @override
  Future<void> checkOutAndPay({
    required int stayId,
    required String paymentMethod,
  }) async {
    await remoteDataSource.checkOut(stayId, paymentMethod);
  }
}

