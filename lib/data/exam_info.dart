class ExamDomain {
  final String title;
  final int weight;
  final String summary;

  const ExamDomain({
    required this.title,
    required this.weight,
    required this.summary,
  });
}

/// Official CompTIA SecAI+ (CY0-001) exam domains and weightings.
const String kExamCode = 'CY0-001';
const String kExamName = 'CompTIA SecAI+';
const String kExamModule = 'SecAI+ (CY0-001) — Security for AI Systems';

const List<ExamDomain> kExamDomains = [
  ExamDomain(
    title: 'Basic AI Concepts Related to Cybersecurity',
    weight: 17,
    summary:
        'AI types and techniques: generative AI, machine learning, deep learning, '
        'NLP, transformers, LLMs and SLMs, GANs, supervised/unsupervised/reinforcement '
        'learning, model training and validation, fine-tuning, epoch, pruning, and quantization.',
  ),
  ExamDomain(
    title: 'Securing AI Systems',
    weight: 40,
    summary:
        'Security controls for AI: model controls and guardrails, prompt templates, '
        'gateway controls (prompt firewalls, rate and token limits), endpoint and '
        'access controls for models, data, agents and APIs, and data security '
        'controls including encryption and data safety.',
  ),
  ExamDomain(
    title: 'AI-assisted Security',
    weight: 24,
    summary:
        'Implementing monitoring and auditing for AI systems and using AI to '
        'automate security tasks such as triage, detection, and response.',
  ),
  ExamDomain(
    title: 'AI Governance, Risk, and Compliance',
    weight: 19,
    summary:
        'How governance, risk, and compliance (GRC) impacts AI technologies on a '
        'global scale, including frameworks, regulations, and threat modeling.',
  ),
];
