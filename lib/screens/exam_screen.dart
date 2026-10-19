import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/exam_progress.dart';
import '../services/question_repository.dart';
import '../theme.dart';
import 'quiz_screen.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  final ExamProgress _progress = ExamProgress.instance;
  late final List<List<Question>> _groups;
  final Map<int, int> _bestByGroup = {};

  @override
  void initState() {
    super.initState();
    _groups = QuestionRepository.instance.examGroups();
    _refreshScores();
  }

  Future<void> _refreshScores() async {
    for (var i = 0; i < _groups.length; i++) {
      final best = await _progress.bestCorrect(i);
      if (best != null) _bestByGroup[i] = best;
    }
    if (mounted) setState(() {});
  }

  int get _totalQuestions =>
      _groups.fold(0, (sum, group) => sum + group.length);

  int get _totalBest =>
      _bestByGroup.values.fold(0, (sum, best) => sum + best);

  Future<void> _openGroup(int index) async {
    final group = _groups[index];
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          questions: group,
          title: 'Group ${index + 1}',
          onFinished: (correct, _) => _progress.record(index, correct),
        ),
      ),
    );
    await _refreshScores();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: const DecoratedBox(
            decoration: BoxDecoration(gradient: AppColors.header)),
        title: const Text('Exam'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          _ScoreSummary(correct: _totalBest, total: _totalQuestions),
          const SizedBox(height: 8),
          for (var i = 0; i < _groups.length; i++)
            _GroupTile(
              index: i,
              count: _groups[i].length,
              best: _bestByGroup[i],
              onTap: () => _openGroup(i),
            ),
        ],
      ),
    );
  }
}

class _ScoreSummary extends StatelessWidget {
  const _ScoreSummary({required this.correct, required this.total});
  final int correct;
  final int total;

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0 : ((correct / total) * 100).round();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your best so far',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              '$correct correct out of $total questions',
              style: TextStyle(color: AppColors.slate, fontSize: 13),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: total == 0 ? 0 : correct / total,
                minHeight: 8,
                backgroundColor: AppColors.bg,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$percent%',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({
    required this.index,
    required this.count,
    required this.best,
    required this.onTap,
  });

  final int index;
  final int count;
  final int? best;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final attempted = best != null;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Group ${index + 1}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        attempted
                            ? 'Best: $best / $count correct'
                            : '$count questions • not attempted yet',
                        style: TextStyle(
                          color: attempted ? AppColors.good : AppColors.slate,
                          fontSize: 13,
                          fontWeight:
                              attempted ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  attempted
                      ? Icons.check_circle_rounded
                      : Icons.chevron_right_rounded,
                  color: attempted ? AppColors.good : AppColors.slate,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
