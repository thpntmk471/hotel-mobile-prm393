import '../../data/models/report_models.dart';

abstract class ReportRepository {
  Future<ComprehensiveReportModel> getComprehensiveReport(DateTime fromDate, DateTime toDate);
  Future<RoomReportModel> getRoomReport(DateTime fromDate, DateTime toDate);
  Future<ReservationReportModel> getReservationReport(DateTime fromDate, DateTime toDate);
  Future<RevenueReportModel> getRevenueReport(DateTime fromDate, DateTime toDate);
  Future<TaskReportModel> getTaskReport(DateTime fromDate, DateTime toDate);
}
