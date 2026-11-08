import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/stay_model.dart';

abstract class StayRemoteDataSource {
  Future<List<StayModel>> fetchStays();
  Future<StayModel> checkIn(Map<String, dynamic> payload);
  Future<void> checkOut(int stayId, String paymentMethod);
}

class StayRemoteDataSourceImpl implements StayRemoteDataSource {
  final Dio dio;

  StayRemoteDataSourceImpl(this.dio);

  final List<StayModel> _mockStays = [
    StayModel(
      id: 1,
      stayCode: 'STY-2026-001',
      reservationId: '1',
      guestName: 'Nguyễn Minh An',
      roomNumber: 'DEV-101',
      roomTypeName: 'Phòng Standard',
      checkInTime: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      status: 'Đang lưu trú',
      roomTotal: 900000,
      serviceTotal: 120000,
      grandTotal: 1020000,
      isPaid: false,
      invoiceLines: [
        InvoiceLineModel(
            id: 1,
            description: 'Tiền phòng DEV-101 (2 đêm)',
            quantity: 2,
            unitPrice: 450000,
            lineTotal: 900000),
        InvoiceLineModel(
            id: 2,
            description: 'Ăn sáng Buffet',
            quantity: 2,
            unitPrice: 60000,
            lineTotal: 120000),
      ],
    ),
    StayModel(
      id: 2,
      stayCode: 'STY-2026-002',
      reservationId: '2',
      guestName: 'Trần Thu Hà',
      roomNumber: 'DEV-201',
      roomTypeName: 'Phòng Deluxe',
      checkInTime: DateTime.now().subtract(const Duration(days: 7)),
      checkOutTime: DateTime.now().subtract(const Duration(days: 5)),
      status: 'Đã hoàn tất',
      roomTotal: 1400000,
      serviceTotal: 0,
      grandTotal: 1400000,
      isPaid: true,
      invoiceLines: [
        InvoiceLineModel(
            id: 3,
            description: 'Tiền phòng DEV-201 (2 đêm)',
            quantity: 2,
            unitPrice: 700000,
            lineTotal: 1400000),
      ],
    ),
  ];

  @override
  Future<List<StayModel>> fetchStays() async {
    try {
      final res = await dio.get(ApiConstants.stayService);
      dynamic data = res.data;
      if (data is Map && (data.containsKey('items') || data.containsKey('Items'))) {
        data = data['items'] ?? data['Items'];
      }
      if (data is List) {
        return data
            .map((e) => StayModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return _mockStays;
    } catch (e) {
      // ignore: avoid_print
      print('⚠️ [StayRemoteDataSource] fetchStays error: $e');
      return _mockStays;
    }
  }

  @override
  Future<StayModel> checkIn(Map<String, dynamic> payload) async {
    try {
      final res = await dio.post('${ApiConstants.stayService}/check-in', data: payload);
      final model = StayModel.fromJson(res.data as Map<String, dynamic>);
      _mockStays.insert(0, model);
      return model;
    } catch (e) {
      // ignore: avoid_print
      print('⚠️ [StayRemoteDataSource] checkIn error: $e');
      final model = StayModel(
        id: _mockStays.length + 1,
        stayCode: 'STY-2026-00${_mockStays.length + 1}',
        reservationId: payload['reservationId']?.toString() ?? '1',
        guestName: payload['guestName'] ?? 'Khách Nhận Phòng',
        roomNumber: payload['roomNumber'] ?? 'DEV-101',
        roomTypeName: payload['roomTypeName'] ?? 'Phòng Standard',
        checkInTime: DateTime.now(),
        status: 'Đang lưu trú',
        roomTotal: (payload['roomTotal'] ?? 900000).toDouble(),
        serviceTotal: 0,
        grandTotal: (payload['roomTotal'] ?? 900000).toDouble(),
        isPaid: false,
        invoiceLines: [
          InvoiceLineModel(
            id: DateTime.now().millisecondsSinceEpoch % 10000,
            description: 'Tiền phòng ${payload['roomNumber']}',
            quantity: 1,
            unitPrice: (payload['roomTotal'] ?? 900000).toDouble(),
            lineTotal: (payload['roomTotal'] ?? 900000).toDouble(),
          ),
        ],
      );
      _mockStays.insert(0, model);
      return model;
    }
  }

  @override
  Future<void> checkOut(int stayId, String paymentMethod) async {
    try {
      await dio.post(
        '${ApiConstants.stayService}/$stayId/check-out',
        data: {
          'checkedOutByAccountId': 2,
          'notes': 'Check-out & Thanh toán qua Mobile App ($paymentMethod)',
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('⚠️ [StayRemoteDataSource] checkOut error: $e');
    }

    final idx = _mockStays.indexWhere((s) => s.id == stayId);
    if (idx != -1) {
      final cur = _mockStays[idx];
      _mockStays[idx] = StayModel(
        id: cur.id,
        stayCode: cur.stayCode,
        reservationId: cur.reservationId,
        guestName: cur.guestName,
        roomNumber: cur.roomNumber,
        roomTypeName: cur.roomTypeName,
        checkInTime: cur.checkInTime,
        checkOutTime: DateTime.now(),
        status: 'Đã hoàn tất',
        roomTotal: cur.roomTotal,
        serviceTotal: cur.serviceTotal,
        grandTotal: cur.grandTotal,
        isPaid: true,
        invoiceLines: cur.invoiceLines,
      );
    }
  }
}
