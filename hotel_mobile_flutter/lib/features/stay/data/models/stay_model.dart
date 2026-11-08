import '../../domain/entities/stay.dart';

class InvoiceLineModel {
  final int id;
  final String description;
  final int quantity;
  final double unitPrice;
  final double lineTotal;

  InvoiceLineModel({
    required this.id,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  factory InvoiceLineModel.fromJson(Map<String, dynamic> json) {
    return InvoiceLineModel(
      id: json['id'] ?? 0,
      description: json['description'] ?? 'Khoản mục',
      quantity: json['quantity'] ?? 1,
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      lineTotal: (json['lineTotal'] ?? json['totalPrice'] ?? 0).toDouble(),
    );
  }

  InvoiceLine toEntity() => InvoiceLine(
        id: id,
        description: description,
        quantity: quantity,
        unitPrice: unitPrice,
        lineTotal: lineTotal,
      );
}

class StayModel {
  final int id;
  final String stayCode;
  final String reservationId;
  final String guestName;
  final String roomNumber;
  final String roomTypeName;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final String status;
  final double roomTotal;
  final double serviceTotal;
  final double grandTotal;
  final bool isPaid;
  final List<InvoiceLineModel> invoiceLines;

  StayModel({
    required this.id,
    required this.stayCode,
    required this.reservationId,
    required this.guestName,
    required this.roomNumber,
    required this.roomTypeName,
    required this.checkInTime,
    this.checkOutTime,
    required this.status,
    required this.roomTotal,
    required this.serviceTotal,
    required this.grandTotal,
    required this.isPaid,
    this.invoiceLines = const [],
  });

  factory StayModel.fromJson(Map<String, dynamic> json) {
    var rawLines = json['invoiceLines'] as List? ?? [];
    final rawId = json['id'] ?? json['Id'] ?? 1;
    final stayId = rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 1;
    final resId = json['reservationId'] ?? json['ReservationId'] ?? '';
    final code = json['stayCode'] ?? json['StayCode'] ?? 'STY-2026-$stayId';
    final rNum = json['roomNumber'] ?? json['RoomNumber'] ?? (json['roomId'] != null ? 'DEV-${json['roomId']}' : 'DEV-101');
    final typeName = json['roomTypeName'] ?? json['RoomTypeName'] ?? 'Phòng Standard';
    final gName = json['guestName'] ?? json['GuestName'] ?? 'Khách lưu trú';

    final inTime = DateTime.tryParse(
            json['checkedInAt']?.toString() ?? json['checkInTime']?.toString() ?? '') ??
        DateTime.now();
    final outTimeStr = json['checkedOutAt'] ?? json['checkOutTime'];
    final outTime = outTimeStr != null ? DateTime.tryParse(outTimeStr.toString()) : null;

    final isActive = json['isActive'] == true || json['IsActive'] == true;
    final statusStr = isActive ? 'Đang lưu trú' : (json['status']?.toString() ?? 'Đã trả phòng');

    return StayModel(
      id: stayId,
      stayCode: code.toString(),
      reservationId: resId.toString(),
      guestName: gName.toString(),
      roomNumber: rNum.toString(),
      roomTypeName: typeName.toString(),
      checkInTime: inTime,
      checkOutTime: outTime,
      status: statusStr,
      roomTotal: (json['roomTotal'] ?? 900000).toDouble(),
      serviceTotal: (json['serviceTotal'] ?? 150000).toDouble(),
      grandTotal: (json['grandTotal'] ?? 1050000).toDouble(),
      isPaid: json['isPaid'] ?? !isActive,
      invoiceLines: rawLines.map((e) => InvoiceLineModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Stay toEntity() {
    return Stay(
      id: id,
      stayCode: stayCode,
      reservationId: reservationId,
      guestName: guestName,
      roomNumber: roomNumber,
      roomTypeName: roomTypeName,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
      status: status,
      roomTotal: roomTotal,
      serviceTotal: serviceTotal,
      grandTotal: grandTotal,
      isPaid: isPaid,
      invoiceLines: invoiceLines.map((l) => l.toEntity()).toList(),
    );
  }
}

