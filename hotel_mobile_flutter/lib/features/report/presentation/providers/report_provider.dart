import 'package:flutter/foundation.dart';
import '../../data/models/report_models.dart';
import '../../domain/repositories/report_repository.dart';

class ReportProvider extends ChangeNotifier {
  final ReportRepository repository;

  ReportProvider({required this.repository}) {
    final now = DateTime.now();
    _fromDate = DateTime(now.year, now.month, 1);
    _toDate = now;
  }

  late DateTime _fromDate;
  late DateTime _toDate;
  ComprehensiveReportModel? _report;
  bool _isLoading = false;
  String? _errorMessage;

  DateTime get fromDate => _fromDate;
  DateTime get toDate => _toDate;
  ComprehensiveReportModel? get report => _report;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadReport({DateTime? from, DateTime? to}) async {
    if (from != null) _fromDate = from;
    if (to != null) _toDate = to;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _report = await repository.getComprehensiveReport(_fromDate, _toDate);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCurrentMonth() {
    final now = DateTime.now();
    _fromDate = DateTime(now.year, now.month, 1);
    _toDate = now;
    loadReport();
  }

  void setDateRange(DateTime from, DateTime to) {
    _fromDate = from;
    _toDate = to;
    loadReport();
  }
}

