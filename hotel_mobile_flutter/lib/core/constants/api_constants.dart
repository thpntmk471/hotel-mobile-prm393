class ApiConstants {
  // Base host cho Web / Desktop / Emulator
  static const String host = 'http://localhost';

  // Endpoints các Micro-API theo cấu hình port Visual Studio đang chạy
  static const String authService = '$host:5049/api/Auth';
  static const String staffService = '$host:5001/api/Staff';
  static const String roomTypeService = '$host:5002/api/RoomType';
  static const String roomService = '$host:5003/api/Room';
  static const String guestService = '$host:5191/api/Guest';
  static const String reservationService = '$host:5046/api/Reservation';
  static const String stayService = '$host:5006/api/Stay';
  static const String hotelService = '$host:5007/api/HotelService';
  static const String serviceUsage = '$host:5089/api/ServiceUsage';
  static const String taskService = '$host:5013/api/Task';
  static const String reportService = '$host:5010/api/Report';
  static const String auditService = '$host:5011/api/Audit';

  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 15000;
}
