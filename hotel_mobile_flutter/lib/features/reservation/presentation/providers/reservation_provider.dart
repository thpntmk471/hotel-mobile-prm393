import 'package:flutter/foundation.dart';
import '../../domain/entities/reservation.dart';
import '../../domain/repositories/reservation_repository.dart';

class ReservationProvider extends ChangeNotifier {
  final ReservationRepository reservationRepository;

  ReservationProvider({required this.reservationRepository});

  List<Reservation> _reservations = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _searchQuery = '';
  String _selectedStatus = 'Tất cả';

  List<Reservation> get reservations => _reservations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedStatus => _selectedStatus;

  Future<void> fetchReservations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _reservations = await reservationRepository.getReservations(
        search: _searchQuery,
        status: _selectedStatus,
      );
    } catch (e) {
      _errorMessage = 'Không thể nạp danh sách đặt phòng: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchReservations();
  }

  void setStatusFilter(String status) {
    _selectedStatus = status;
    fetchReservations();
  }

  Future<bool> createReservation({
    required String guestName,
    required String guestPhone,
    String? guestIdCard,
    required int roomId,
    required String roomNumber,
    required String roomTypeName,
    required double pricePerNight,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int numberOfGuests,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await reservationRepository.createReservation(
        guestName: guestName,
        guestPhone: guestPhone,
        guestIdCard: guestIdCard,
        roomId: roomId,
        roomNumber: roomNumber,
        roomTypeName: roomTypeName,
        pricePerNight: pricePerNight,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
        numberOfGuests: numberOfGuests,
      );
      await fetchReservations();
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi tạo đặt phòng: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateStatus(String id, String newStatus, {String rowVersion = ''}) async {
    await reservationRepository.updateStatus(id, newStatus, rowVersion: rowVersion);
    await fetchReservations();
  }
}

