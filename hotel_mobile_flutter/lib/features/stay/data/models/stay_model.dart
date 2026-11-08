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
      id: json['id'] ?? json['Id'] ?? 0,
      description: json['description'] ?? json['Description'] ?? 'Khoản mục',
      quantity: (json['quantity'] ?? json['Quantity'] ?? 1) is int
          ? (json['quantity'] ?? json['Quantity'] ?? 1)
          : (double.tryParse((json['quantity'] ?? json['Quantity']).toString())?.toInt() ?? 1),
      unitPrice: (json['unitPrice'] ?? json['UnitPrice'] ?? 0).toDouble(),
      lineTotal: (json['amount'] ?? json['Amount'] ?? json['lineTotal'] ?? json['totalPrice'] ?? 0).toDouble(),
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

class StayServiceUsageModel {
  final int id;
  final int hotelServiceId;
  final String serviceName;
  final double quantity;
  final double unitPrice;
  final String unit;
  final DateTime usedAt;

  StayServiceUsageModel({
    required this.id,
    required this.hotelServiceId,
    required this.serviceName,
    required this.quantity,
    required this.unitPrice,
    required this.unit,
    required this.usedAt,
  });

  factory StayServiceUsageModel.fromJson(Map<String, dynamic> json) {
    return StayServiceUsageModel(
      id: json['id'] ?? json['Id'] ?? 0,
      hotelServiceId: json['hotelServiceId'] ?? json['HotelServiceId'] ?? 0,
      serviceName: (json['serviceNameSnapshot'] ?? json['ServiceNameSnapshot'] ?? json['serviceName'] ?? 'Dịch vụ').toString(),
      quantity: (json['quantity'] ?? json['Quantity'] ?? 1).toDouble(),
      unitPrice: (json['unitPrice'] ?? json['UnitPrice'] ?? 0).toDouble(),
      unit: (json['unitSnapshot'] ?? json['UnitSnapshot'] ?? json['unit'] ?? '').toString(),
      usedAt: DateTime.tryParse(json['usedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  StayServiceUsage toEntity() => StayServiceUsage(
        id: id,
        hotelServiceId: hotelServiceId,
        serviceName: serviceName,
        quantity: quantity,
        unitPrice: unitPrice,
        unit: unit,
        usedAt: usedAt,
      );
}

class StayModel {
  final int id;
  final String stayCode;
  final String reservationId;
  final int numericReservationId;
  final int roomId;
  final String guestName;
  final String guestPhone;
  final String roomNumber;
  final String roomTypeName;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final String status;
  final double roomTotal;
  final double serviceTotal;
  final double grandTotal;
  final bool isPaid;
  final int? invoiceId;
  final int invoiceStatus;
  final double paidAmount;
  final double remainingAmount;
  final List<InvoiceLineModel> invoiceLines;
  final List<StayServiceUsageModel> serviceUsages;

  StayModel({
    required this.id,
    required this.stayCode,
    required this.reservationId,
    this.numericReservationId = 0,
    this.roomId = 0,
    required this.guestName,
    this.guestPhone = '',
    required this.roomNumber,
    required this.roomTypeName,
    required this.checkInTime,
    this.checkOutTime,
    required this.status,
    required this.roomTotal,
    required this.serviceTotal,
    required this.grandTotal,
    required this.isPaid,
    this.invoiceId,
    this.invoiceStatus = 0,
    this.paidAmount = 0,
    this.remainingAmount = 0,
    this.invoiceLines = const [],
    this.serviceUsages = const [],
  });

  factory StayModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['Id'] ?? 0;
    final stayId = rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0;

    final rawResId = json['reservationId'] ?? json['ReservationId'];
    final parsedResNum = rawResId is int ? rawResId : int.tryParse(rawResId?.toString() ?? '') ?? 0;
    final resIdStr = parsedResNum > 0 ? 'RSV#$parsedResNum' : (rawResId?.toString() ?? '');

    final code = (json['stayCode'] ?? json['StayCode'] ?? 'STY-$stayId').toString();
    final rawRoomId = json['roomId'] ?? json['RoomId'] ?? 0;
    final parsedRoomId = rawRoomId is int ? rawRoomId : int.tryParse(rawRoomId.toString()) ?? 0;

    final inTime = DateTime.tryParse(
            json['checkedInAt']?.toString() ?? json['checkInTime']?.toString() ?? '') ??
        DateTime.now();
    final outTimeStr = json['checkedOutAt'] ?? json['checkOutTime'];
    final outTime = outTimeStr != null ? DateTime.tryParse(outTimeStr.toString()) : null;

    final bool isActive = json['isActive'] == true || json['IsActive'] == true || (outTime == null && json['checkedOutAt'] == null);
    final statusStr = isActive ? 'Đang lưu trú' : 'Đã trả phòng';

    // Xử lý thông tin Invoice nếu có đi kèm trong StayDetailDto
    final invMap = json['invoice'] ?? json['Invoice'];
    int? parsedInvId;
    int parsedInvStatus = 0;
    double parsedGrandTotal = 0;
    double parsedPaidAmount = 0;
    double parsedRemainingAmount = 0;
    List<InvoiceLineModel> lines = [];

    if (invMap is Map<String, dynamic>) {
      parsedInvId = invMap['id'] ?? invMap['Id'];
      parsedInvStatus = invMap['status'] ?? invMap['Status'] ?? 0;
      parsedGrandTotal = (invMap['totalAmount'] ?? invMap['TotalAmount'] ?? 0).toDouble();
      parsedPaidAmount = (invMap['paidAmount'] ?? invMap['PaidAmount'] ?? 0).toDouble();
      parsedRemainingAmount = (invMap['remainingAmount'] ?? invMap['RemainingAmount'] ?? 0).toDouble();

      final rawLines = (invMap['lines'] ?? invMap['Lines']) as List? ?? [];
      lines = rawLines.map((e) => InvoiceLineModel.fromJson(e as Map<String, dynamic>)).toList();
    }

    // Nếu có invoiceLines trực tiếp
    if (lines.isEmpty && json['invoiceLines'] is List) {
      lines = (json['invoiceLines'] as List)
          .map((e) => InvoiceLineModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Danh sách dịch vụ sử dụng
    final rawUsages = (json['serviceUsages'] ?? json['ServiceUsages']) as List? ?? [];
    final usages = rawUsages
        .map((e) => StayServiceUsageModel.fromJson(e as Map<String, dynamic>))
        .toList();

    double calculatedServiceTotal = 0;
    for (final u in usages) {
      calculatedServiceTotal += (u.quantity * u.unitPrice);
    }

    final bool isSettled = parsedRemainingAmount == 0 && parsedPaidAmount > 0;

    return StayModel(
      id: stayId,
      stayCode: code,
      reservationId: resIdStr,
      numericReservationId: parsedResNum,
      roomId: parsedRoomId,
      guestName: (json['guestName'] ?? json['GuestName'] ?? 'Khách lưu trú').toString(),
      guestPhone: (json['guestPhone'] ?? json['GuestPhone'] ?? '').toString(),
      roomNumber: (json['roomNumber'] ?? json['RoomNumber'] ?? (parsedRoomId > 0 ? 'Phòng #$parsedRoomId' : '')).toString(),
      roomTypeName: (json['roomTypeName'] ?? json['RoomTypeName'] ?? 'Phòng tiêu chuẩn').toString(),
      checkInTime: inTime,
      checkOutTime: outTime,
      status: statusStr,
      roomTotal: (json['roomTotal'] ?? (parsedGrandTotal > 0 ? (parsedGrandTotal - calculatedServiceTotal) : 0)).toDouble(),
      serviceTotal: (json['serviceTotal'] ?? calculatedServiceTotal).toDouble(),
      grandTotal: parsedGrandTotal > 0 ? parsedGrandTotal : (json['grandTotal'] ?? 0).toDouble(),
      isPaid: isSettled || !isActive,
      invoiceId: parsedInvId,
      invoiceStatus: parsedInvStatus,
      paidAmount: parsedPaidAmount,
      remainingAmount: parsedRemainingAmount,
      invoiceLines: lines,
      serviceUsages: usages,
    );
  }

  Stay toEntity() {
    return Stay(
      id: id,
      stayCode: stayCode,
      reservationId: reservationId,
      numericReservationId: numericReservationId,
      roomId: roomId,
      guestName: guestName,
      guestPhone: guestPhone,
      roomNumber: roomNumber,
      roomTypeName: roomTypeName,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
      status: status,
      roomTotal: roomTotal,
      serviceTotal: serviceTotal,
      grandTotal: grandTotal,
      isPaid: isPaid,
      invoiceId: invoiceId,
      invoiceStatus: invoiceStatus,
      paidAmount: paidAmount,
      remainingAmount: remainingAmount,
      invoiceLines: invoiceLines.map((l) => l.toEntity()).toList(),
      serviceUsages: serviceUsages.map((u) => u.toEntity()).toList(),
    );
  }
}
