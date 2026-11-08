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

  // Endpoints các Micro-API chuẩn xác 100% theo route controller của PRN232 Backend (cổng 5000 -> 5011)
  static String get authService => '$host:5000/api/auth';
  static String get staffService => '$host:5001/api/accounts';
  static String get roomTypeService => '$host:5002/HotelOps/room-types';
  static String get roomService => '$host:5003/HotelOps/rooms';
  static String get guestService => '$host:5004/HotelOps/guests';
  static String get reservationService => '$host:5005/api/reservations';
  static String get stayService => '$host:5006/api/stays';
  static String get hotelService => '$host:5007/api/hotel-services';
  static String get serviceUsage => '$host:5008/api/service-usages';
  static String get taskService => '$host:5009/api/hotel-tasks';
  static String get reportService => '$host:5010/api/reports';
  static String get auditService => '$host:5011/api/auditlogs';

  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 15000;
}
