import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../core/controllers/panic_controller.dart';
import '../core/models/panic_event.dart';

/// Foreground stand-in for FR-PANIC-3's on-device "help" wake-word listener.
///
/// The SRS/Algorithm Test Plan specify an always-on **background** listener
/// (e.g. Picovoice Porcupine) with its own FAR/FRR evaluation harness against
/// a recorded corpus (Algorithm Test Plan §3) — that requires a trained
/// keyword model and native background-service wiring neither available nor
/// testable in this environment. `speech_to_text` only supports foreground,
/// session-based listening (it stops after a pause and must be restarted),
/// so this restarts itself in a loop for as long as the feature is toggled
/// on, which approximates "always listening while the app is open" but is
/// NOT the same as a true background service, and has not been evaluated for
/// false-accept/false-reject rate the way the real implementation must be.
class VoiceTriggerController {
  final PanicController panicController;
  final SpeechToText _speech;
  bool _shouldBeListening = false;

  VoiceTriggerController(this.panicController, {SpeechToText? speech})
      : _speech = speech ?? SpeechToText();

  bool get isListening => _shouldBeListening;

  /// Returns false if speech recognition isn't available (permission denied,
  /// unsupported platform, etc.) — the toggle should reflect that rather than
  /// silently pretending to listen.
  Future<bool> start() async {
    final available = await _speech.initialize(onStatus: _onStatus);
    if (!available) return false;

    _shouldBeListening = true;
    await _listenOnce();
    return true;
  }

  void stop() {
    _shouldBeListening = false;
    _speech.stop();
  }

  void _onStatus(String status) {
    if (!_shouldBeListening) return;
    if (status == 'done' || status == 'notListening') {
      // Re-enter the event loop before restarting — speech_to_text does not
      // support calling listen() synchronously from within its own status
      // callback.
      Future.microtask(_listenOnce);
    }
  }

  Future<void> _listenOnce() async {
    if (!_shouldBeListening) return;
    await _speech.listen(
      onResult: _onResult,
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
      ),
    );
  }

  void _onResult(SpeechRecognitionResult result) {
    if (result.recognizedWords.toLowerCase().contains('help')) {
      // PanicController.trigger already dedupes concurrent/rapid triggers,
      // so no extra debounce is needed here even if "help" appears in
      // several consecutive partial results.
      panicController.trigger(PanicTrigger.voice);
    }
  }
}
