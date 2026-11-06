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

class Stay {
  final int id;
  final String stayCode; // STY-2026-001
  final String reservationId; // RSV...
  final String guestName;
  final String roomNumber;
  final String roomTypeName;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final String status; // Active (Đang lưu trú), Completed (Đã thanh toán & trả phòng)
  final double roomTotal;
  final double serviceTotal;
  final double grandTotal;
  final bool isPaid;
  final List<InvoiceLine> invoiceLines;

  const Stay({
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

  bool get isActive => status == 'Active' || status == 'Đang lưu trú';
}
