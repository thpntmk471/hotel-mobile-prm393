import 'package:flutter/foundation.dart';
import '../../domain/entities/hotel_service_item.dart';
import '../../domain/repositories/hotel_service_repository.dart';

class HotelServiceProvider extends ChangeNotifier {
  final HotelServiceRepository serviceRepository;

  HotelServiceProvider({required this.serviceRepository});

  List<HotelServiceItem> _services = [];
  List<ServiceUsageOrder> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _searchQuery = '';
  String _selectedCategory = 'Tất cả';

  List<HotelServiceItem> get services => _services;
  List<ServiceUsageOrder> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;

  Future<void> fetchServices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _services = await serviceRepository.getServices(
        category: _selectedCategory,
        search: _searchQuery,
      );
      _orders = await serviceRepository.getServiceOrders();
    } catch (e) {
      _errorMessage = 'Không thể nạp danh mục dịch vụ: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchServices();
  }

  void setCategoryFilter(String cat) {
    _selectedCategory = cat;
    fetchServices();
  }

  Future<bool> orderService({
    required int stayId,
    required String roomNumber,
    required HotelServiceItem service,
    required int quantity,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await serviceRepository.orderService(
        stayId: stayId,
        roomNumber: roomNumber,
        service: service,
        quantity: quantity,
      );
      await fetchServices();
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi gọi dịch vụ: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> createService({
    required String serviceCode,
    required String name,
    required String unit,
    required double price,
    String? description,
    bool isActive = true,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await serviceRepository.createService(
        serviceCode: serviceCode,
        name: name,
        unit: unit,
        price: price,
        description: description,
        isActive: isActive,
      );
      await fetchServices();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateService({
    required int id,
    required String serviceCode,
    required String name,
    required String unit,
    required double price,
    required String rowVersion,
    String? description,
    bool isActive = true,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await serviceRepository.updateService(
        id: id,
        serviceCode: serviceCode,
        name: name,
        unit: unit,
        price: price,
        rowVersion: rowVersion,
        description: description,
        isActive: isActive,
      );
      await fetchServices();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleServiceStatus(HotelServiceItem item) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await serviceRepository.updateStatus(
        id: item.id,
        isActive: !item.isAvailable,
        rowVersion: item.rowVersion,
      );
      await fetchServices();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

