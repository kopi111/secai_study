import 'package:flutter/material.dart';
import '../data/exam_info.dart';
import '../services/question_repository.dart';
import '../theme.dart';
import 'exam_screen.dart';
import 'quiz_screen.dart';
import 'study_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final total = QuestionRepository.instance.all.length;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _Header(total: total)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            sliver: SliverList.list(
              children: [
                _ActionCard(
                  icon: Icons.menu_book_rounded,
                  color: AppColors.primary,
                  title: 'Study & Read',
                  subtitle:
                      'Flip through all $total questions with answers, '
                      'explanations, and read-aloud.',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StudyScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _ActionCard(
                  icon: Icons.quiz_rounded,
                  color: AppColors.accent,
                  title: 'Take a Quiz',
                  subtitle:
                      'Answer questions, get instant feedback, and see '
                      'your score at the end.',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const QuizScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _ActionCard(
                  icon: Icons.assignment_turned_in_rounded,
                  color: AppColors.good,
                  title: 'Take an Exam',
                  subtitle:
                      'Work through the questions in groups of ten. '
                      'Your best score for each group is saved.',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ExamScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                const _DomainsCard(),
                const SizedBox(height: 18),
                Center(
                  child: Text(
                    'For exam preparation only.',
                    style: TextStyle(color: AppColors.slate, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.total});
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppColors.header),
      padding: const EdgeInsets.fromLTRB(22, 64, 22, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.shield_moon_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              const Text(
                'SecAI+ Study',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            kExamModule,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$kExamName • $kExamCode • $total questions',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.slate,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.slate),
            ],
          ),
        ),
      ),
    );
  }
}

class _DomainsCard extends StatelessWidget {
  const _DomainsCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Exam domains',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              'Official CompTIA SecAI+ (CY0-001) objectives.',
              style: TextStyle(color: AppColors.slate, fontSize: 12.5),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap a domain to study or quiz just that area.',
              style: TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 14),
            for (var i = 0; i < kExamDomains.length; i++)
              _DomainTile(index: i, domain: kExamDomains[i]),
          ],
        ),
      ),
    );
  }
}

class _DomainTile extends StatelessWidget {
  const _DomainTile({required this.index, required this.domain});
  final int index;
  final ExamDomain domain;

  void _open(BuildContext context) {
    final questions = QuestionRepository.instance.byDomain(index);
    final label = 'Domain ${index + 1}';
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                domain.title,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                '${questions.length} questions • ${domain.weight}% of exam',
                style: TextStyle(color: AppColors.slate, fontSize: 13),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                icon: const Icon(Icons.menu_book_rounded),
                label: const Text('Study & Read this domain'),
                onPressed: () {
                  Navigator.pop(sheet);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          StudyScreen(questions: questions, title: label),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.quiz_rounded),
                label: const Text('Quiz this domain',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                onPressed: () {
                  Navigator.pop(sheet);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          QuizScreen(questions: questions, title: label),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final count = QuestionRepository.instance.countForDomain(index);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _open(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      domain.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${domain.weight}%',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.slate, size: 20),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: domain.weight / 100,
                  minHeight: 6,
                  backgroundColor: AppColors.bg,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$count questions • ${domain.summary}',
                style: TextStyle(
                  color: AppColors.slate,
                  fontSize: 12.5,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
