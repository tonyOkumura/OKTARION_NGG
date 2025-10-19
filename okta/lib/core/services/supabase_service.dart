import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_constants.dart';
import '../utils/log_service.dart';

/// Сервис для работы с Supabase
/// Управляет инициализацией и подключением к Supabase
class SupabaseService {
  SupabaseService._();

  static final SupabaseService _instance = SupabaseService._();
  static SupabaseService get instance => _instance;

  /// Получить клиент Supabase
  SupabaseClient get client => Supabase.instance.client;

  /// Инициализация Supabase
  Future<void> init() async {
    try {
      LogService.i('🔗 Initializing Supabase...');
      
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        anonKey: AppConstants.supabaseAnonKey,
        debug: AppConstants.isDebugMode,
      );
      
      LogService.i('✅ Supabase initialized successfully');
      LogService.i('🔗 Supabase URL: ${AppConstants.supabaseUrl}');
      
    } catch (e, stackTrace) {
      LogService.e('❌ Failed to initialize Supabase: $e', e, stackTrace);
      rethrow;
    }
  }

  /// Проверить подключение к Supabase
  Future<bool> checkConnection() async {
    try {
      LogService.i('🔍 Checking Supabase connection...');
      
      // Для локального сервера используем простую проверку через auth
      // Это более надежный способ проверки подключения
      await client.auth.getUser();
      
      LogService.i('✅ Supabase connection is healthy');
      LogService.i('🔗 Connected to: ${AppConstants.supabaseUrl}');
      return true;
      
    } catch (e) {
      LogService.w('⚠️ Supabase connection check failed: $e');
      LogService.w('🔗 Failed to connect to: ${AppConstants.supabaseUrl}');
      return false;
    }
  }

  /// Получить информацию о текущем пользователе
  User? get currentUser => client.auth.currentUser;

  /// Проверить, авторизован ли пользователь
  bool get isAuthenticated => currentUser != null;

  /// Получить сессию пользователя
  Session? get currentSession => client.auth.currentSession;

  /// Подписаться на изменения состояния аутентификации
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  /// Выйти из системы
  Future<void> signOut() async {
    try {
      LogService.i('🚪 Signing out from Supabase...');
      await client.auth.signOut();
      LogService.i('✅ Successfully signed out');
    } catch (e, stackTrace) {
      LogService.e('❌ Failed to sign out: $e', e, stackTrace);
      rethrow;
    }
  }

  /// Получить информацию о Supabase
  Map<String, dynamic> getSupabaseInfo() {
    return {
      'url': AppConstants.supabaseUrl,
      'isLocal': AppConstants.supabaseUrl.contains('localhost'),
      'isInitialized': true,
      'isAuthenticated': isAuthenticated,
      'currentUser': currentUser?.email ?? 'Not authenticated',
      'sessionExists': currentSession != null,
    };
  }
}
