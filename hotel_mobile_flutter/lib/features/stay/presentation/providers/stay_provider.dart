import 'package:flutter/foundation.dart';
import '../../domain/entities/stay.dart';
import '../../domain/repositories/stay_repository.dart';

class StayProvider extends ChangeNotifier {
  final StayRepository stayRepository;

  StayProvider({required this.stayRepository});

  List<Stay> _stays = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _searchQuery = '';
  String _selectedStatus = 'Tất cả';

  List<Stay> get stays => _stays;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedStatus => _selectedStatus;

  Future<void> fetchStays() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _stays = await stayRepository.getStays(
        search: _searchQuery,
        status: _selectedStatus,
      );
    } catch (e) {
      _errorMessage = 'Không thể nạp danh sách lưu trú: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchStays();
  }

  void setStatusFilter(String status) {
    _selectedStatus = status;
    fetchStays();
  }

  Future<Stay?> getStayById(int stayId) async {
    try {
      return await stayRepository.getStayById(stayId);
    } catch (e) {
      _errorMessage = 'Không thể lấy thông tin lưu trú #$stayId: $e';
      return null;
    }
  }

  Future<bool> checkIn({
    required int reservationId,
    required int accountId,
    String? notes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await stayRepository.checkIn(
        reservationId: reservationId,
        accountId: accountId,
        notes: notes,
      );
      await fetchStays();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>?> draftInvoice(int stayId, int accountId, {String? notes}) async {
    try {
      final res = await stayRepository.draftInvoice(stayId, accountId, notes: notes);
      await fetchStays();
      return res;
    } catch (e) {
      _errorMessage = 'Lỗi lập hóa đơn nháp: $e';
      notifyListeners();
      return null;
    }
  }

  Future<bool> finalizeInvoice(int stayId, int accountId) async {
    try {
      await stayRepository.finalizeInvoice(stayId, accountId);
      await fetchStays();
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi chốt hóa đơn: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> recordPayment({
    required int invoiceId,
    required double amount,
    required int method,
    required int accountId,
    String? notes,
  }) async {
    try {
      await stayRepository.recordPayment(
        invoiceId: invoiceId,
        amount: amount,
        method: method,
        accountId: accountId,
        notes: notes,
      );
      await fetchStays();
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi ghi nhận thanh toán: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> checkOut(int stayId, int accountId, {String? notes}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await stayRepository.checkOut(stayId, accountId, notes: notes);
      await fetchStays();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getServiceUsages(int stayId) async {
    try {
      return await stayRepository.getServiceUsages(stayId);
    } catch (e) {
      return [];
    }
  }

  Future<bool> addServiceUsage({
    required int stayId,
    required int hotelServiceId,
    required double quantity,
    required int accountId,
    String? notes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await stayRepository.addServiceUsage(
        stayId: stayId,
        hotelServiceId: hotelServiceId,
        quantity: quantity,
        accountId: accountId,
        notes: notes,
      );
      // Tự động tính lại hóa đơn nháp sau khi thêm dịch vụ
      await stayRepository.draftInvoice(stayId, accountId);
      await fetchStays();
      return true;
    } catch (e) {
      _errorMessage = 'Không thể thêm dịch vụ: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> checkOutAndPay(int stayId, String paymentMethod, {int accountId = 2}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await stayRepository.checkOutAndPay(
        stayId: stayId,
        paymentMethod: paymentMethod,
        accountId: accountId,
      );
      await fetchStays();
    } catch (e) {
      _errorMessage = 'Lỗi trả phòng: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
