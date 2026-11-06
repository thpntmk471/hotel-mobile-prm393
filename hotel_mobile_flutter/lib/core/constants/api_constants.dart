import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  // Tự động nhận diện môi trường chạy:
  // - Web / Windows Desktop: http://localhost
  // - Android Emulator: http://10.0.2.2
  static String get host {
    if (kIsWeb) return 'http://localhost';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2';
    } catch (_) {}
    return 'http://localhost';
  }

  // Endpoints các Micro-API chuẩn theo dải cổng 5000 -> 5011 của script Backend
  static String get authService => '$host:5000/api/Auth';
  static String get staffService => '$host:5001/api/Staff';
  static String get roomTypeService => '$host:5002/api/RoomType';
  static String get roomService => '$host:5003/api/Room';
  static String get guestService => '$host:5004/api/Guest';
  static String get reservationService => '$host:5005/api/Reservation';
  static String get stayService => '$host:5006/api/Stay';
  static String get hotelService => '$host:5007/api/HotelService';
  static String get serviceUsage => '$host:5008/api/ServiceUsage';
  static String get taskService => '$host:5009/api/Task';
  static String get reportService => '$host:5010/api/Report';
  static String get auditService => '$host:5011/api/Audit';

  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 15000;
}
