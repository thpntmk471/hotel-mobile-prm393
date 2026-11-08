import '../../domain/entities/stay.dart';
import '../../domain/repositories/stay_repository.dart';
import '../datasources/stay_remote_datasource.dart';
import '../models/stay_model.dart';
import '../../../room/data/datasources/room_remote_datasource.dart';
import '../../../room/data/models/room_model.dart';
import '../../../reservation/data/datasources/reservation_remote_datasource.dart';
import '../../../reservation/data/models/reservation_model.dart';
import '../../../guest/data/datasources/guest_remote_datasource.dart';
import '../../../guest/data/models/guest_model.dart';

class StayRepositoryImpl implements StayRepository {
  final StayRemoteDataSource remoteDataSource;
  final RoomRemoteDataSource? roomRemoteDataSource;
  final ReservationRemoteDataSource? reservationRemoteDataSource;
  final GuestRemoteDataSource? guestRemoteDataSource;

  StayRepositoryImpl(
    this.remoteDataSource, {
    this.roomRemoteDataSource,
    this.reservationRemoteDataSource,
    this.guestRemoteDataSource,
  });

  @override
  Future<List<Stay>> getStays({String? search, String? status}) async {
    final models = await remoteDataSource.fetchStays();

    // Làm giàu dữ liệu phòng
    final Map<int, RoomModel> roomsMap = {};
    if (roomRemoteDataSource != null) {
      try {
        final rooms = await roomRemoteDataSource!.fetchRooms();
        for (final r in rooms) {
          roomsMap[r.id] = r;
        }
      } catch (_) {}
    }

    // Làm giàu dữ liệu đặt phòng & khách hàng
    final Map<int, ReservationModel> resMap = {};
    if (reservationRemoteDataSource != null) {
      try {
        final reservations = await reservationRemoteDataSource!.fetchReservations();
        for (final r in reservations) {
          resMap[r.numericId] = r;
        }
      } catch (_) {}
    }

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
      final res = resMap[m.numericReservationId];
      final guest = res != null ? guestsMap[res.guestId] : null;

      String resolvedRoomNumber = room?.roomNumber.isNotEmpty == true
          ? room!.roomNumber
          : (m.roomNumber.isNotEmpty ? m.roomNumber : (m.roomId > 0 ? 'Phòng #${m.roomId}' : 'Chưa xếp'));

      String resolvedRoomTypeName = room?.roomTypeName.isNotEmpty == true
          ? room!.roomTypeName
          : (res?.roomTypeName.isNotEmpty == true ? res!.roomTypeName : m.roomTypeName);

      String resolvedGuestName = guest?.fullName.isNotEmpty == true
          ? guest!.fullName
          : (res?.guestName.isNotEmpty == true && res!.guestName != 'Khách đặt phòng'
              ? res.guestName
              : (m.guestName.isNotEmpty && m.guestName != 'Khách lưu trú' ? m.guestName : 'Khách #${m.id}'));

      String resolvedGuestPhone = guest?.phoneNumber.isNotEmpty == true
          ? guest!.phoneNumber
          : (res?.guestPhone.isNotEmpty == true && res!.guestPhone != '0901234567' ? res.guestPhone : m.guestPhone);

      return m.toEntity().copyWith(
        roomNumber: resolvedRoomNumber,
        roomTypeName: resolvedRoomTypeName,
        guestName: resolvedGuestName,
        guestPhone: resolvedGuestPhone,
      );
    }).toList();

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
    final detail = await remoteDataSource.getStayDetail(stayId);
    if (detail != null) {
      final model = StayModel.fromJson(detail);
      final stays = await getStays();
      final matched = stays.where((s) => s.id == stayId);
      if (matched.isNotEmpty) {
        return matched.first.copyWith(
          invoiceId: model.invoiceId,
          invoiceStatus: model.invoiceStatus,
          grandTotal: model.grandTotal > 0 ? model.grandTotal : matched.first.grandTotal,
          roomTotal: model.roomTotal > 0 ? model.roomTotal : matched.first.roomTotal,
          serviceTotal: model.serviceTotal > 0 ? model.serviceTotal : matched.first.serviceTotal,
          paidAmount: model.paidAmount,
          remainingAmount: model.remainingAmount,
          invoiceLines: model.invoiceLines.map((l) => l.toEntity()).toList(),
          serviceUsages: model.serviceUsages.map((u) => u.toEntity()).toList(),
          isPaid: model.isPaid,
          status: model.status,
          checkOutTime: model.checkOutTime,
        );
      }
      return model.toEntity();
    }
    final list = await getStays();
    return list.firstWhere((s) => s.id == stayId);
  }

  @override
  Future<Stay> checkIn({
    required int reservationId,
    required int accountId,
    String? notes,
  }) async {
    final model = await remoteDataSource.checkIn(reservationId, accountId, notes: notes);
    return model.toEntity();
  }

  @override
  Future<Map<String, dynamic>?> getStayDetail(int stayId) {
    return remoteDataSource.getStayDetail(stayId);
  }

  @override
  Future<Map<String, dynamic>> draftInvoice(int stayId, int accountId, {String? notes}) {
    return remoteDataSource.draftInvoice(stayId, accountId, notes: notes);
  }

  @override
  Future<Map<String, dynamic>> finalizeInvoice(int stayId, int accountId) {
    return remoteDataSource.finalizeInvoice(stayId, accountId);
  }

  @override
  Future<Map<String, dynamic>> recordPayment({
    required int invoiceId,
    required double amount,
    required int method,
    required int accountId,
    String? notes,
  }) {
    return remoteDataSource.recordPayment(
      invoiceId: invoiceId,
      amount: amount,
      method: method,
      accountId: accountId,
      notes: notes,
    );
  }

  @override
  Future<void> checkOut(int stayId, int accountId, {String? notes}) {
    return remoteDataSource.checkOut(stayId, accountId, notes: notes);
  }

  @override
  Future<List<Map<String, dynamic>>> getServiceUsages(int stayId) {
    return remoteDataSource.fetchServiceUsages(stayId);
  }

  @override
  Future<void> addServiceUsage({
    required int stayId,
    required int hotelServiceId,
    required double quantity,
    required int accountId,
    String? notes,
  }) async {
    await remoteDataSource.createServiceUsage(
      stayId: stayId,
      hotelServiceId: hotelServiceId,
      quantity: quantity,
      accountId: accountId,
      notes: notes,
    );
  }

  @override
  Future<void> checkOutAndPay({
    required int stayId,
    required String paymentMethod,
    int accountId = 2,
  }) async {
    // Quy trình thanh toán & check-out đầy đủ theo nghiệp vụ BE:
    // 1. Lập hóa đơn nháp (nếu chưa có)
    Map<String, dynamic> inv = await remoteDataSource.draftInvoice(stayId, accountId);
    int invoiceId = inv['id'] ?? inv['Id'] ?? 0;
    double total = (inv['totalAmount'] ?? inv['TotalAmount'] ?? 0).toDouble();

    // 2. Chốt hóa đơn
    if (invoiceId > 0) {
      await remoteDataSource.finalizeInvoice(stayId, accountId);
    }

    // 3. Ghi nhận thanh toán đủ
    if (invoiceId > 0 && total > 0) {
      int methodInt = paymentMethod.contains('Chuyển') ? 2 : (paymentMethod.contains('Thẻ') ? 3 : 1);
      await remoteDataSource.recordPayment(
        invoiceId: invoiceId,
        amount: total,
        method: methodInt,
        accountId: accountId,
        notes: 'Thanh toán qua app ($paymentMethod)',
      );
    }

    // 4. Trả phòng
    await remoteDataSource.checkOut(stayId, accountId, notes: 'Khách thanh toán qua $paymentMethod');
  }
}
