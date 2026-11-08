import 'package:flutter/foundation.dart';
import '../../domain/entities/room.dart';
import '../../domain/repositories/room_repository.dart';

class RoomProvider extends ChangeNotifier {
  final RoomRepository roomRepository;

  RoomProvider({required this.roomRepository});

  List<Room> _rooms = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _searchQuery = '';
  String _selectedRoomType = 'Tất cả';
  String _selectedHousekeeping = 'Tất cả';

  List<Room> get rooms => _rooms;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedRoomType => _selectedRoomType;
  String get selectedHousekeeping => _selectedHousekeeping;

  Future<void> fetchRooms() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _rooms = await roomRepository.getRooms(
        searchRoomNumber: _searchQuery,
        roomTypeName: _selectedRoomType,
        housekeepingStatus: _selectedHousekeeping,
      );
    } catch (e) {
      _errorMessage = 'Không thể nạp danh sách phòng: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchRooms();
  }

  void setRoomTypeFilter(String type) {
    _selectedRoomType = type;
    fetchRooms();
  }

  void setHousekeepingFilter(String status) {
    _selectedHousekeeping = status;
    fetchRooms();
  }

  Future<void> toggleHousekeepingStatus(Room room) async {
    final nextStatus = room.housekeepingStatus == 'Sạch' ? 'Cần dọn' : 'Sạch';
    await roomRepository.updateHousekeepingStatus(room.id, nextStatus, rowVersion: room.rowVersion);
    await fetchRooms();
  }

  Future<void> setHousekeepingStatus(int roomId, String status, {String rowVersion = ''}) async {
    await roomRepository.updateHousekeepingStatus(roomId, status, rowVersion: rowVersion);
    await fetchRooms();
  }
}

