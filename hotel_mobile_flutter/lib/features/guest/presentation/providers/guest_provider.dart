import 'package:flutter/foundation.dart';
import '../../domain/entities/guest.dart';
import '../../domain/repositories/guest_repository.dart';

class GuestProvider extends ChangeNotifier {
  final GuestRepository guestRepository;

  GuestProvider({required this.guestRepository});

  List<Guest> _guests = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Guest> get guests => _guests;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchGuests({String? keyword}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _guests = await guestRepository.getGuests(keyword: keyword);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Guest?> createGuest({
    required String fullName,
    required String phoneNumber,
    String? email,
    required String documentNumber,
    String? address,
    String? notes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newGuest = await guestRepository.createGuest(
        fullName: fullName,
        phoneNumber: phoneNumber,
        email: email,
        documentNumber: documentNumber,
        address: address,
        notes: notes,
      );
      await fetchGuests();
      return newGuest;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateGuest({
    required int id,
    required String fullName,
    required String phoneNumber,
    String? email,
    required String documentNumber,
    String? address,
    String? notes,
    required String rowVersion,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await guestRepository.updateGuest(
        id: id,
        fullName: fullName,
        phoneNumber: phoneNumber,
        email: email,
        documentNumber: documentNumber,
        address: address,
        notes: notes,
        rowVersion: rowVersion,
      );
      await fetchGuests();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> archiveGuest(int id, String rowVersion) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await guestRepository.archiveGuest(id, rowVersion);
      await fetchGuests();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

