import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/question_repository.dart';
import '../services/speech_service.dart';
import '../theme.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, this.questions, this.title, this.onFinished});

  /// Optional filtered set (e.g. one domain). Defaults to all gradable questions.
  final List<Question>? questions;
  final String? title;

  /// Called once with the final score when the learner reaches the last question.
  final void Function(int correct, int total)? onFinished;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final SpeechService _speech = SpeechService.instance;
  late final List<Question> _questions;

  int _index = 0;
  int _correct = 0;
  final Set<int> _selected = {};
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    final source = widget.questions ?? QuestionRepository.instance.quizzable;
    _questions = source.where((q) => !q.isInfo).toList();
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  Question get _q => _questions[_index];

  bool get _isAnswerCorrect {
    final correct = _q.correctIndices.toSet();
    return _selected.length == correct.length &&
        _selected.containsAll(correct);
  }

  void _tapOption(int i) {
    if (_checked) return;
    setState(() {
      if (_q.isMultiAnswer) {
        if (_selected.contains(i)) {
          _selected.remove(i);
        } else {
          if (_selected.length < _q.correctIndices.length) _selected.add(i);
        }
      } else {
        _selected
          ..clear()
          ..add(i);
      }
    });
  }

  void _check() {
    if (_selected.isEmpty) return;
    _speech.stop();
    setState(() {
      _checked = true;
      if (_isAnswerCorrect) _correct++;
    });
  }

  void _next() {
    _speech.stop();
    if (_index == _questions.length - 1) {
      widget.onFinished?.call(_correct, _questions.length);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            correct: _correct,
            total: _questions.length,
            questions: widget.questions,
            title: widget.title,
          ),
        ),
      );
      return;
    }
    setState(() {
      _index++;
      _selected.clear();
      _checked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = _q;
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: const DecoratedBox(
            decoration: BoxDecoration(gradient: AppColors.header)),
        title: Text(widget.title != null
            ? '${widget.title}  ${_index + 1}/${_questions.length}'
            : 'Quiz  ${_index + 1}/${_questions.length}'),
        actions: [
          ListenableBuilder(
            listenable: _speech,
            builder: (context, _) => IconButton(
              tooltip: _speech.isSpeaking ? 'Stop' : 'Read question',
              icon: Icon(_speech.isSpeaking
                  ? Icons.stop_circle_rounded
                  : Icons.volume_up_rounded),
              onPressed: () => _speech.toggle(_readText(q)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_index + 1) / _questions.length,
            minHeight: 5,
            backgroundColor: AppColors.bg,
            color: AppColors.accent,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Score: $_correct',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.slate,
                        ),
                      ),
                      const Spacer(),
                      if (q.isMultiAnswer)
                        Text(
                          'Choose ${q.correctIndices.length}',
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    q.question,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  for (var i = 0; i < q.options.length; i++)
                    _QuizOption(
                      letter: q.letterFor(i),
                      text: q.options[i],
                      state: _optionState(i),
                      onTap: () => _tapOption(i),
                    ),
                  if (_checked) ...[
                    const SizedBox(height: 8),
                    _Feedback(correct: _isAnswerCorrect, question: q),
                  ],
                ],
              ),
            ),
          ),
          _BottomBar(
            checked: _checked,
            canCheck: _selected.isNotEmpty,
            isLast: _index == _questions.length - 1,
            onCheck: _check,
            onNext: _next,
          ),
        ],
      ),
    );
  }

  _OptState _optionState(int i) {
    final isCorrect = _q.correctIndices.contains(i);
    final isSelected = _selected.contains(i);
    if (!_checked) {
      return isSelected ? _OptState.selected : _OptState.idle;
    }
    if (isCorrect) return _OptState.correct;
    if (isSelected && !isCorrect) return _OptState.wrong;
    return _OptState.idle;
  }

  String _readText(Question q) {
    final b = StringBuffer()..writeln(q.question);
    for (var i = 0; i < q.options.length; i++) {
      b.writeln('Option ${q.letterFor(i)}. ${q.options[i]}');
    }
    return b.toString();
  }
}

enum _OptState { idle, selected, correct, wrong }

class _QuizOption extends StatelessWidget {
  const _QuizOption({
    required this.letter,
    required this.text,
    required this.state,
    required this.onTap,
  });

  final String letter;
  final String text;
  final _OptState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color border = const Color(0xFFE2E8F0);
    Color fill = AppColors.card;
    Color badge = AppColors.slate.withValues(alpha: 0.15);
    Color badgeText = AppColors.slate;
    Widget? trailing;

    switch (state) {
      case _OptState.selected:
        border = AppColors.primary;
        fill = AppColors.primary.withValues(alpha: 0.06);
        badge = AppColors.primary;
        badgeText = Colors.white;
        break;
      case _OptState.correct:
        border = AppColors.good;
        fill = AppColors.good.withValues(alpha: 0.10);
        badge = AppColors.good;
        badgeText = Colors.white;
        trailing = const Icon(Icons.check_circle_rounded,
            color: AppColors.good, size: 20);
        break;
      case _OptState.wrong:
        border = AppColors.bad;
        fill = AppColors.bad.withValues(alpha: 0.08);
        badge = AppColors.bad;
        badgeText = Colors.white;
        trailing =
            const Icon(Icons.cancel_rounded, color: AppColors.bad, size: 20);
        break;
      case _OptState.idle:
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border, width: 1.4),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 13,
                backgroundColor: badge,
                child: Text(
                  letter,
                  style: TextStyle(
                    color: badgeText,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 14.5, height: 1.35),
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 8), trailing],
            ],
          ),
        ),
      ),
    );
  }
}

class _Feedback extends StatelessWidget {
  const _Feedback({required this.correct, required this.question});
  final bool correct;
  final Question question;

  @override
  Widget build(BuildContext context) {
    final color = correct ? AppColors.good : AppColors.bad;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                correct
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                correct
                    ? 'Correct!'
                    : 'Correct answer: ${question.correctLetters}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: color,
                  fontSize: 15,
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

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.checked,
    required this.canCheck,
    required this.isLast,
    required this.onCheck,
    required this.onNext,
  });

  final bool checked;
  final bool canCheck;
  final bool isLast;
  final VoidCallback onCheck;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
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
      child: SizedBox(
        width: double.infinity,
        child: checked
            ? FilledButton(
                onPressed: onNext,
                child: Text(isLast ? 'See results' : 'Next question'),
              )
            : FilledButton(
                onPressed: canCheck ? onCheck : null,
                child: const Text('Check answer'),
              ),
      ),
    );
  }
}
