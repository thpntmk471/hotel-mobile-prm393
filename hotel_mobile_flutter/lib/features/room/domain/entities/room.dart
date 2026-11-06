class Room {
  final int id;
  final String roomNumber;
  final int floor;
  final int roomTypeId;
  final String roomTypeName;
  final double pricePerNight;
  final String operationalStatus; // Hoạt động, Tạm khóa
  final String housekeepingStatus; // Sạch, Cần dọn, Đang dọn

  const Room({
    required this.id,
    required this.roomNumber,
    required this.floor,
    required this.roomTypeId,
    required this.roomTypeName,
    required this.pricePerNight,
    required this.operationalStatus,
    required this.housekeepingStatus,
  });

  bool get isClean => housekeepingStatus == 'Sạch';
  bool get isActive => operationalStatus == 'Hoạt động';
}
