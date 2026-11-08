import '../../domain/entities/room_type.dart';

class RoomTypeModel {
  final int id;
  final String code;
  final String name;
  final String description;
  final int capacity;
  final double basePricePerNight;
  final String rowVersion;

  RoomTypeModel({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.capacity,
    required this.basePricePerNight,
    required this.rowVersion,
  });

  factory RoomTypeModel.fromJson(Map<String, dynamic> json) {
    return RoomTypeModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      capacity: json['capacity'] is int ? json['capacity'] : int.tryParse(json['capacity']?.toString() ?? '2') ?? 2,
      basePricePerNight: (json['basePricePerNight'] is num)
          ? (json['basePricePerNight'] as num).toDouble()
          : double.tryParse(json['basePricePerNight']?.toString() ?? '0') ?? 0.0,
      rowVersion: json['rowVersion'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'description': description,
        'capacity': capacity,
        'basePricePerNight': basePricePerNight,
        'rowVersion': rowVersion,
      };

  RoomType toEntity() => RoomType(
        id: id,
        code: code,
        name: name,
        description: description,
        capacity: capacity,
        basePricePerNight: basePricePerNight,
        rowVersion: rowVersion,
      );
}

