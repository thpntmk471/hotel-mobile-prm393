import '../entities/reservation.dart';

abstract class ReservationRepository {
  Future<List<Reservation>> getReservations({String? search, String? status});
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
  });
  Future<void> updateStatus(String reservationId, String newStatus);
}

