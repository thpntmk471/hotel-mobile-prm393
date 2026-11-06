import '../../domain/entities/reservation.dart';

class ReservationModel {
  final String id;
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
  final String status;
  final DateTime createdAt;

  ReservationModel({
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

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'] ?? json['reservationCode'] ?? 'RSV${DateTime.now().millisecondsSinceEpoch}',
      guestName: json['guestName'] ?? json['customerName'] ?? 'Khách Test',
      guestPhone: json['guestPhone'] ?? '0901234567',
      guestIdCard: json['guestIdCard'],
      roomId: json['roomId'] ?? 1,
      roomNumber: json['roomNumber'] ?? 'DEV-101',
      roomTypeName: json['roomTypeName'] ?? 'Phòng Standard',
      pricePerNight: (json['pricePerNight'] ?? 450000).toDouble(),
      checkInDate: DateTime.tryParse(json['checkInDate'] ?? '') ?? DateTime.now(),
      checkOutDate: DateTime.tryParse(json['checkOutDate'] ?? '') ??
          DateTime.now().add(const Duration(days: 1)),
      numberOfGuests: json['numberOfGuests'] ?? 1,
      totalPrice: (json['totalPrice'] ?? 450000).toDouble(),
      status: json['status'] ?? 'Đã xác nhận',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'guestName': guestName,
      'guestPhone': guestPhone,
      'guestIdCard': guestIdCard,
      'roomId': roomId,
      'roomNumber': roomNumber,
      'roomTypeName': roomTypeName,
      'pricePerNight': pricePerNight,
      'checkInDate': checkInDate.toIso8601String(),
      'checkOutDate': checkOutDate.toIso8601String(),
      'numberOfGuests': numberOfGuests,
      'totalPrice': totalPrice,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Reservation toEntity() {
    return Reservation(
      id: id,
      guestName: guestName,
      guestPhone: guestPhone,
      guestIdCard: guestIdCard,
      roomId: roomId,
      roomNumber: roomNumber,
      roomTypeName: roomTypeName,
      pricePerNight: pricePerNight,
      checkInDate: checkInDate,
      checkOutDate: checkOutDate,
      numberOfGuests: numberOfGuests,
      totalPrice: totalPrice,
      status: status,
      createdAt: createdAt,
    );
  }
}

