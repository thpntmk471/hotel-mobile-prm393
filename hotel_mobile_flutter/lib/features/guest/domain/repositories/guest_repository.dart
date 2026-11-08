import '../entities/guest.dart';

abstract class GuestRepository {
  Future<List<Guest>> getGuests({String? keyword});
  Future<Guest?> findGuestByDocument(String documentNumber);
  Future<Guest> createGuest({
    required String fullName,
    required String phoneNumber,
    String? email,
    required String documentNumber,
    String? address,
    String? notes,
  });
  Future<Guest> updateGuest({
    required int id,
    required String fullName,
    required String phoneNumber,
    String? email,
    required String documentNumber,
    String? address,
    String? notes,
    required String rowVersion,
  });
  Future<void> archiveGuest(int id, String rowVersion);
}

