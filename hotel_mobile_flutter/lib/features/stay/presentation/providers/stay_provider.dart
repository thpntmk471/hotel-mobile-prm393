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

  Future<bool> checkInFromReservation({
    required String reservationId,
    required String guestName,
    required String roomNumber,
    required String roomTypeName,
    required double roomTotal,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await stayRepository.checkInFromReservation(
        reservationId: reservationId,
        guestName: guestName,
        roomNumber: roomNumber,
        roomTypeName: roomTypeName,
        roomTotal: roomTotal,
      );
      await fetchStays();
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi Check-in: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> checkOutAndPay(int stayId, String paymentMethod) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await stayRepository.checkOutAndPay(stayId: stayId, paymentMethod: paymentMethod);
      await fetchStays();
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi thanh toán: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

