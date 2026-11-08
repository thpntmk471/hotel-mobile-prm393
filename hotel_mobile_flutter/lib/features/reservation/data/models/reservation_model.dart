import '../../domain/entities/reservation.dart';

class ReservationModel {
  final int numericId;
  final String reservationCode;
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
  final String rowVersion;

  ReservationModel({
    this.numericId = 0,
    this.reservationCode = '',
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
    this.rowVersion = '',
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    final rawNumId = json['id'] ?? json['Id'];
    final numId = rawNumId is int ? rawNumId : int.tryParse(rawNumId?.toString() ?? '') ?? 0;
    final resCode = (json['reservationCode'] ?? json['ReservationCode'] ?? '').toString();
    final idStr = resCode.isNotEmpty ? resCode : (numId > 0 ? numId.toString() : 'RSV${DateTime.now().millisecondsSinceEpoch}');

    final guestName = json['guestName'] ?? json['GuestName'] ?? json['customerName'] ?? 'Khách đặt phòng';
    final guestPhone = json['guestPhone'] ?? json['GuestPhone'] ?? json['phoneNumber'] ?? '0901234567';
    final rawRoomId = json['roomId'] ?? json['RoomId'] ?? 1;
    final roomId = rawRoomId is int ? rawRoomId : int.tryParse(rawRoomId.toString()) ?? 1;
    final roomNumber = json['roomNumber'] ?? json['RoomNumber'] ?? json['roomCode'] ?? json['RoomCode'] ?? 'DEV-101';
    final roomTypeName = json['roomTypeName'] ?? json['RoomTypeName'] ?? 'Phòng Standard';
    final pricePerNight = (json['pricePerNight'] ?? json['nightlyRate'] ?? json['NightlyRate'] ?? 450000).toDouble();
    final totalPrice = (json['totalPrice'] ?? json['totalAmount'] ?? json['TotalAmount'] ?? 450000).toDouble();
    final checkIn = DateTime.tryParse(json['checkInDate']?.toString() ?? '') ?? DateTime.now();
    final checkOut = DateTime.tryParse(json['checkOutDate']?.toString() ?? '') ??
        DateTime.now().add(const Duration(days: 1));
    final rawNumGuests = json['numberOfGuests'] ?? json['NumberOfGuests'] ?? 1;
    final numGuests = rawNumGuests is int ? rawNumGuests : int.tryParse(rawNumGuests.toString()) ?? 1;

    // Ánh xạ trạng thái byte của .NET (1: Chờ xử lý, 2: Đã xác nhận, 3: Đã nhận phòng, 4: Đã trả phòng, 5: Đã hủy)
    final rawStatus = json['status'] ?? json['Status'] ?? json['statusName'] ?? json['StatusName'];
    String statusStr = 'Đã xác nhận';
    if (rawStatus is int || (rawStatus != null && int.tryParse(rawStatus.toString()) != null)) {
      final sInt = rawStatus is int ? rawStatus : int.parse(rawStatus.toString());
      if (sInt == 1) {
        statusStr = 'Chờ xử lý';
      } else if (sInt == 2) {
        statusStr = 'Đã xác nhận';
      } else if (sInt == 3) {
        statusStr = 'Đã nhận phòng';
      } else if (sInt == 4) {
        statusStr = 'Đã trả phòng';
      } else if (sInt == 5) {
        statusStr = 'Đã hủy';
      }
    } else if (rawStatus != null) {
      statusStr = rawStatus.toString();
    }

    return ReservationModel(
      numericId: numId,
      reservationCode: resCode,
      id: idStr,
      guestName: guestName.toString(),
      guestPhone: guestPhone.toString(),
      guestIdCard: json['guestIdCard']?.toString(),
      roomId: roomId,
      roomNumber: roomNumber.toString(),
      roomTypeName: roomTypeName.toString(),
      pricePerNight: pricePerNight,
      checkInDate: checkIn,
      checkOutDate: checkOut,
      numberOfGuests: numGuests,
      totalPrice: totalPrice,
      status: statusStr,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      rowVersion: (json['rowVersion'] ?? json['RowVersion'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': numericId > 0 ? numericId : id,
      'reservationCode': reservationCode,
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
      'rowVersion': rowVersion,
    };
  }

  Reservation toEntity() {
    return Reservation(
      numericId: numericId,
      reservationCode: reservationCode,
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
      rowVersion: rowVersion,
    );
  }
}

