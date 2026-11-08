import '../../domain/entities/reservation.dart';
import '../../domain/repositories/reservation_repository.dart';
import '../datasources/reservation_remote_datasource.dart';
import '../../../room/data/datasources/room_remote_datasource.dart';
import '../../../room/data/models/room_model.dart';
import '../../../guest/data/datasources/guest_remote_datasource.dart';
import '../../../guest/data/models/guest_model.dart';

class ReservationRepositoryImpl implements ReservationRepository {
  final ReservationRemoteDataSource remoteDataSource;
  final RoomRemoteDataSource? roomRemoteDataSource;
  final GuestRemoteDataSource? guestRemoteDataSource;

  ReservationRepositoryImpl(
    this.remoteDataSource, {
    this.roomRemoteDataSource,
    this.guestRemoteDataSource,
  });

  @override
  Future<List<Reservation>> getReservations({String? search, String? status}) async {
    final models = await remoteDataSource.fetchReservations();

    // Làm giàu dữ liệu (Enrich) với thông tin phòng thực tế từ RoomAPI
    final Map<int, RoomModel> roomsMap = {};
    if (roomRemoteDataSource != null) {
      try {
        final rooms = await roomRemoteDataSource!.fetchRooms();
        for (final r in rooms) {
          roomsMap[r.id] = r;
        }
      } catch (_) {}
    }

    // Làm giàu dữ liệu với thông tin khách hàng thực tế từ GuestAPI
    final Map<int, GuestModel> guestsMap = {};
    if (guestRemoteDataSource != null) {
      try {
        final guests = await guestRemoteDataSource!.fetchGuests();
        for (final g in guests) {
          guestsMap[g.id] = g;
        }
      } catch (_) {}
    }

    var list = models.map((m) {
      final room = roomsMap[m.roomId];
      final guest = guestsMap[m.guestId];

      String resolvedGuestName = guest?.fullName ?? '';
      String resolvedGuestPhone = guest?.phoneNumber ?? '';
      String? resolvedGuestIdCard = guest?.documentNumber;

      // Nếu không tìm thấy trong GuestAPI, thử bóc tách từ notes (được ghi lại khi tạo đặt phòng)
      if (resolvedGuestName.isEmpty && m.notes != null && m.notes!.contains('Khách:')) {
        final reg = RegExp(r'Khách:\s*([^-]+)(?:\s*-\s*SĐT:\s*([^-]+))?(?:\s*-\s*CCCD:\s*(.+))?');
        final match = reg.firstMatch(m.notes!);
        if (match != null) {
          resolvedGuestName = match.group(1)?.trim() ?? '';
          if (resolvedGuestPhone.isEmpty) resolvedGuestPhone = match.group(2)?.trim() ?? '';
          resolvedGuestIdCard ??= match.group(3)?.trim();
        }
      }

      if (resolvedGuestName.isEmpty) {
        resolvedGuestName = m.guestName.isNotEmpty && m.guestName != 'Khách đặt phòng'
            ? m.guestName
            : (m.guestId > 0 ? 'Khách #${m.guestId}' : 'Khách #${m.numericId}');
      }
      if (resolvedGuestPhone.isEmpty) {
        resolvedGuestPhone = m.guestPhone.isNotEmpty && m.guestPhone != '0901234567'
            ? m.guestPhone
            : 'Chưa có SĐT';
      }

      final resolvedRoomNumber = room?.roomNumber.isNotEmpty == true
          ? room!.roomNumber
          : (m.roomNumber.isNotEmpty && m.roomNumber != 'DEV-101' ? m.roomNumber : (m.roomId > 0 ? 'Phòng #${m.roomId}' : 'Chưa xếp phòng'));

      final resolvedRoomTypeName = room?.roomTypeName.isNotEmpty == true
          ? room!.roomTypeName
          : (m.roomTypeName.isNotEmpty ? m.roomTypeName : 'Phòng tiêu chuẩn');

      return m.toEntity().copyWith(
        guestName: resolvedGuestName,
        guestPhone: resolvedGuestPhone,
        guestIdCard: resolvedGuestIdCard ?? m.guestIdCard,
        roomNumber: resolvedRoomNumber,
        roomTypeName: resolvedRoomTypeName,
      );
    }).toList();

    if (search != null && search.isNotEmpty) {
      final s = search.toLowerCase();
      list = list.where((r) =>
          r.id.toLowerCase().contains(s) ||
          r.guestName.toLowerCase().contains(s) ||
          r.roomNumber.toLowerCase().contains(s) ||
          r.guestPhone.toLowerCase().contains(s)).toList();
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
    return createdModel.toEntity().copyWith(
      guestName: guestName,
      guestPhone: guestPhone,
      guestIdCard: guestIdCard,
      roomNumber: roomNumber,
      roomTypeName: roomTypeName,
    );
  }

  @override
  Future<void> updateStatus(String reservationId, String newStatus, {String rowVersion = ''}) async {
    await remoteDataSource.updateStatus(reservationId, newStatus, rowVersion: rowVersion);
  }
}
