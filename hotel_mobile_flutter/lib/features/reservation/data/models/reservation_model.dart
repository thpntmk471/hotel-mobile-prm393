import '../../domain/entities/reservation.dart';

class ReservationModel {
  final int numericId;
  final String reservationCode;
  final String id;
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
  final String status;
  final DateTime createdAt;
  final String rowVersion;
  final String? notes;

  ReservationModel({
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

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    final rawNumId = json['id'] ?? json['Id'];
    final numId = rawNumId is int ? rawNumId : int.tryParse(rawNumId?.toString() ?? '') ?? 0;
    final resCode = (json['reservationCode'] ?? json['ReservationCode'] ?? '').toString();
    final idStr = resCode.isNotEmpty ? resCode : (numId > 0 ? numId.toString() : 'RSV${DateTime.now().millisecondsSinceEpoch}');

    final rawGuestId = json['guestId'] ?? json['GuestId'] ?? 0;
    final parsedGuestId = rawGuestId is int ? rawGuestId : int.tryParse(rawGuestId.toString()) ?? 0;

    final rawRoomId = json['roomId'] ?? json['RoomId'] ?? 0;
    final roomId = rawRoomId is int ? rawRoomId : int.tryParse(rawRoomId.toString()) ?? 0;

    final notes = (json['notes'] ?? json['Notes'])?.toString();

    // Tự động phân tích trường notes nếu chứa thông tin dự phòng "Khách: ... - SĐT: ... - CCCD: ..."
    String parsedGuestName = '';
    String parsedGuestPhone = '';
    String? parsedGuestIdCard;
    if (notes != null && notes.contains('Khách:')) {
      final reg = RegExp(r'Khách:\s*([^-]+)(?:\s*-\s*SĐT:\s*([^-]+))?(?:\s*-\s*CCCD:\s*(.+))?');
      final match = reg.firstMatch(notes);
      if (match != null) {
        parsedGuestName = match.group(1)?.trim() ?? '';
        parsedGuestPhone = match.group(2)?.trim() ?? '';
        parsedGuestIdCard = match.group(3)?.trim();
      }
    }

    final rawGuestName = json['guestName'] ?? json['GuestName'] ?? json['customerName'];
    final guestName = rawGuestName != null && rawGuestName.toString().isNotEmpty
        ? rawGuestName.toString()
        : (parsedGuestName.isNotEmpty ? parsedGuestName : 'Khách #${parsedGuestId > 0 ? parsedGuestId : numId}');

    final rawGuestPhone = json['guestPhone'] ?? json['GuestPhone'] ?? json['phoneNumber'];
    final guestPhone = rawGuestPhone != null && rawGuestPhone.toString().isNotEmpty
        ? rawGuestPhone.toString()
        : (parsedGuestPhone.isNotEmpty ? parsedGuestPhone : 'Chưa có SĐT');

    final rawRoomNumber = json['roomNumber'] ?? json['RoomNumber'] ?? json['roomCode'] ?? json['RoomCode'];
    final roomNumber = rawRoomNumber != null && rawRoomNumber.toString().isNotEmpty
        ? rawRoomNumber.toString()
        : (roomId > 0 ? 'Phòng #$roomId' : 'Chưa xếp phòng');

    final rawRoomTypeName = json['roomTypeName'] ?? json['RoomTypeName'];
    final roomTypeName = rawRoomTypeName != null && rawRoomTypeName.toString().isNotEmpty
        ? rawRoomTypeName.toString()
        : 'Phòng tiêu chuẩn';

    final pricePerNight = (json['pricePerNight'] ?? json['nightlyRate'] ?? json['NightlyRate'] ?? 0).toDouble();
    final totalPrice = (json['totalPrice'] ?? json['totalAmount'] ?? json['TotalAmount'] ?? 0).toDouble();
    final checkIn = DateTime.tryParse(json['checkInDate']?.toString() ?? '') ?? DateTime.now();
    final checkOut = DateTime.tryParse(json['checkOutDate']?.toString() ?? '') ??
        DateTime.now().add(const Duration(days: 1));
    final rawNumGuests = json['numberOfGuests'] ?? json['NumberOfGuests'] ?? 1;
    final numGuests = rawNumGuests is int ? rawNumGuests : int.tryParse(rawNumGuests.toString()) ?? 1;

    // Ánh xạ trạng thái byte của .NET Backend ReservationStatus:
    // Confirmed = 1, CheckedIn = 2, Completed = 3, Cancelled = 4, NoShow = 5
    final rawStatus = json['status'] ?? json['Status'] ?? json['statusName'] ?? json['StatusName'];
    String statusStr = 'Đã xác nhận';
    if (rawStatus is int || (rawStatus != null && int.tryParse(rawStatus.toString()) != null)) {
      final sInt = rawStatus is int ? rawStatus : int.parse(rawStatus.toString());
      switch (sInt) {
        case 1:
          statusStr = 'Đã xác nhận';
          break;
        case 2:
          statusStr = 'Đã nhận phòng';
          break;
        case 3:
          statusStr = 'Đã trả phòng';
          break;
        case 4:
          statusStr = 'Đã hủy';
          break;
        case 5:
          statusStr = 'Vắng mặt';
          break;
        default:
          statusStr = 'Đã xác nhận';
      }
    } else if (rawStatus != null) {
      final sStr = rawStatus.toString().toLowerCase();
      if (sStr.contains('confirm')) {
        statusStr = 'Đã xác nhận';
      } else if (sStr.contains('checkin') || sStr.contains('checkedin')) {
        statusStr = 'Đã nhận phòng';
      } else if (sStr.contains('complet') || sStr.contains('checkout')) {
        statusStr = 'Đã trả phòng';
      } else if (sStr.contains('cancel')) {
        statusStr = 'Đã hủy';
      } else if (sStr.contains('noshow')) {
        statusStr = 'Vắng mặt';
      } else {
        statusStr = rawStatus.toString();
      }
    }

    return ReservationModel(
      numericId: numId,
      reservationCode: resCode,
      id: idStr,
      guestId: parsedGuestId,
      guestName: guestName,
      guestPhone: guestPhone,
      guestIdCard: json['guestIdCard']?.toString() ?? parsedGuestIdCard,
      roomId: roomId,
      roomNumber: roomNumber,
      roomTypeName: roomTypeName,
      pricePerNight: pricePerNight,
      checkInDate: checkIn,
      checkOutDate: checkOut,
      numberOfGuests: numGuests,
      totalPrice: totalPrice,
      status: statusStr,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      rowVersion: (json['rowVersion'] ?? json['RowVersion'] ?? '').toString(),
      notes: notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': numericId > 0 ? numericId : id,
      'reservationCode': reservationCode,
      'guestId': guestId,
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
      'notes': notes,
    };
  }

  Reservation toEntity() {
    return Reservation(
      numericId: numericId,
      reservationCode: reservationCode,
      id: id,
      guestId: guestId,
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
      notes: notes,
    );
  }
}
