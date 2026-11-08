import '../../domain/entities/reservation.dart';
import '../../domain/repositories/reservation_repository.dart';
import '../datasources/reservation_remote_datasource.dart';

class ReservationRepositoryImpl implements ReservationRepository {
  final ReservationRemoteDataSource remoteDataSource;

  ReservationRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Reservation>> getReservations({String? search, String? status}) async {
    final models = await remoteDataSource.fetchReservations();
    var list = models.map((m) => m.toEntity()).toList();

    if (search != null && search.isNotEmpty) {
      final s = search.toLowerCase();
      list = list.where((r) =>
          r.id.toLowerCase().contains(s) ||
          r.guestName.toLowerCase().contains(s) ||
          r.roomNumber.toLowerCase().contains(s)).toList();
    }

    if (status != null && status != 'Tất cả') {
      list = list.where((r) => r.status == status).toList();
    }

    return list;
  }

  @override
  Future<Reservation> createReservation({
    int? guestId,
    required String guestName,
    required String guestPhone,
    String? guestIdCard,
    required int roomId,
    required String roomNumber,
    required String roomTypeName,
    required double pricePerNight,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int numberOfGuests,
    int? createdByAccountId,
  }) async {
    final inDateStr =
        '${checkInDate.year}-${checkInDate.month.toString().padLeft(2, '0')}-${checkInDate.day.toString().padLeft(2, '0')}';
    final outDateStr =
        '${checkOutDate.year}-${checkOutDate.month.toString().padLeft(2, '0')}-${checkOutDate.day.toString().padLeft(2, '0')}';

    final payload = {
      'guestId': (guestId != null && guestId > 0) ? guestId : 1,
      'roomId': roomId,
      'checkInDate': inDateStr,
      'checkOutDate': outDateStr,
      'numberOfGuests': numberOfGuests,
      'createdByAccountId': (createdByAccountId != null && createdByAccountId > 0) ? createdByAccountId : 2,
      'notes': 'Khách: $guestName - SĐT: $guestPhone${guestIdCard != null ? ' - CCCD: $guestIdCard' : ''}',
    };

    final createdModel = await remoteDataSource.createReservation(payload);
    return createdModel.toEntity();
  }

  @override
  Future<void> updateStatus(String reservationId, String newStatus, {String rowVersion = ''}) async {
    await remoteDataSource.updateStatus(reservationId, newStatus, rowVersion: rowVersion);
  }
}

