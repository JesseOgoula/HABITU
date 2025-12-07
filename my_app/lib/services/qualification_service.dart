import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Data model for user qualification
class QualificationData {
  final String? phoneNumber;
  final String? city;
  final String gender; // 'homme', 'femme', 'non_specifie'
  final String urgentObjective;
  final String mainFriction;

  QualificationData({
    this.phoneNumber,
    this.city,
    required this.gender,
    required this.urgentObjective,
    required this.mainFriction,
  });

  Map<String, dynamic> toJson() => {
    'phone_number': phoneNumber,
    'city': city,
    'gender': gender,
    'urgent_objective': urgentObjective,
    'main_friction': mainFriction,
  };
}

/// Data model for AI recommendations
class AIRecommendations {
  final List<String> habits;
  final String circleName;

  AIRecommendations({required this.habits, required this.circleName});

  factory AIRecommendations.fromJson(Map<String, dynamic> json) {
    return AIRecommendations(
      habits: List<String>.from(json['habits'] ?? []),
      circleName: json['circle_name'] ?? 'Mon Cercle',
    );
  }
}

/// Service for profile qualification and AI recommendations
class QualificationService {
  static final QualificationService _instance =
      QualificationService._internal();
  factory QualificationService() => _instance;
  QualificationService._internal();

  SupabaseClient get _supabase => Supabase.instance.client;

  /// Objective options for qualification
  static const List<Map<String, String>> objectiveOptions = [
    {'id': 'health', 'label': 'Être en meilleure santé', 'emoji': '💪'},
    {'id': 'income', 'label': 'Augmenter mes revenus', 'emoji': '💰'},
    {
      'id': 'skill',
      'label': 'Maîtriser une nouvelle compétence',
      'emoji': '📚',
    },
    {'id': 'productivity', 'label': 'Améliorer ma productivité', 'emoji': '⚡'},
    {'id': 'relationships', 'label': 'Renforcer mes relations', 'emoji': '❤️'},
  ];

  /// Friction options for qualification
  static const List<Map<String, String>> frictionOptions = [
    {'id': 'time', 'label': 'Manque de temps', 'emoji': '⏰'},
    {'id': 'motivation', 'label': 'Manque de motivation', 'emoji': '😴'},
    {'id': 'support', 'label': 'Absence de soutien', 'emoji': '🤝'},
    {'id': 'resources', 'label': 'Manque de ressources', 'emoji': '🔧'},
  ];

  /// Gender options
  static const List<Map<String, String>> genderOptions = [
    {'id': 'homme', 'label': 'Homme'},
    {'id': 'femme', 'label': 'Femme'},
    {'id': 'non_specifie', 'label': 'Préfère ne pas dire'},
  ];

  /// Save qualification data to Supabase
  Future<void> saveQualification(String userId, QualificationData data) async {
    try {
      debugPrint('Saving qualification data for user: $userId');

      await _supabase.from('profil').upsert({
        'id': userId,
        'phone_number': data.phoneNumber,
        'city': data.city,
        'gender': data.gender,
        'urgent_objective': data.urgentObjective,
        'main_friction': data.mainFriction,
        'qualification_complete': true,
        'updated_at': DateTime.now().toIso8601String(),
      });

      debugPrint('Qualification data saved successfully');
    } catch (e) {
      debugPrint('Error saving qualification: $e');
      rethrow;
    }
  }

  /// Check if user has completed qualification
  Future<bool> isQualificationComplete(String userId) async {
    try {
      final response = await _supabase
          .from('profil')
          .select('qualification_complete')
          .eq('id', userId)
          .maybeSingle();

      return response?['qualification_complete'] == true;
    } catch (e) {
      debugPrint('Error checking qualification: $e');
      return false;
    }
  }

  /// Generate AI recommendations using Gemini
  Future<AIRecommendations> generateRecommendations(
    QualificationData data,
  ) async {
    try {
      debugPrint('Generating AI recommendations...');

      final objectiveLabel = objectiveOptions.firstWhere(
        (o) => o['id'] == data.urgentObjective,
        orElse: () => {'label': data.urgentObjective},
      )['label'];

      final frictionLabel = frictionOptions.firstWhere(
        (f) => f['id'] == data.mainFriction,
        orElse: () => {'label': data.mainFriction},
      )['label'];

      final prompt =
          '''
Tu es un Expert en Modélisation Culturelle et Design d'Habitude pour l'application HABITU, une app africaine basée sur la philosophie Ubuntu (grandir ensemble).

Données utilisateur:
- Sexe: ${data.gender == 'homme'
              ? 'Homme'
              : data.gender == 'femme'
              ? 'Femme'
              : 'Non spécifié'}
- Ville: ${data.city ?? 'Non spécifiée'}
- Objectif Urgent: $objectiveLabel
- Friction Principale: $frictionLabel

Instructions:
1. Génère 3 habitudes concrètes, mesurables et de TRÈS FAIBLE FRICTION (max 10 minutes) adaptées au contexte africain
2. Les habitudes doivent mitiger la friction principale
3. Génère un nom inspirant pour le "Cercle" (max 3 mots) qui résonne avec la culture Ubuntu

IMPORTANT: Réponds UNIQUEMENT avec un JSON valide, sans texte avant ou après:
{"habits": ["Habitude 1", "Habitude 2", "Habitude 3"], "circle_name": "Nom du Cercle"}
''';

      final response = await http.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${SupabaseConfig.geminiApiKey}',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 500},
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final text =
            jsonResponse['candidates'][0]['content']['parts'][0]['text'];

        // Extract JSON from response (handle potential markdown code blocks)
        String jsonStr = text;
        if (text.contains('```json')) {
          jsonStr = text.split('```json')[1].split('```')[0].trim();
        } else if (text.contains('```')) {
          jsonStr = text.split('```')[1].split('```')[0].trim();
        }

        final recommendations = jsonDecode(jsonStr);
        debugPrint('AI recommendations received: $recommendations');

        return AIRecommendations.fromJson(recommendations);
      } else {
        debugPrint(
          'Gemini API error: ${response.statusCode} - ${response.body}',
        );
        // Return default recommendations on error
        return _getDefaultRecommendations(data);
      }
    } catch (e) {
      debugPrint('Error generating recommendations: $e');
      return _getDefaultRecommendations(data);
    }
  }

  /// Get default recommendations when AI fails
  AIRecommendations _getDefaultRecommendations(QualificationData data) {
    Map<String, List<String>> defaultHabits = {
      'health': [
        'Faire 5 minutes d\'étirements au réveil',
        'Boire un verre d\'eau avant chaque repas',
        'Marcher 10 minutes après le déjeuner',
      ],
      'income': [
        'Noter 1 idée de business chaque matin',
        'Lire 10 pages sur les finances',
        'Épargner 500 FCFA par jour',
      ],
      'skill': [
        'Pratiquer 15 minutes de ma compétence cible',
        'Regarder 1 tutoriel par jour',
        'Noter 3 choses apprises aujourd\'hui',
      ],
      'productivity': [
        'Planifier mes 3 priorités du jour',
        'Travailler 25 min sans distraction (Pomodoro)',
        'Ranger mon espace de travail le soir',
      ],
      'relationships': [
        'Envoyer un message d\'encouragement à 1 personne',
        'Appeler un proche pendant 5 minutes',
        'Exprimer ma gratitude à quelqu\'un',
      ],
    };

    return AIRecommendations(
      habits:
          defaultHabits[data.urgentObjective] ?? defaultHabits['productivity']!,
      circleName: 'Cercle Ubuntu',
    );
  }
}
