import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/question.dart';

class QuestionRepository {
  QuestionRepository._();
  static final QuestionRepository instance = QuestionRepository._();

  List<Question> _questions = const [];
  bool _loaded = false;

  List<Question> get all => _questions;

  /// Questions that can be graded (excludes the hotspot/info item).
  List<Question> get quizzable =>
      _questions.where((q) => !q.isInfo).toList(growable: false);

  /// All questions belonging to a single exam domain.
  List<Question> byDomain(int domain) =>
      _questions.where((q) => q.domain == domain).toList(growable: false);

  /// How many questions are tagged to each domain.
  int countForDomain(int domain) =>
      _questions.where((q) => q.domain == domain).length;

  /// Gradable questions split into fixed-size exam groups.
  /// The final group holds the remainder when the count is not divisible.
  List<List<Question>> examGroups({int size = 10}) {
    final source = quizzable;
    final groups = <List<Question>>[];
    for (var start = 0; start < source.length; start += size) {
      final end = (start + size).clamp(0, source.length);
      groups.add(source.sublist(start, end));
    }
    return groups;
  }

  Future<void> load() async {
    if (_loaded) return;
    final raw = await rootBundle.loadString('assets/questions.json');
    final data = jsonDecode(raw) as List<dynamic>;
    _questions = data
        .map((e) => Question.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
    _loaded = true;
  }
}
