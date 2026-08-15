import 'package:respiracare/features/patient/education/models/educational_content.dart';
import 'package:respiracare/features/patient/education/models/exercise.dart';
import 'package:respiracare/features/patient/education/models/exercise_session.dart';
import 'package:respiracare/features/patient/education/models/rehabilitation_program.dart';
import 'package:respiracare/features/patient/education/models/smoking_entry.dart';
import 'package:respiracare/features/patient/education/repositories/education_repository.dart';

/// Mock implementation of EducationRepository for development and testing
class MockEducationRepository implements EducationRepository {
  // In-memory storage
  RehabilitationProgram? _program;
  final List<ExerciseSession> _exerciseSessions = [];
  final List<SmokingEntry> _smokingEntries = [];
  final List<EducationalContent> _educationalContent = [];
  final String _currentGoal = 'Arrêt progressif';

  MockEducationRepository() {
    _initializeMockData();
  }

  void _initializeMockData() {
    // Initialize rehabilitation program
    final exercises = [
      const Exercise(
        id: 'ex-1',
        name: 'Respiration contrôlée',
        description:
            'Exercice de base pour apprendre à contrôler sa respiration et réduire l\'essoufflement.',
        duration: Duration(minutes: 10),
        videoUrl: null, // Placeholder
        instructions:
            '1. Asseyez-vous confortablement, dos droit\n2. Inspirez lentement par le nez pendant 2 temps\n3. Expirez doucement par la bouche entrouverte pendant 4 temps\n4. Répétez pendant 10 minutes\n\nConsigne validée par votre équipe soignante.',
        order: 1,
      ),
      const Exercise(
        id: 'ex-2',
        name: 'Mobilité thoracique',
        description:
            'Exercices pour améliorer l\'amplitude respiratoire et la souplesse de la cage thoracique.',
        duration: Duration(minutes: 8),
        videoUrl: null, // Placeholder
        instructions:
            '1. Debout, pieds écartés largeur épaules\n2. Bras croisés sur la poitrine\n3. Inspirez en ouvrant les coudes sur les côtés\n4. Expirez en ramenant les coudes\n5. Répétez 10 fois\n\nConsigne validée par votre équipe soignante.',
        order: 2,
      ),
      const Exercise(
        id: 'ex-3',
        name: 'Exercices respiratoires',
        description:
            'Série d\'exercices combinés pour renforcer les muscles respiratoires.',
        duration: Duration(minutes: 12),
        videoUrl: null, // Placeholder
        instructions:
            '1. Respiration diaphragmatique (5 min)\n2. Respiration à lèvres pincées (4 min)\n3. Exercices de toux efficace (3 min)\n\nConsigne validée par votre équipe soignante.',
        order: 3,
      ),
    ];

    _program = RehabilitationProgram(
      id: 'prog-1',
      title: 'Programme de rééducation respiratoire',
      description:
          'Votre programme personnalisé établi par l\'équipe de rééducation. Les exercices sont adaptés à votre condition et doivent être réalisés selon les consignes de votre kinésithérapeute.',
      exercises: exercises,
      targetWeeklySessions: 5,
      startDate: DateTime.now().subtract(const Duration(days: 10)),
      endDate: DateTime.now().add(const Duration(days: 60)),
    );

    // Initialize some completed exercise sessions
    _exerciseSessions.addAll([
      ExerciseSession(
        id: 'sess-1',
        exerciseId: 'ex-1',
        exerciseName: 'Respiration contrôlée',
        completedAt: DateTime.now().subtract(const Duration(days: 2)),
        actualDuration: const Duration(minutes: 10),
        perceivedEffort: 3,
        notes: 'Bien ressenti',
      ),
      ExerciseSession(
        id: 'sess-2',
        exerciseId: 'ex-2',
        exerciseName: 'Mobilité thoracique',
        completedAt: DateTime.now().subtract(const Duration(days: 1)),
        actualDuration: const Duration(minutes: 8),
        perceivedEffort: 4,
        notes: null,
      ),
      ExerciseSession(
        id: 'sess-3',
        exerciseId: 'ex-1',
        exerciseName: 'Respiration contrôlée',
        completedAt: DateTime.now().subtract(const Duration(hours: 2)),
        actualDuration: const Duration(minutes: 10),
        perceivedEffort: 2,
        notes: 'Plus facile aujourd\'hui',
      ),
    ]);

    // Initialize smoking entries
    final now = DateTime.now();
    _smokingEntries.addAll([
      SmokingEntry(
        id: 'smk-1',
        date: now.subtract(const Duration(days: 11)),
        cigarettesConsumed: 8,
        cravingIntensity: CravingIntensity.moderate,
        trigger: SmokingTrigger.habit,
        personalNote: 'Matin au café',
        createdAt: now.subtract(const Duration(days: 11, hours: 2)),
      ),
      SmokingEntry(
        id: 'smk-2',
        date: now.subtract(const Duration(days: 10)),
        cigarettesConsumed: 6,
        cravingIntensity: CravingIntensity.low,
        trigger: SmokingTrigger.stress,
        personalNote: 'Stress au travail',
        createdAt: now.subtract(const Duration(days: 10, hours: 3)),
      ),
      SmokingEntry(
        id: 'smk-3',
        date: now.subtract(const Duration(days: 9)),
        cigarettesConsumed: 5,
        cravingIntensity: CravingIntensity.low,
        trigger: SmokingTrigger.habit,
        personalNote: null,
        createdAt: now.subtract(const Duration(days: 9, hours: 1)),
      ),
      SmokingEntry(
        id: 'smk-4',
        date: now.subtract(const Duration(days: 8)),
        cigarettesConsumed: 4,
        cravingIntensity: CravingIntensity.low,
        trigger: SmokingTrigger.social,
        personalNote: 'Déjeuner entre collègues',
        createdAt: now.subtract(const Duration(days: 8, hours: 4)),
      ),
      SmokingEntry(
        id: 'smk-5',
        date: now.subtract(const Duration(days: 7)),
        cigarettesConsumed: 3,
        cravingIntensity: CravingIntensity.moderate,
        trigger: SmokingTrigger.emotion,
        personalNote: 'Anxiété soirée',
        createdAt: now.subtract(const Duration(days: 7, hours: 5)),
      ),
      SmokingEntry(
        id: 'smk-6',
        date: now.subtract(const Duration(days: 6)),
        cigarettesConsumed: 3,
        cravingIntensity: CravingIntensity.low,
        trigger: SmokingTrigger.habit,
        personalNote: null,
        createdAt: now.subtract(const Duration(days: 6, hours: 2)),
      ),
      SmokingEntry(
        id: 'smk-7',
        date: now.subtract(const Duration(days: 5)),
        cigarettesConsumed: 2,
        cravingIntensity: CravingIntensity.low,
        trigger: SmokingTrigger.habit,
        personalNote: 'Progression',
        createdAt: now.subtract(const Duration(days: 5, hours: 1)),
      ),
      SmokingEntry(
        id: 'smk-8',
        date: now.subtract(const Duration(days: 4)),
        cigarettesConsumed: 2,
        cravingIntensity: CravingIntensity.low,
        trigger: SmokingTrigger.habit,
        personalNote: null,
        createdAt: now.subtract(const Duration(days: 4, hours: 3)),
      ),
      SmokingEntry(
        id: 'smk-9',
        date: now.subtract(const Duration(days: 3)),
        cigarettesConsumed: 2,
        cravingIntensity: CravingIntensity.moderate,
        trigger: SmokingTrigger.stress,
        personalNote: 'Grosse journée',
        createdAt: now.subtract(const Duration(days: 3, hours: 2)),
      ),
      SmokingEntry(
        id: 'smk-10',
        date: now.subtract(const Duration(days: 2)),
        cigarettesConsumed: 1,
        cravingIntensity: CravingIntensity.low,
        trigger: SmokingTrigger.habit,
        personalNote: 'Presque là',
        createdAt: now.subtract(const Duration(days: 2, hours: 1)),
      ),
      SmokingEntry(
        id: 'smk-11',
        date: now.subtract(const Duration(days: 1)),
        cigarettesConsumed: 1,
        cravingIntensity: CravingIntensity.low,
        trigger: SmokingTrigger.habit,
        personalNote: null,
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
      ),
      SmokingEntry(
        id: 'smk-12',
        date: now,
        cigarettesConsumed: 2,
        cravingIntensity: CravingIntensity.moderate,
        trigger: SmokingTrigger.stress,
        personalNote: 'Reprise difficile',
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
    ]);

    // Initialize educational content
    _educationalContent.addAll([
      const EducationalContent(
        id: 'edu-1',
        title: 'Comprendre le sevrage tabagique',
        summary:
            'Pourquoi arrêter de fumer est bénéfique pour votre santé respiratoire et comment le sevrage agit sur votre organisme.',
        content:
            'Le sevrage tabagique est un processus par lequel votre corps élimine la nicotine et ses effets. Dans les 20 minutes suivant votre dernière cigarette, votre fréquence cardiaque et votre tension artérielle commencent à baisser. À 8 heures, le taux de monoxyde de carbone dans le sang diminue de moitié. À 48 heures, la nicotine est entièrement éliminée de votre organisme et vos sens du goût et de l\'odorat s\'améliorent.\n\nPour une personne atteinte de BPCO, l\'arrêt du tabac est le seul geste qui ralentit la progression de la maladie. Chaque jour sans cigarette préserve votre fonction respiratoire.\n\n⚠️ Ce contenu est un placeholder. Le contenu validé par l\'équipe médicale remplacera cette version.',
        category: EducationalCategory.sevrage,
        isPlaceholder: true,
      ),
      const EducationalContent(
        id: 'edu-2',
        title: 'Gérer une envie de fumer',
        summary:
            'Techniques concrètes pour traverser une envie intense de fumer sans craquer.',
        content:
            'Les envies de fumer durent généralement 3 à 5 minutes. Voici des stratégies pour les traverser :\n\n1. **La règle des 5 minutes** : Dites-vous "j\'attends 5 minutes". L\'envie passera.\n2. **Respiration profonde** : Inspirez 4 temps, expirez 6 temps. Répétez 5 fois.\n3. **Changez d\'activité** : Levez-vous, marchez, buvez un verre d\'eau.\n4. **Mâchez un chewing-gum** ou mangez un fruit.\n5. **Rappelez-vous votre motivation** : Pourquoi avez-vous décidé d\'arrêter ?\n\nSi l\'envie persiste après 10 minutes, contactez votre infirmier référent ou une ligne d\'aide au sevrage.\n\n⚠️ Ce contenu est un placeholder. Le contenu validé par l\'équipe médicale remplacera cette version.',
        category: EducationalCategory.sevrage,
        isPlaceholder: true,
      ),
      const EducationalContent(
        id: 'edu-3',
        title: 'Identifier vos déclencheurs',
        summary:
            'Apprenez à reconnaître les situations, émotions et habitudes qui provoquent l\'envie de fumer.',
        content:
            'Un déclencheur est une situation, une émotion ou une habitude qui crée automatiquement l\'envie de fumer. Les identifier vous permet d\'anticiper et de préparer des alternatives.\n\n**Déclencheurs courants :**\n- **Le café/le thé** : Associez la boisson à un nouveau rituel (lecture, musique)\n- **La pause** : Sortez marcher au lieu de rester sur place\n- **Le stress** : Préparez une technique de relaxation (respiration, méditation)\n- **L\'alcool** : Évitez ou limitez dans les premières semaines\n- **L\'ennui** : Ayez toujours une occupation de secours\n- **Voir d\'autres fumer** : Éloignez-vous temporairement\n\n**Exercice :** Notez pendant 3 jours chaque cigarette : heure, lieu, émotion, intensité de l\'envie (1-10). Des schémas apparaîtront.\n\n⚠️ Ce contenu est un placeholder. Le contenu validé par l\'équipe médicale remplacera cette version.',
        category: EducationalCategory.sevrage,
        isPlaceholder: true,
      ),
      const EducationalContent(
        id: 'edu-4',
        title: 'Préparer votre environnement',
        summary:
            'Comment modifier votre domicile et votre routine pour faciliter l\'arrêt du tabac.',
        content:
            'Votre environnement peut vous aider ou vous piéger. Quelques ajustements simples :\n\n**À la maison :**\n- Jetez tous les cendriers, briquets, paquets\n- Lavez les vêtements qui sentent le tabac\n- Aérez toutes les pièces\n- Créez un "coin détente" sans tabac\n\n**Au travail :**\n- Identifiez les zones non-fumeurs pour vos pauses\n- Prévenez vos collègues de votre démarche\n- Ayez des alternatives : eau, fruits, chewing-gums\n\n**En voiture :**\n- Nettoyez l\'intérieur\n- Mettez un diffuseur d\'huile essentielle (menthe, citron)\n- Écoutez un podcast ou de la musique\n\n**Le soir :**\n- Remplacez le rituel "cigarette détente" par : tisane, lecture, étirements\n- Couchez-vous plus tôt si la fatigue déclenche l\'envie\n\n⚠️ Ce contenu est un placeholder. Le contenu validé par l\'équipe médicale remplacera cette version.',
        category: EducationalCategory.sevrage,
        isPlaceholder: true,
      ),
      const EducationalContent(
        id: 'edu-5',
        title: 'Pourquoi la rééducation respiratoire ?',
        summary:
            'Comprendre les bénéfices des exercices respiratoires pour votre BPCO.',
        content:
            'La rééducation respiratoire est un pilier de la prise en charge de la BPCO. Elle ne guérit pas la maladie, mais elle améliore significativement votre qualité de vie :\n\n**Bénéfices prouvés :**\n- Réduction de l\'essoufflement à l\'effort\n- Amélioration de la tolérance à l\'exercice\n- Diminution des exacerbations\n- Meilleure qualité de vie\n- Réduction des hospitalisations\n\n**Comment ça marche :**\nLes exercices renforcent vos muscles respiratoires (diaphragme, intercostaux), améliorent la mécanique ventilatoire et vous apprennent à gérer l\'essoufflement.\n\n**Votre programme :**\nIl est personnalisé par votre kinésithérapeute en fonction de votre capacité respiratoire, vos symptômes et vos objectifs. La régularité est la clé : 3 à 5 séances par semaine.\n\n⚠️ Ce contenu est un placeholder. Le contenu validé par l\'équipe médicale remplacera cette version.',
        category: EducationalCategory.rehabilitation,
        isPlaceholder: true,
      ),
    ]);
  }

  @override
  Future<RehabilitationProgram?> getRehabilitationProgram() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _program;
  }

  @override
  Future<List<ExerciseSession>> getExerciseSessions({int? limit}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final sessions = List<ExerciseSession>.from(_exerciseSessions);
    sessions.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    if (limit != null && sessions.length > limit) {
      return sessions.take(limit).toList();
    }
    return sessions;
  }

  @override
  Future<ExerciseSession> recordExerciseSession(ExerciseSession session) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _exerciseSessions.insert(0, session);
    return session;
  }

  @override
  Future<List<SmokingEntry>> getSmokingEntries({int? limit}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final entries = List<SmokingEntry>.from(_smokingEntries);
    entries.sort((a, b) => b.date.compareTo(a.date));
    if (limit != null && entries.length > limit) {
      return entries.take(limit).toList();
    }
    return entries;
  }

  @override
  Future<SmokingEntry> addSmokingEntry(SmokingEntry entry) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _smokingEntries.insert(0, entry);
    return entry;
  }

  @override
  Future<void> deleteSmokingEntry(String entryId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _smokingEntries.removeWhere((e) => e.id == entryId);
  }

  @override
  Future<int> getTrackedDaysCount() async {
    await Future.delayed(const Duration(milliseconds: 100));
    final uniqueDates = _smokingEntries
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet();
    return uniqueDates.length;
  }

  @override
  Future<String> getCurrentGoal() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _currentGoal;
  }

  @override
  Future<List<EducationalContent>> getEducationalContent(
      {String? category}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (category != null) {
      return _educationalContent.where((c) => c.category == category).toList();
    }
    return List.from(_educationalContent);
  }

  @override
  Future<EducationalContent?> getEducationalContentById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _educationalContent.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
