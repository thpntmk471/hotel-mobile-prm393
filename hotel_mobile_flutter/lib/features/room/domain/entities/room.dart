class Room {
  final int id;
  final String roomNumber;
  final int floor;
  final int roomTypeId;
  final String roomTypeName;
  final double pricePerNight;
  final String operationalStatus; // Hoạt động, Tạm khóa
  final String housekeepingStatus; // Sạch, Cần dọn, Đang dọn
  final int capacity; // Sức chứa tối đa (số người)

  const Room({
    required this.id,
    required this.roomNumber,
    required this.floor,
    required this.roomTypeId,
    required this.roomTypeName,
    required this.pricePerNight,
    required this.operationalStatus,
    required this.housekeepingStatus,
    this.capacity = 2,
  });

  int get maxGuests {
    if (capacity > 0) return capacity;
    final lower = roomTypeName.toLowerCase();
    if (lower.contains('vip') || lower.contains('suite') || lower.contains('fam')) {
      return 4;
    }
    return 2;
  }

  bool get isClean => housekeepingStatus == 'Sạch';
  bool get isDirty => housekeepingStatus == 'Cần dọn';
  bool get isActive => operationalStatus == 'Hoạt động';
}
