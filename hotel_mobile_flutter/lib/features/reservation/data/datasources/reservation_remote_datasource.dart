import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/reservation_model.dart';

abstract class ReservationRemoteDataSource {
  Future<List<ReservationModel>> fetchReservations();
  Future<ReservationModel> createReservation(Map<String, dynamic> payload);
  Future<void> updateStatus(String reservationId, String newStatus);
}

class ReservationRemoteDataSourceImpl implements ReservationRemoteDataSource {
  final Dio dio;

  ReservationRemoteDataSourceImpl(this.dio);

  // Mock data bám sát dữ liệu hiển thị trên Web Backend (PRN232)
  final List<ReservationModel> _mockReservations = [
    ReservationModel(
      id: 'RSV334E35DF4B',
      guestName: 'Khách Test F07',
      guestPhone: '0912345678',
      roomId: 1,
      roomNumber: 'F09TEST-101',
      roomTypeName: 'Phòng Standard',
      pricePerNight: 450000,
      checkInDate: DateTime.now().subtract(const Duration(days: 2)),
      checkOutDate: DateTime.now(),
      numberOfGuests: 1,
      totalPrice: 900000,
      status: 'Đã nhận phòng',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    ReservationModel(
      id: 'RSV5F939B8987',
      guestName: 'Khách Test F07',
      guestPhone: '0912345678',
      roomId: 5,
      roomNumber: 'DEV-301',
      roomTypeName: 'Phòng VIP Suite',
      pricePerNight: 1100000,
      checkInDate: DateTime.now().subtract(const Duration(days: 2)),
      checkOutDate: DateTime.now(),
      numberOfGuests: 1,
      totalPrice: 2200000,
      status: 'Đã trả phòng',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    ReservationModel(
      id: 'DEV-RES-004',
      guestName: 'Phạm Ngọc Mai',
      guestPhone: '0987654321',
      roomId: 4,
      roomNumber: 'DEV-202',
      roomTypeName: 'Phòng Deluxe',
      pricePerNight: 700000,
      checkInDate: DateTime.now().subtract(const Duration(days: 1)),
      checkOutDate: DateTime.now().add(const Duration(days: 1)),
      numberOfGuests: 2,
      totalPrice: 1400000,
      status: 'Đã xác nhận',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    ReservationModel(
      id: 'DEV-RES-003',
      guestName: 'Lê Quốc Bảo',
      guestPhone: '0933221100',
      roomId: 2,
      roomNumber: 'DEV-102',
      roomTypeName: 'Phòng Standard',
      pricePerNight: 450000,
      checkInDate: DateTime.now().subtract(const Duration(days: 2)),
      checkOutDate: DateTime.now(),
      numberOfGuests: 1,
      totalPrice: 900000,
      status: 'Đã xác nhận',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    ReservationModel(
      id: 'DEV-RES-002',
      guestName: 'Trần Thu Hà',
      guestPhone: '0944556677',
      roomId: 3,
      roomNumber: 'DEV-201',
      roomTypeName: 'Phòng Deluxe',
      pricePerNight: 700000,
      checkInDate: DateTime.now().subtract(const Duration(days: 7)),
      checkOutDate: DateTime.now().subtract(const Duration(days: 5)),
      numberOfGuests: 1,
      totalPrice: 1400000,
      status: 'Đã trả phòng',
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
  ];

  @override
  Future<List<ReservationModel>> fetchReservations() async {
    try {
      final response = await dio.get(ApiConstants.reservationService);
      if (response.data is List) {
        return (response.data as List)
            .map((e) => ReservationModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return _mockReservations;
    } catch (_) {
      return _mockReservations;
    }
  }

  @override
  Future<ReservationModel> createReservation(Map<String, dynamic> payload) async {
    try {
      final response = await dio.post(ApiConstants.reservationService, data: payload);
      final model = ReservationModel.fromJson(response.data as Map<String, dynamic>);
      _mockReservations.insert(0, model);
      return model;
    } catch (_) {
      final model = ReservationModel.fromJson(payload);
      _mockReservations.insert(0, model);
      return model;
    }
  }

  @override
  Future<void> updateStatus(String reservationId, String newStatus) async {
    try {
      await dio.put(
        '${ApiConstants.reservationService}/$reservationId/status',
        data: {'status': newStatus},
      );
    } catch (_) {
      final idx = _mockReservations.indexWhere((r) => r.id == reservationId);
      if (idx != -1) {
        final r = _mockReservations[idx];
        _mockReservations[idx] = ReservationModel(
          id: r.id,
          guestName: r.guestName,
          guestPhone: r.guestPhone,
          guestIdCard: r.guestIdCard,
          roomId: r.roomId,
          roomNumber: r.roomNumber,
          roomTypeName: r.roomTypeName,
          pricePerNight: r.pricePerNight,
          checkInDate: r.checkInDate,
          checkOutDate: r.checkOutDate,
          numberOfGuests: r.numberOfGuests,
          totalPrice: r.totalPrice,
          status: newStatus,
          createdAt: r.createdAt,
        );
      }
    }
  }
}
