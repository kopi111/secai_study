import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/question_repository.dart';
import '../services/speech_service.dart';
import '../theme.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key, this.questions, this.title});

  /// Optional filtered set (e.g. one domain). Defaults to all questions.
  final List<Question>? questions;
  final String? title;

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  final PageController _controller = PageController();
  final SpeechService _speech = SpeechService.instance;
  late final List<Question> _questions;
  int _index = 0;
  bool _readingAll = false;
  bool _autoAdvancing = false;

  @override
  void initState() {
    super.initState();
    _questions = widget.questions ?? QuestionRepository.instance.all;
  }

  @override
  void dispose() {
    _readingAll = false;
    _speech.stop();
    _controller.dispose();
    super.dispose();
  }

  void _go(int delta) {
    final next = _index + delta;
    if (next < 0 || next >= _questions.length) return;
    _stopReading();
    _controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  /// Reads from question [i] to the end, auto-advancing between cards.
  void _readFrom(int i) {
    if (!_readingAll || !mounted) return;
    if (i >= _questions.length) {
      _stopReading();
      return;
    }
    if (i != _index) {
      _autoAdvancing = true;
      _controller.jumpToPage(i);
    }
    _speech.speak(
      buildSpokenText(_questions[i]),
      onDone: () => _readFrom(i + 1),
    );
  }

  void _toggleReadAll() {
    if (_readingAll || _speech.isSpeaking) {
      _stopReading();
    } else {
      setState(() => _readingAll = true);
      _readFrom(_index);
    }
  }

  void _stopReading() {
    _readingAll = false;
    _speech.stop();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: const DecoratedBox(
            decoration: BoxDecoration(gradient: AppColors.header)),
        title: Text(widget.title ?? 'Study  ${_index + 1}/${_questions.length}'),
        actions: [
          ListenableBuilder(
            listenable: _speech,
            builder: (context, _) {
              final active = _readingAll || _speech.isSpeaking;
              return IconButton(
                tooltip: active ? 'Stop' : 'Read all aloud',
                icon: Icon(active
                    ? Icons.stop_circle_rounded
                    : Icons.volume_up_rounded),
                onPressed: _toggleReadAll,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _questions.length,
              onPageChanged: (i) {
                if (_autoAdvancing) {
                  _autoAdvancing = false;
                  setState(() => _index = i);
                  return;
                }
                _stopReading();
                setState(() => _index = i);
              },
              itemBuilder: (context, i) => _StudyCard(
                question: _questions[i],
                reading: _readingAll,
                onToggleRead: _toggleReadAll,
              ),
            ),
          ),
          _NavBar(
            index: _index,
            total: _questions.length,
            onPrev: () => _go(-1),
            onNext: () => _go(1),
          ),
        ],
      ),
    );
  }
}

String buildSpokenText(Question q) {
  final buffer = StringBuffer();
  buffer.writeln('Question ${q.number}.');
  buffer.writeln(q.question);
  for (var i = 0; i < q.options.length; i++) {
    buffer.writeln('Option ${q.letterFor(i)}. ${q.options[i]}');
  }
  if (!q.isInfo) {
    buffer.writeln('Correct answer: ${q.correctLetters}.');
  }
  buffer.writeln('Explanation.');
  buffer.writeln(q.explanation);
  return buffer.toString();
}

class _ReadAloudButton extends StatelessWidget {
  const _ReadAloudButton({required this.reading, required this.onToggle});
  final bool reading;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final speech = SpeechService.instance;
    return ListenableBuilder(
      listenable: speech,
      builder: (context, _) {
        final active = reading || speech.isSpeaking;
        return SizedBox(
          width: double.infinity,
          child: FilledButton.tonalIcon(
            style: FilledButton.styleFrom(
              backgroundColor: active
                  ? AppColors.bad.withValues(alpha: 0.12)
                  : AppColors.accent.withValues(alpha: 0.14),
              foregroundColor: active ? AppColors.bad : AppColors.accent,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: Icon(active
                ? Icons.stop_circle_rounded
                : Icons.volume_up_rounded),
            label: Text(
              active ? 'Stop reading' : 'Read aloud (this & onward)',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            onPressed: onToggle,
          ),
        );
      },
    );
  }
}

class _StudyCard extends StatelessWidget {
  const _StudyCard({
    required this.question,
    required this.reading,
    required this.onToggleRead,
  });
  final Question question;
  final bool reading;
  final VoidCallback onToggleRead;

  @override
  Widget build(BuildContext context) {
    final q = question;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  gradient: AppColors.header,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  q.isInfo ? 'SIMULATION' : 'Question ${q.number}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              if (q.isMultiAnswer) ...[
                const SizedBox(width: 8),
                _tag('Choose ${q.correctIndices.length}'),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Text(
            q.question,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          _ReadAloudButton(reading: reading, onToggle: onToggleRead),
          const SizedBox(height: 16),
          for (var i = 0; i < q.options.length; i++)
            _OptionRow(
              letter: q.letterFor(i),
              text: q.options[i],
              correct: q.correctIndices.contains(i),
            ),
          const SizedBox(height: 18),
          _ExplanationBox(question: q),
        ],
      ),
    );
  }

  Widget _tag(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.accent,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      );
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.letter,
    required this.text,
    required this.correct,
  });

  final String letter;
  final String text;
  final bool correct;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: correct ? AppColors.good.withValues(alpha: 0.08) : AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: correct
              ? AppColors.good.withValues(alpha: 0.6)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: correct
                ? AppColors.good
                : AppColors.slate.withValues(alpha: 0.15),
            child: Text(
              letter,
              style: TextStyle(
                color: correct ? Colors.white : AppColors.slate,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.5,
                height: 1.35,
                color: correct ? AppColors.ink : AppColors.ink,
                fontWeight: correct ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          if (correct)
            const Icon(Icons.check_circle_rounded,
                color: AppColors.good, size: 20),
        ],
      ),
    );
  }
}

class _ExplanationBox extends StatelessWidget {
  const _ExplanationBox({required this.question});
  final Question question;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_rounded,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 6),
              Text(
                question.isInfo
                    ? 'How to approach it'
                    : 'Answer: ${question.correctLetters}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            question.explanation,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar({
    required this.index,
    required this.total,
    required this.onPrev,
    required this.onNext,
  });

  final int index;
  final int total;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _navButton(
            icon: Icons.arrow_back_rounded,
            label: 'Prev',
            enabled: index > 0,
            onTap: onPrev,
          ),
          Expanded(
            child: Center(
              child: Text(
                '${index + 1} of $total',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate,
                ),
              ),
            ),
          ),
          _navButton(
            icon: Icons.arrow_forward_rounded,
            label: 'Next',
            enabled: index < total - 1,
            onTap: onNext,
            trailing: true,
          ),
        ],
      ),
    );
  }

  Widget _navButton({
    required IconData icon,
    required String label,
    required bool enabled,
    required VoidCallback onTap,
    bool trailing = false,
  }) {
    final color = enabled ? AppColors.primary : AppColors.slate.withValues(alpha: 0.4);
    final children = trailing
        ? [Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700)), const SizedBox(width: 4), Icon(icon, color: color)]
        : [Icon(icon, color: color), const SizedBox(width: 4), Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700))];
    return TextButton(
      onPressed: enabled ? onTap : null,
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}
