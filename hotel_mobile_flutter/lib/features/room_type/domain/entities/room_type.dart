class RoomType {
  final int id;
  final String code;
  final String name;
  final String description;
  final int capacity;
  final double basePricePerNight;
  final String rowVersion;

  const RoomType({
    required this.id,
    required this.code,
    required this.name,
    this.description = '',
    required this.capacity,
    required this.basePricePerNight,
    this.rowVersion = '',
  });
}

