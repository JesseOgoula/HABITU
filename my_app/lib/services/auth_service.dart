import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Service handling all authentication operations with Supabase
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Get the Supabase client instance
  SupabaseClient get _supabase => Supabase.instance.client;

  /// Get the current authenticated user
  User? get currentUser => _supabase.auth.currentUser;

  /// Check if a user is currently authenticated
  bool get isAuthenticated => currentUser != null;

  /// Stream of authentication state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Initialize Supabase - call this in main.dart before runApp
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  }

  // ==================== Phone Authentication ====================

  /// Send OTP to the given phone number
  ///
  /// [phoneNumber] should include country code, e.g., "+33612345678"
  Future<void> sendOtp(String phoneNumber) async {
    await _supabase.auth.signInWithOtp(
      phone: phoneNumber,
      channel: OtpChannel.sms,
    );
  }

  /// Verify the OTP code sent to the phone number
  ///
  /// Returns the authenticated session if successful
  Future<AuthResponse> verifyOtp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    final response = await _supabase.auth.verifyOTP(
      phone: phoneNumber,
      token: otpCode,
      type: OtpType.sms,
    );
    return response;
  }

  // ==================== Google Authentication ====================

  /// Sign in with Google
  ///
  /// Opens Google Sign-In flow and authenticates with Supabase
  Future<AuthResponse> signInWithGoogle() async {
    try {
      // Configure Google Sign-In
      // For Android: clientId is not needed (uses SHA-1 fingerprint)
      // serverClientId is needed for Supabase to validate the token
      final googleSignIn = GoogleSignIn(
        serverClientId: SupabaseConfig.googleWebClientId,
        scopes: ['email', 'profile'],
      );

      // Start Google Sign-In flow
      debugPrint('Starting Google Sign-In...');
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('Google Sign-In was cancelled by user');
        throw Exception('Google Sign-In was cancelled');
      }

      debugPrint('Google user: ${googleUser.email}');

      // Get authentication tokens
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      debugPrint(
        'Got Google tokens - idToken: ${idToken != null}, accessToken: ${accessToken != null}',
      );

      if (idToken == null) {
        throw Exception('No ID token received from Google');
      }

      // Authenticate with Supabase using the Google token
      debugPrint('Authenticating with Supabase...');
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      debugPrint('Supabase auth success: ${response.user?.email}');
      return response;
    } catch (e, stackTrace) {
      debugPrint('Google Sign-In error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // ==================== Session Management ====================

  /// Sign out the current user
  Future<void> signOut() async {
    // Sign out from Google if applicable
    try {
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
    } catch (e) {
      debugPrint('Google sign out error: $e');
    }

    // Sign out from Supabase
    await _supabase.auth.signOut();
  }

  /// Get the current session
  Session? get currentSession => _supabase.auth.currentSession;

  /// Refresh the current session
  Future<void> refreshSession() async {
    await _supabase.auth.refreshSession();
  }
}
