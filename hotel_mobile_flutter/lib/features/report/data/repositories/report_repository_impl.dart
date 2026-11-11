import '../datasources/report_remote_datasource.dart';
import '../models/report_models.dart';
import '../../domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remoteDataSource;

  ReportRepositoryImpl(this.remoteDataSource);

  @override
  Future<ComprehensiveReportModel> getComprehensiveReport(DateTime fromDate, DateTime toDate) {
    return remoteDataSource.fetchComprehensiveReport(fromDate, toDate);
  }

  @override
  Future<RoomReportModel> getRoomReport(DateTime fromDate, DateTime toDate) {
    return remoteDataSource.fetchRoomReport(fromDate, toDate);
  }

  @override
  Future<ReservationReportModel> getReservationReport(DateTime fromDate, DateTime toDate) {
    return remoteDataSource.fetchReservationReport(fromDate, toDate);
  }

  @override
  Future<RevenueReportModel> getRevenueReport(DateTime fromDate, DateTime toDate) {
    return remoteDataSource.fetchRevenueReport(fromDate, toDate);
  }

  @override
  Future<TaskReportModel> getTaskReport(DateTime fromDate, DateTime toDate) {
    return remoteDataSource.fetchTaskReport(fromDate, toDate);
  }
}

