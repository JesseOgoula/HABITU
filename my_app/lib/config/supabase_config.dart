/// Supabase configuration for HABITU app
///
/// This file contains the Supabase project credentials.
/// DO NOT commit this file with real credentials to public repositories.
class SupabaseConfig {
  /// Supabase project URL
  static const String supabaseUrl = 'https://atoktiskrhouleriixrm.supabase.co';

  /// Supabase anonymous key (safe to use in client apps)
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF0b2t0aXNrcmhvdWxlcmlpeHJtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUwNDY0MjMsImV4cCI6MjA4MDYyMjQyM30.CH6EnTQ_Iz3qui1Vj7-G8EtSaBH99-1ROL-LuQL2f3I';

  /// Google OAuth Web Client ID (required for Google Sign-In)
  static const String googleWebClientId =
      '565966401094-i27o38loicphcachklb7i9o2g60qvgol.apps.googleusercontent.com';
}
