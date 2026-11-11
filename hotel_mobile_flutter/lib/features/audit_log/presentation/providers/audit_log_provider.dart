import 'package:flutter/foundation.dart';
import '../../domain/entities/audit_log_item.dart';
import '../../domain/repositories/audit_log_repository.dart';

class AuditLogProvider extends ChangeNotifier {
  final AuditLogRepository repository;

  AuditLogProvider({required this.repository});

  List<AuditLogItem> _items = [];
  int _totalCount = 0;
  int _currentPage = 1;
  int _pageSize = 20;
  int _totalPages = 1;
  bool _hasPreviousPage = false;
  bool _hasNextPage = false;

  bool _isLoading = false;
  String? _errorMessage;

  // Filter state
  String? _keyword;
  String? _action;
  String? _entityType;
  int? _actorAccountId;
  String? _entityId;
  DateTime? _fromDate;
  DateTime? _toDate;

  // Selected detail
  AuditLogItem? _selectedItem;
  bool _isLoadingDetail = false;

  // Getters
  List<AuditLogItem> get items => _items;
  int get totalCount => _totalCount;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  int get totalPages => _totalPages;
  bool get hasPreviousPage => _hasPreviousPage;
  bool get hasNextPage => _hasNextPage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String? get keyword => _keyword;
  String? get action => _action;
  String? get entityType => _entityType;
  int? get actorAccountId => _actorAccountId;
  String? get entityId => _entityId;
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;

  AuditLogItem? get selectedItem => _selectedItem;
  bool get isLoadingDetail => _isLoadingDetail;

  bool get hasActiveFilters =>
      (_keyword != null && _keyword!.trim().isNotEmpty) ||
      (_action != null && _action!.trim().isNotEmpty) ||
      (_entityType != null && _entityType!.trim().isNotEmpty) ||
      _actorAccountId != null ||
      (_entityId != null && _entityId!.trim().isNotEmpty) ||
      _fromDate != null ||
      _toDate != null;

  Future<void> loadLogs({int? page}) async {
    if (page != null) {
      _currentPage = page;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await repository.getAuditLogs(
        page: _currentPage,
        pageSize: _pageSize,
        keyword: _keyword,
        action: _action,
        entityType: _entityType,
        actorAccountId: _actorAccountId,
        entityId: _entityId,
        fromDate: _fromDate,
        toDate: _toDate,
      );

      _items = result.items;
      _totalCount = result.totalCount;
      _currentPage = result.pageNumber;
      _pageSize = result.pageSize;
      _totalPages = result.totalPages;
      _hasPreviousPage = result.hasPreviousPage;
      _hasNextPage = result.hasNextPage;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  void setKeyword(String? val) {
    _keyword = (val != null && val.trim().isNotEmpty) ? val.trim() : null;
  }

  void setAction(String? val) {
    _action = (val != null && val.trim().isNotEmpty) ? val.trim() : null;
  }

  void setEntityType(String? val) {
    _entityType = (val != null && val.trim().isNotEmpty) ? val.trim() : null;
  }

  void setActorAccountId(int? val) {
    _actorAccountId = val;
  }

  void setEntityId(String? val) {
    _entityId = (val != null && val.trim().isNotEmpty) ? val.trim() : null;
  }

  void setDateRange(DateTime? from, DateTime? to) {
    _fromDate = from;
    _toDate = to;
  }

  void setPageSize(int size) {
    _pageSize = size;
    _currentPage = 1;
    loadLogs(page: 1);
  }

  void resetFilters() {
    _keyword = null;
    _action = null;
    _entityType = null;
    _actorAccountId = null;
    _entityId = null;
    _fromDate = null;
    _toDate = null;
    _currentPage = 1;
    loadLogs(page: 1);
  }

  Future<AuditLogItem?> fetchDetail(int id) async {
    _isLoadingDetail = true;
    notifyListeners();

    try {
      final item = await repository.getAuditLogById(id);
      _selectedItem = item;
      _isLoadingDetail = false;
      notifyListeners();
      return item;
    } catch (e) {
      _isLoadingDetail = false;
      notifyListeners();
      return null;
    }
  }
}
