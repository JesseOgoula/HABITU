import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';

/// Provider for managing authentication state throughout the app
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  String? _pendingPhoneNumber;
  StreamSubscription<AuthState>? _authSubscription;

  /// Current authenticated user
  User? get user => _user;

  /// Whether authentication operation is in progress
  bool get isLoading => _isLoading;

  /// Error message from last failed operation
  String? get errorMessage => _errorMessage;

  /// Whether user is currently authenticated
  bool get isAuthenticated => _user != null;

  /// Phone number waiting for OTP verification
  String? get pendingPhoneNumber => _pendingPhoneNumber;

  /// User's display name (from Google or phone)
  String get displayName {
    if (_user == null) return 'User';

    // Try to get name from user metadata
    final metadata = _user!.userMetadata;
    if (metadata != null) {
      if (metadata['full_name'] != null) {
        return metadata['full_name'] as String;
      }
      if (metadata['name'] != null) {
        return metadata['name'] as String;
      }
    }

    // Fallback to email or phone
    if (_user!.email != null) {
      return _user!.email!.split('@').first;
    }
    if (_user!.phone != null) {
      return _user!.phone!;
    }

    return 'User';
  }

  /// User's avatar URL (from Google)
  String? get avatarUrl {
    final metadata = _user?.userMetadata;
    if (metadata != null && metadata['avatar_url'] != null) {
      return metadata['avatar_url'] as String;
    }
    return null;
  }

  /// Initialize the provider and listen to auth state changes
  Future<void> init() async {
    _user = _authService.currentUser;

    // Listen to auth state changes
    _authSubscription = _authService.authStateChanges.listen((authState) {
      _user = authState.session?.user;
      notifyListeners();
    });

    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  /// Clear any error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ==================== Phone Authentication ====================

  /// Send OTP to the given phone number
  Future<bool> sendOtp(String phoneNumber) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.sendOtp(phoneNumber);
      _pendingPhoneNumber = phoneNumber;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  /// Verify OTP code
  Future<bool> verifyOtp(String otpCode) async {
    if (_pendingPhoneNumber == null) {
      _errorMessage = 'No phone number to verify';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.verifyOtp(
        phoneNumber: _pendingPhoneNumber!,
        otpCode: otpCode,
      );

      _user = response.user;
      _pendingPhoneNumber = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  /// Cancel phone verification and go back
  void cancelPhoneVerification() {
    _pendingPhoneNumber = null;
    _errorMessage = null;
    notifyListeners();
  }

  // ==================== Google Authentication ====================

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.signInWithGoogle();
      _user = response.user;

      // Save profile to Supabase
      if (_user != null) {
        await _profileService.createOrUpdateProfile(
          id: _user!.id,
          email: _user!.email,
          displayName: displayName,
          avatarUrl: avatarUrl,
        );

        // Mark as registered and clear logout flag
        final box = await Hive.openBox('settings');
        await box.put('has_registered', true);
        await box.put('has_logged_out', false);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  // ==================== Sign Out ====================

  /// Sign out the current user
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _user = null;
      _pendingPhoneNumber = null;
      _errorMessage = null;

      // Mark as logged out for "Welcome Back" screen
      final box = await Hive.openBox('settings');
      await box.put('has_logged_out', true);
    } catch (e) {
      _errorMessage = _parseError(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Parse error to user-friendly message
  String _parseError(dynamic error) {
    if (error is AuthException) {
      switch (error.message) {
        case 'Invalid OTP':
          return 'Code invalide. Veuillez réessayer.';
        case 'Phone number not confirmed':
          return 'Numéro de téléphone non confirmé.';
        default:
          return error.message;
      }
    }

    final errorStr = error.toString();

    if (errorStr.contains('cancelled')) {
      return 'Connexion annulée.';
    }
    if (errorStr.contains('network')) {
      return 'Erreur de connexion. Vérifiez votre internet.';
    }

    return 'Une erreur est survenue. Veuillez réessayer.';
  }
}
