import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/report_models.dart';

abstract class ReportRemoteDataSource {
  Future<RoomReportModel> fetchRoomReport(DateTime fromDate, DateTime toDate);
  Future<ReservationReportModel> fetchReservationReport(DateTime fromDate, DateTime toDate);
  Future<RevenueReportModel> fetchRevenueReport(DateTime fromDate, DateTime toDate);
  Future<TaskReportModel> fetchTaskReport(DateTime fromDate, DateTime toDate);
  Future<ComprehensiveReportModel> fetchComprehensiveReport(DateTime fromDate, DateTime toDate);
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final Dio dio;

  ReportRemoteDataSourceImpl(this.dio);

  String _formatDate(DateTime dt) => DateFormat('yyyy-MM-dd').format(dt);

  @override
  Future<RoomReportModel> fetchRoomReport(DateTime fromDate, DateTime toDate) async {
    final response = await dio.get(
      '${ApiConstants.reportService}/rooms',
      queryParameters: {
        'FromDate': _formatDate(fromDate),
        'ToDate': _formatDate(toDate),
      },
    );
    return RoomReportModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ReservationReportModel> fetchReservationReport(DateTime fromDate, DateTime toDate) async {
    final response = await dio.get(
      '${ApiConstants.reportService}/reservations',
      queryParameters: {
        'FromDate': _formatDate(fromDate),
        'ToDate': _formatDate(toDate),
      },
    );
    return ReservationReportModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<RevenueReportModel> fetchRevenueReport(DateTime fromDate, DateTime toDate) async {
    final response = await dio.get(
      '${ApiConstants.reportService}/revenue',
      queryParameters: {
        'FromDate': _formatDate(fromDate),
        'ToDate': _formatDate(toDate),
      },
    );
    return RevenueReportModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<TaskReportModel> fetchTaskReport(DateTime fromDate, DateTime toDate) async {
    final response = await dio.get(
      '${ApiConstants.reportService}/tasks',
      queryParameters: {
        'FromDate': _formatDate(fromDate),
        'ToDate': _formatDate(toDate),
      },
    );
    return TaskReportModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ComprehensiveReportModel> fetchComprehensiveReport(DateTime fromDate, DateTime toDate) async {
    try {
      final results = await Future.wait([
        fetchRoomReport(fromDate, toDate),
        fetchReservationReport(fromDate, toDate),
        fetchRevenueReport(fromDate, toDate),
        fetchTaskReport(fromDate, toDate),
      ]);

      return ComprehensiveReportModel(
        rooms: results[0] as RoomReportModel,
        reservations: results[1] as ReservationReportModel,
        revenue: results[2] as RevenueReportModel,
        tasks: results[3] as TaskReportModel,
        generatedAt: DateTime.now(),
      );
    } on DioException catch (e) {
      final msg = e.response?.data is Map && (e.response!.data as Map).containsKey('message')
          ? (e.response!.data as Map)['message'].toString()
          : 'Không thể tải báo cáo từ hệ thống (Lỗi ${e.response?.statusCode ?? 'kết nối'}).';
      throw Exception(msg);
    } catch (e) {
      throw Exception('Lỗi nạp báo cáo tổng hợp: $e');
    }
  }
}

