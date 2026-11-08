import 'package:flutter/foundation.dart';
import '../../domain/entities/room_type.dart';
import '../../domain/repositories/room_type_repository.dart';

class RoomTypeProvider extends ChangeNotifier {
  final RoomTypeRepository roomTypeRepository;

  RoomTypeProvider({required this.roomTypeRepository});

  List<RoomType> _roomTypes = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<RoomType> get roomTypes => _roomTypes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchRoomTypes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _roomTypes = await roomTypeRepository.getRoomTypes();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createRoomType({
    required String code,
    required String name,
    required String description,
    required int capacity,
    required double basePricePerNight,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await roomTypeRepository.createRoomType(
        code: code,
        name: name,
        description: description,
        capacity: capacity,
        basePricePerNight: basePricePerNight,
      );
      await fetchRoomTypes();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateRoomType({
    required int id,
    required String code,
    required String name,
    required String description,
    required int capacity,
    required double basePricePerNight,
    required String rowVersion,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await roomTypeRepository.updateRoomType(
        id: id,
        code: code,
        name: name,
        description: description,
        capacity: capacity,
        basePricePerNight: basePricePerNight,
        rowVersion: rowVersion,
      );
      await fetchRoomTypes();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteRoomType(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await roomTypeRepository.deleteRoomType(id);
      await fetchRoomTypes();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
