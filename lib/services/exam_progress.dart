import 'package:shared_preferences/shared_preferences.dart';

/// Persists the best number of correct answers the learner has scored on each
/// exam group, so progress survives across sessions.
class ExamProgress {
  ExamProgress._();
  static final ExamProgress instance = ExamProgress._();

  static const String _keyPrefix = 'exam_group_best_';

  String _keyFor(int groupIndex) => '$_keyPrefix$groupIndex';

  /// Best correct count recorded for [groupIndex], or null when never attempted.
  Future<int?> bestCorrect(int groupIndex) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyFor(groupIndex));
  }

  /// Stores [correct] for [groupIndex] only when it beats the previous best.
  Future<void> record(int groupIndex, int correct) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _keyFor(groupIndex);
    final previousBest = prefs.getInt(key) ?? -1;
    if (correct > previousBest) await prefs.setInt(key, correct);
  }
}
