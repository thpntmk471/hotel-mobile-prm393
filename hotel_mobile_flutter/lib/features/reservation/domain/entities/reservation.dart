class Reservation {
  final int numericId;
  final String reservationCode;
  final String id; // Mã đặt phòng: DEV-RES... hoặc số ID
  final int guestId;
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
  final String rowVersion;
  final String? notes;

  const Reservation({
    this.numericId = 0,
    this.reservationCode = '',
    required this.id,
    this.guestId = 0,
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
    this.rowVersion = '',
    this.notes,
  });

  int get numberOfNights {
    final diff = checkOutDate.difference(checkInDate).inDays;
    return diff <= 0 ? 1 : diff;
  }

  bool get isConfirmed => status == 'Đã xác nhận';
  bool get isCheckedIn => status == 'Đã nhận phòng';

  Reservation copyWith({
    int? numericId,
    String? reservationCode,
    String? id,
    int? guestId,
    String? guestName,
    String? guestPhone,
    String? guestIdCard,
    int? roomId,
    String? roomNumber,
    String? roomTypeName,
    double? pricePerNight,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? numberOfGuests,
    double? totalPrice,
    String? status,
    DateTime? createdAt,
    String? rowVersion,
    String? notes,
  }) {
    return Reservation(
      numericId: numericId ?? this.numericId,
      reservationCode: reservationCode ?? this.reservationCode,
      id: id ?? this.id,
      guestId: guestId ?? this.guestId,
      guestName: guestName ?? this.guestName,
      guestPhone: guestPhone ?? this.guestPhone,
      guestIdCard: guestIdCard ?? this.guestIdCard,
      roomId: roomId ?? this.roomId,
      roomNumber: roomNumber ?? this.roomNumber,
      roomTypeName: roomTypeName ?? this.roomTypeName,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      numberOfGuests: numberOfGuests ?? this.numberOfGuests,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      rowVersion: rowVersion ?? this.rowVersion,
      notes: notes ?? this.notes,
    );
  }
}
