import '../../domain/entities/guest.dart';

class GuestModel {
  final int id;
  final String fullName;
  final String phoneNumber;
  final String email;
  final String documentNumber;
  final String address;
  final String rowVersion;

  GuestModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.documentNumber,
    required this.address,
    required this.rowVersion,
  });

  factory GuestModel.fromJson(Map<String, dynamic> json) {
    return GuestModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'] ?? '',
      documentNumber: json['documentNumber'] ?? '',
      address: json['address'] ?? '',
      rowVersion: json['rowVersion'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'email': email,
        'documentNumber': documentNumber,
        'address': address,
        'rowVersion': rowVersion,
      };

  Guest toEntity() => Guest(
        id: id,
        fullName: fullName,
        phoneNumber: phoneNumber,
        email: email,
        documentNumber: documentNumber,
        address: address,
        rowVersion: rowVersion,
      );
}

