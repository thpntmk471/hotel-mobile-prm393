class InvoiceLine {
  final int id;
  final String description; // Ví dụ: Tiền phòng, Ăn sáng buffet, Dịch vụ giặt là
  final int quantity;
  final double unitPrice;
  final double lineTotal;

  const InvoiceLine({
    required this.id,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });
}

class StayServiceUsage {
  final int id;
  final int hotelServiceId;
  final String serviceName;
  final double quantity;
  final double unitPrice;
  final String unit;
  final DateTime usedAt;

  const StayServiceUsage({
    required this.id,
    required this.hotelServiceId,
    required this.serviceName,
    required this.quantity,
    required this.unitPrice,
    required this.unit,
    required this.usedAt,
  });

  double get totalPrice => quantity * unitPrice;
}

class Stay {
  final int id;
  final String stayCode; // STY-2026-001
  final String reservationId; // RSV...
  final int numericReservationId;
  final int roomId;
  final String guestName;
  final String guestPhone;
  final String roomNumber;
  final String roomTypeName;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final String status; // Đang lưu trú, Đã trả phòng
  final double roomTotal;
  final double serviceTotal;
  final double grandTotal;
  final bool isPaid;
  final int? invoiceId;
  final int invoiceStatus; // 0: Chưa lập, 1: Nháp, 2: Đã chốt
  final double paidAmount;
  final double remainingAmount;
  final List<InvoiceLine> invoiceLines;
  final List<StayServiceUsage> serviceUsages;

  const Stay({
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

  bool get isActive => status == 'Active' || status == 'Đang lưu trú';

  Stay copyWith({
    int? id,
    String? stayCode,
    String? reservationId,
    int? numericReservationId,
    int? roomId,
    String? guestName,
    String? guestPhone,
    String? roomNumber,
    String? roomTypeName,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    String? status,
    double? roomTotal,
    double? serviceTotal,
    double? grandTotal,
    bool? isPaid,
    int? invoiceId,
    int? invoiceStatus,
    double? paidAmount,
    double? remainingAmount,
    List<InvoiceLine>? invoiceLines,
    List<StayServiceUsage>? serviceUsages,
  }) {
    return Stay(
      id: id ?? this.id,
      stayCode: stayCode ?? this.stayCode,
      reservationId: reservationId ?? this.reservationId,
      numericReservationId: numericReservationId ?? this.numericReservationId,
      roomId: roomId ?? this.roomId,
      guestName: guestName ?? this.guestName,
      guestPhone: guestPhone ?? this.guestPhone,
      roomNumber: roomNumber ?? this.roomNumber,
      roomTypeName: roomTypeName ?? this.roomTypeName,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      status: status ?? this.status,
      roomTotal: roomTotal ?? this.roomTotal,
      serviceTotal: serviceTotal ?? this.serviceTotal,
      grandTotal: grandTotal ?? this.grandTotal,
      isPaid: isPaid ?? this.isPaid,
      invoiceId: invoiceId ?? this.invoiceId,
      invoiceStatus: invoiceStatus ?? this.invoiceStatus,
      paidAmount: paidAmount ?? this.paidAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      invoiceLines: invoiceLines ?? this.invoiceLines,
      serviceUsages: serviceUsages ?? this.serviceUsages,
    );
  }
}
