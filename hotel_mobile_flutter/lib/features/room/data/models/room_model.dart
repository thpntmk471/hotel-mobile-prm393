import '../../domain/entities/room.dart';

class RoomModel {
  final int id;
  final String roomNumber;
  final int floor;
  final int roomTypeId;
  final String roomTypeName;
  final double pricePerNight;
  final String operationalStatus;
  final String housekeepingStatus;
  final int capacity;
  final String rowVersion;

  RoomModel({
    required this.id,
    required this.roomNumber,
    required this.floor,
    required this.roomTypeId,
    required this.roomTypeName,
    required this.pricePerNight,
    required this.operationalStatus,
    required this.housekeepingStatus,
    this.capacity = 2,
    this.rowVersion = '',
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    final typeName = (json['roomTypeName'] ?? json['RoomTypeName'] ?? json['type'] ?? 'Phòng Standard').toString();
    final cap = json['capacity'] ?? json['maxGuests'] ?? (typeName.toLowerCase().contains('suite') || typeName.toLowerCase().contains('fam') ? 4 : 2);

    // Chuyển đổi HousekeepingStatus từ byte của .NET Backend:
    // 1: Cần dọn (Dirty), 2: Đang dọn (InProgress), 3: Sạch (Clean), 4: Đã kiểm tra (Inspected)
    final rawHk = json['housekeepingStatus'] ?? json['HousekeepingStatus'];
    String hkStatus = 'Sạch';
    if (rawHk is int || (rawHk != null && int.tryParse(rawHk.toString()) != null)) {
      final hkInt = rawHk is int ? rawHk : int.parse(rawHk.toString());
      if (hkInt == 1) {
        hkStatus = 'Cần dọn';
      } else if (hkInt == 2) {
        hkStatus = 'Đang dọn';
      } else if (hkInt == 3) {
        hkStatus = 'Sạch';
      } else if (hkInt == 4) {
        hkStatus = 'Đã kiểm tra';
      } else {
        hkStatus = 'Sạch';
      }
    } else if (rawHk != null) {
      hkStatus = rawHk.toString();
    }

    // Chuyển đổi OperationalStatus từ byte của .NET (1: Hoạt động, 2: Tạm khóa)
    final rawOp = json['operationalStatus'] ?? json['OperationalStatus'];
    String opStatus = 'Hoạt động';
    if (rawOp == 2 || rawOp == '2' || rawOp == 'Tạm khóa') {
      opStatus = 'Tạm khóa';
    }

    return RoomModel(
      id: json['id'] ?? json['Id'] ?? 0,
      roomNumber: json['roomNumber'] ?? json['RoomCode'] ?? json['roomCode'] ?? '',
      floor: json['floor'] ?? json['FloorNumber'] ?? json['floorNumber'] ?? 1,
      roomTypeId: json['roomTypeId'] ?? json['RoomTypeId'] ?? 1,
      roomTypeName: typeName,
      pricePerNight: (json['pricePerNight'] ?? json['price'] ?? json['basePricePerNight'] ?? 
          (typeName.toLowerCase().contains('suite') || typeName.toLowerCase().contains('fam') ? 1100000 : 
           typeName.toLowerCase().contains('deluxe') ? 700000 : 450000)).toDouble(),
      operationalStatus: opStatus,
      housekeepingStatus: hkStatus,
      capacity: cap is int ? cap : int.tryParse(cap.toString()) ?? 2,
      rowVersion: (json['rowVersion'] ?? json['RowVersion'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomNumber': roomNumber,
      'floor': floor,
      'roomTypeId': roomTypeId,
      'roomTypeName': roomTypeName,
      'pricePerNight': pricePerNight,
      'operationalStatus': operationalStatus,
      'housekeepingStatus': housekeepingStatus,
      'capacity': capacity,
      'rowVersion': rowVersion,
    };
  }

  Room toEntity() {
    return Room(
      id: id,
      roomNumber: roomNumber,
      floor: floor,
      roomTypeId: roomTypeId,
      roomTypeName: roomTypeName,
      pricePerNight: pricePerNight,
      operationalStatus: operationalStatus,
      housekeepingStatus: housekeepingStatus,
      capacity: capacity,
      rowVersion: rowVersion,
    );
  }
}
