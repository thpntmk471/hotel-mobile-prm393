class ApiConstants {
  // Thay đổi host tùy theo môi trường chạy:
  // - Android Emulator: 'http://10.0.2.2'
  // - iOS Simulator / Web / Desktop: 'http://localhost'
  // - Thiết bị thật: 'http://<IP_MÁY_TÍNH>:PORT'
  static const String host = 'http://10.0.2.2';

  // Endpoints các Micro-API thuộc hệ sinh thái PRN232
  static const String authService = '$host:5001/api/Auth';
  static const String staffService = '$host:5002/api/Staff';
  static const String guestService = '$host:5003/api/Guest';
  static const String roomTypeService = '$host:5004/api/RoomType';
  static const String roomService = '$host:5005/api/Room';
  static const String reservationService = '$host:5006/api/Reservation';
  static const String stayService = '$host:5007/api/Stay';
  static const String hotelService = '$host:5008/api/HotelService';
  static const String serviceUsage = '$host:5009/api/ServiceUsage';
  static const String taskService = '$host:5010/api/Task';

  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 15000;
}

