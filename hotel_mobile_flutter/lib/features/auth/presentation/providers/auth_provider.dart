import 'package:flutter/foundation.dart';
import '../../domain/entities/user_session.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthStatus { initial, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthRepository authRepository;

  AuthProvider({required this.authRepository}) {
    checkSavedSession();
  }

  AuthStatus _status = AuthStatus.initial;
  UserSession? _session;
  bool _isLoading = false;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserSession? get session => _session;
  UserSession? get user => _session;
  int get currentUserId => _session?.userId ?? 2;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> checkSavedSession() async {
    final saved = await authRepository.getCachedSession();
    if (saved != null) {
      _session = saved;
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _session = await authRepository.login(username: username, password: password);
      _status = AuthStatus.authenticated;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await authRepository.logout();
    _session = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}

