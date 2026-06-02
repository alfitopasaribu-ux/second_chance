import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

class AuthState {
  final bool isAuthenticated;
<<<<<<< HEAD
  final bool isCheckingAuth;
=======
>>>>>>> ba968ea74465efef7597cf98104212157e45199a
  final Map<String, dynamic>? user;
  final String? token;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
<<<<<<< HEAD
    this.isCheckingAuth = false,
=======
>>>>>>> ba968ea74465efef7597cf98104212157e45199a
    this.user,
    this.token,
    this.isLoading = false,
    this.error,
  });

<<<<<<< HEAD

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isCheckingAuth,
=======
  AuthState copyWith({
    bool? isAuthenticated,
>>>>>>> ba968ea74465efef7597cf98104212157e45199a
    Map<String, dynamic>? user,
    String? token,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
<<<<<<< HEAD
      isCheckingAuth: isCheckingAuth ?? this.isCheckingAuth,
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

=======
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
>>>>>>> ba968ea74465efef7597cf98104212157e45199a
}

class AuthNotifier extends StateNotifier<AuthState> {
  final _storage = const FlutterSecureStorage();
  final _dio = Dio();

  AuthNotifier() : super(const AuthState()) {
    _loadToken();
  }

  Future<void> _loadToken() async {
<<<<<<< HEAD
    state = state.copyWith(isCheckingAuth: true, error: null);
    final token = await _storage.read(key: 'auth_token');

=======
    final token = await _storage.read(key: 'auth_token');
>>>>>>> ba968ea74465efef7597cf98104212157e45199a
    final username = await _storage.read(key: 'username');
    final email = await _storage.read(key: 'email');
    final userId = await _storage.read(key: 'user_id');

    if (token != null) {
      state = state.copyWith(
        isAuthenticated: true,
        token: token,
        user: {'id': userId, 'username': username, 'email': email},
      );
<<<<<<< HEAD
    } else {
      state = state.copyWith(isAuthenticated: false, token: null, user: null);
    }

    state = state.copyWith(isCheckingAuth: false);
  }


=======
    }
  }

>>>>>>> ba968ea74465efef7597cf98104212157e45199a
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.post(
        '${AppConstants.baseUrl}${AppConstants.loginEndpoint}',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['token'] as String;
        final user = data['user'] as Map<String, dynamic>;

        await _storage.write(key: 'auth_token', value: token);
        await _storage.write(key: 'username', value: user['username']);
        await _storage.write(key: 'email', value: user['email']);
        await _storage.write(key: 'user_id', value: user['id']);

        state = state.copyWith(
          isAuthenticated: true,
          token: token,
          user: user,
          isLoading: false,
        );
        return true;
      }
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? 'Gagal terhubung ke server';
      state = state.copyWith(isLoading: false, error: message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Terjadi kesalahan');
    }
    return false;
  }

  Future<bool> register(String username, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.post(
        '${AppConstants.baseUrl}${AppConstants.registerEndpoint}',
        data: {'username': username, 'email': email, 'password': password},
      );

      if (response.statusCode == 201) {
        final data = response.data;
        final token = data['token'] as String;
        final user = data['user'] as Map<String, dynamic>;

        await _storage.write(key: 'auth_token', value: token);
        await _storage.write(key: 'username', value: user['username']);
        await _storage.write(key: 'email', value: user['email']);
        await _storage.write(key: 'user_id', value: user['id']);

        state = state.copyWith(
          isAuthenticated: true,
          token: token,
          user: user,
          isLoading: false,
        );
        return true;
      }
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? 'Gagal mendaftar';
      state = state.copyWith(isLoading: false, error: message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Terjadi kesalahan');
    }
    return false;
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
