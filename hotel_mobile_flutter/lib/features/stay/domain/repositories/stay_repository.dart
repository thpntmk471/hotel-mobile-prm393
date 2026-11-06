import '../entities/stay.dart';

abstract class StayRepository {
  Future<List<Stay>> getStays({String? search, String? status});
  Future<Stay> getStayById(int stayId);
  Future<Stay> checkInFromReservation({
    required String reservationId,
    required String guestName,
    required String roomNumber,
    required String roomTypeName,
    required double roomTotal,
  });
  Future<void> checkOutAndPay({
    required int stayId,
    required String paymentMethod, // Tiền mặt, Chuyển khoản / VNPay, Thẻ tín dụng
  });
}
