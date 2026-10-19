import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Wraps flutter_tts so the rest of the app never talks to the plugin directly.
class SpeechService extends ChangeNotifier {
  SpeechService._() {
    _init();
  }
  static final SpeechService instance = SpeechService._();

  final FlutterTts _tts = FlutterTts();
  bool _speaking = false;
  VoidCallback? _onDone;

  bool get isSpeaking => _speaking;

  Future<void> _init() async {
    await _tts.setSpeechRate(0.46);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    _tts.setCompletionHandler(() {
      _speaking = false;
      final done = _onDone;
      _onDone = null;
      notifyListeners();
      done?.call();
    });
    _tts.setCancelHandler(() {
      _onDone = null;
      _speaking = false;
      notifyListeners();
    });
    _tts.setErrorHandler((_) {
      _onDone = null;
      _speaking = false;
      notifyListeners();
    });
  }

  /// Speaks [text]. If [onDone] is given it fires only when speech finishes
  /// naturally (not when stopped/cancelled) — used to chain questions.
  Future<void> speak(String text, {VoidCallback? onDone}) async {
    await stop();
    if (text.trim().isEmpty) {
      onDone?.call();
      return;
    }
    _onDone = onDone;
    _speaking = true;
    notifyListeners();
    await _tts.speak(text);
  }

  Future<void> toggle(String text) async {
    if (_speaking) {
      await stop();
    } else {
      await speak(text);
    }
  }

  Future<void> stop() async {
    if (_speaking) {
      await _tts.stop();
    }
    _speaking = false;
    notifyListeners();
  }
}
