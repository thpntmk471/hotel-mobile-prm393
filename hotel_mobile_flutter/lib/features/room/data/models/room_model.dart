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

  RoomModel({
    required this.id,
    required this.roomNumber,
    required this.floor,
    required this.roomTypeId,
    required this.roomTypeName,
    required this.pricePerNight,
    required this.operationalStatus,
    required this.housekeepingStatus,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] ?? 0,
      roomNumber: json['roomNumber'] ?? json['roomCode'] ?? '',
      floor: json['floor'] ?? 1,
      roomTypeId: json['roomTypeId'] ?? 1,
      roomTypeName: json['roomTypeName'] ?? 'Phòng Standard',
      pricePerNight: (json['pricePerNight'] ?? json['price'] ?? 500000).toDouble(),
      operationalStatus: json['operationalStatus'] ?? 'Hoạt động',
      housekeepingStatus: json['housekeepingStatus'] ?? 'Sạch',
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
    );
  }
}
