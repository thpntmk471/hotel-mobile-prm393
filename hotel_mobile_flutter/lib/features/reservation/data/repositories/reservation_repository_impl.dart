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
  }) async {
    final nights = checkOutDate.difference(checkInDate).inDays;
    final validNights = nights <= 0 ? 1 : nights;
    final total = pricePerNight * validNights;

    final inDateStr =
        '${checkInDate.year}-${checkInDate.month.toString().padLeft(2, '0')}-${checkInDate.day.toString().padLeft(2, '0')}';
    final outDateStr =
        '${checkOutDate.year}-${checkOutDate.month.toString().padLeft(2, '0')}-${checkOutDate.day.toString().padLeft(2, '0')}';

    final payload = {
      // Dữ liệu chuẩn DTO gửi lên .NET Backend (CreateReservationDto)
      'guestId': 1,
      'roomId': roomId,
      'checkInDate': inDateStr,
      'checkOutDate': outDateStr,
      'numberOfGuests': numberOfGuests,
      'notes': 'Khách hàng: $guestName - SĐT: $guestPhone (Mobile App)',

      // Dữ liệu mở rộng để đồng bộ UI và Mock Fallback
      'id': 'RSV${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      'guestName': guestName,
      'guestPhone': guestPhone,
      'guestIdCard': guestIdCard,
      'roomNumber': roomNumber,
      'roomTypeName': roomTypeName,
      'pricePerNight': pricePerNight,
      'totalPrice': total,
      'status': 'Đã xác nhận',
      'createdAt': DateTime.now().toIso8601String(),
    };

    final createdModel = await remoteDataSource.createReservation(payload);
    return createdModel.toEntity();
  }

  @override
  Future<void> updateStatus(String reservationId, String newStatus) async {
    await remoteDataSource.updateStatus(reservationId, newStatus);
  }
}

