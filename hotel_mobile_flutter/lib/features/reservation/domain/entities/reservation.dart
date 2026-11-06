class Reservation {
  final String id; // Mã đặt phòng: RSV...
  final String guestName;
  final String guestPhone;
  final String? guestIdCard;
  final int roomId;
  final String roomNumber;
  final String roomTypeName;
  final double pricePerNight;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int numberOfGuests;
  final double totalPrice;
  final String status; // Đã xác nhận, Đã nhận phòng, Đã trả phòng, Đã hủy
  final DateTime createdAt;

  const Reservation({
    required this.id,
    required this.guestName,
    required this.guestPhone,
    this.guestIdCard,
    required this.roomId,
    required this.roomNumber,
    required this.roomTypeName,
    required this.pricePerNight,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numberOfGuests,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  int get numberOfNights {
    final diff = checkOutDate.difference(checkInDate).inDays;
    return diff <= 0 ? 1 : diff;
  }

  bool get isConfirmed => status == 'Đã xác nhận';
  bool get isCheckedIn => status == 'Đã nhận phòng';
}

