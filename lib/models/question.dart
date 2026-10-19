class Question {
  final int number;
  final String question;
  final List<String> options;
  final List<int> correctIndices;
  final String explanation;
  final bool isInfo;
  final int domain;

  const Question({
    required this.number,
    required this.question,
    required this.options,
    required this.correctIndices,
    required this.explanation,
    required this.isInfo,
    required this.domain,
  });

  bool get isMultiAnswer => correctIndices.length > 1;

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      number: json['number'] as int,
      question: json['question'] as String,
      options: (json['options'] as List).map((e) => e as String).toList(),
      correctIndices:
          (json['correctIndices'] as List).map((e) => e as int).toList(),
      explanation: json['explanation'] as String,
      isInfo: json['isInfo'] as bool? ?? false,
      domain: json['domain'] as int? ?? 0,
    );
  }

  String get correctLetters =>
      correctIndices.map((i) => String.fromCharCode(65 + i)).join(', ');

  String letterFor(int index) => String.fromCharCode(65 + index);
}
