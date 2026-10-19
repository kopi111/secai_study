import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/question_repository.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await QuestionRepository.instance.load();
  runApp(const SecAiStudyApp());
}

class SecAiStudyApp extends StatelessWidget {
  const SecAiStudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SecAI+ Study',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const HomeScreen(),
    );
  }
}
