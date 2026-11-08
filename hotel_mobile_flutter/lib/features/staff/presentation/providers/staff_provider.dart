import 'package:flutter/foundation.dart';
import '../../domain/entities/staff_member.dart';
import '../../domain/repositories/staff_repository.dart';

class StaffProvider extends ChangeNotifier {
  final StaffRepository staffRepository;

  StaffProvider({required this.staffRepository});

  List<StaffMember> _staffList = [];
  StaffMember? _selectedStaff;
  bool _isLoading = false;
  String? _errorMessage;

  String _keyword = '';
  int? _roleFilter;
  bool? _statusFilter;

  List<StaffMember> get staffList => _staffList;
  StaffMember? get selectedStaff => _selectedStaff;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get keyword => _keyword;
  int? get roleFilter => _roleFilter;
  bool? get statusFilter => _statusFilter;

  Future<void> fetchStaffList() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _staffList = await staffRepository.getStaffList(
        keyword: _keyword,
        role: _roleFilter,
        isActive: _statusFilter,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setKeyword(String kw) {
    _keyword = kw;
    fetchStaffList();
  }

  void setRoleFilter(int? role) {
    _roleFilter = role;
    fetchStaffList();
  }

  void setStatusFilter(bool? status) {
    _statusFilter = status;
    fetchStaffList();
  }

  Future<StaffMember?> fetchStaffDetail(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final staff = await staffRepository.getStaffById(id);
      _selectedStaff = staff;
      return staff;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createStaff({
    required String username,
    required String password,
    required String fullName,
    String? phoneNumber,
    String? email,
    required int role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await staffRepository.createStaff(
        username: username,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
        email: email,
        role: role,
      );
      await fetchStaffList();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStaff({
    required int id,
    required String fullName,
    String? phoneNumber,
    String? email,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await staffRepository.updateStaff(
        id: id,
        fullName: fullName,
        phoneNumber: phoneNumber,
        email: email,
      );
      if (_selectedStaff?.id == id) {
        _selectedStaff = updated;
      }
      await fetchStaffList();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changeRole({
    required int id,
    required int role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await staffRepository.updateRole(
        id: id,
        role: role,
      );
      if (_selectedStaff?.id == id) {
        _selectedStaff = updated;
      }
      await fetchStaffList();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleStatus(StaffMember member) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await staffRepository.updateStatus(
        id: member.id,
        isActive: !member.isActive,
      );
      if (_selectedStaff?.id == member.id) {
        _selectedStaff = updated;
      }
      await fetchStaffList();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
