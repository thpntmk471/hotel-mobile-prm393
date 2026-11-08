import '../entities/stay.dart';

abstract class StayRepository {
  Future<List<Stay>> getStays({String? search, String? status});
  Future<Stay> getStayById(int stayId);
  Future<Stay> checkIn({
    required int reservationId,
    required int accountId,
    String? notes,
  });
  Future<Map<String, dynamic>?> getStayDetail(int stayId);
  Future<Map<String, dynamic>> draftInvoice(int stayId, int accountId, {String? notes});
  Future<Map<String, dynamic>> finalizeInvoice(int stayId, int accountId);
  Future<Map<String, dynamic>> recordPayment({
    required int invoiceId,
    required double amount,
    required int method,
    required int accountId,
    String? notes,
  });
  Future<void> checkOut(int stayId, int accountId, {String? notes});
  Future<List<Map<String, dynamic>>> getServiceUsages(int stayId);
  Future<void> addServiceUsage({
    required int stayId,
    required int hotelServiceId,
    required double quantity,
    required int accountId,
    String? notes,
  });
  Future<void> checkOutAndPay({
    required int stayId,
    required String paymentMethod,
    int accountId = 2,
  });
}
