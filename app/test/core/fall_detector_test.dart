import 'package:flutter_test/flutter_test.dart';
import 'package:safeher/core/algorithms/fall_detector.dart';

/// These fixtures are synthetic (hand-authored waveforms), not recordings
/// from a real device. They exist to validate the three-phase state-machine
/// LOGIC in fall_detector.dart — they are not a substitute for the real
/// on-device recording corpus the Algorithm Test Plan (§4.4) calls for
/// before shipping fall-detection tuning to a pilot. Treat a pass here as
/// "the algorithm does what it's designed to do," not "the thresholds are
/// correct for a real phone in a real pocket."
List<AccelMagnitudeSample> _segments(List<(int startMs, int endMs, double magnitude)> segments) {
  const stepMs = 20;
  final samples = <AccelMagnitudeSample>[];
  for (final segment in segments) {
    for (var ms = segment.$1; ms < segment.$2; ms += stepMs) {
      samples.add(AccelMagnitudeSample(Duration(milliseconds: ms), segment.$3));
    }
  }
  return samples;
}

void main() {
  group('FallDetector', () {
    final detector = FallDetector.defaultTuning();

    test('genuine fall pattern (dip, spike, stillness) is confirmed', () {
      final samples = _segments([
        (0, 500, 9.8), // standing still, holding phone
        (500, 700, 0.5), // free fall (~200ms)
        (700, 720, 40.0), // impact
        (720, 3000, 9.7), // lying still on the ground afterwards
      ]);

      final result = detector.evaluate(samples);
      expect(result.confirmed, isTrue);
    });

    test('a dropped phone (impact with no preceding free-fall) is rejected', () {
      final samples = _segments([
        (0, 500, 9.8),
        // No sustained free-fall dip — phone was released, not the whole body falling.
        (500, 520, 35.0), // hits the floor
        (520, 3000, 9.8), // sits still on the floor afterwards (would otherwise look "still")
      ]);

      final result = detector.evaluate(samples);
      expect(result.confirmed, isFalse);
    });

    test('a free-fall dip too short to be a real fall is rejected', () {
      final samples = _segments([
        (0, 500, 9.8),
        (500, 560, 0.5), // only 60ms of low-g — below minFreeFallDuration (150ms)
        (560, 580, 30.0),
        (580, 3000, 9.8),
      ]);

      final result = detector.evaluate(samples);
      expect(result.confirmed, isFalse);
    });

    test('a stumble with fast recovery (no post-impact stillness) is rejected', () {
      final samples = _segments([
        (0, 500, 9.8),
        (500, 700, 0.8), // stumbles, brief free fall
        (700, 720, 27.0), // catches herself hard against something
        // Immediately active again — walking/adjusting, not lying still.
        (720, 3000, 14.0),
      ]);

      final result = detector.evaluate(samples);
      expect(result.confirmed, isFalse);
    });

    test('jogging (rhythmic footstrike spikes, no free-fall dip) produces no false positive', () {
      final segments = <(int, int, double)>[];
      for (var cycle = 0; cycle < 50; cycle++) {
        final base = cycle * 400;
        // Stays above the free-fall threshold throughout — footstrikes are
        // impact-like but never preceded by near-weightlessness.
        segments.add((base, base + 350, 12.0));
        segments.add((base + 350, base + 400, 22.0));
      }
      final samples = _segments(segments);

      final result = detector.evaluate(samples);
      expect(result.confirmed, isFalse);
    });

    test('a fall down stairs (impact, brief movement, then a later impact+stillness) is confirmed', () {
      final samples = _segments([
        (0, 500, 9.8),
        (500, 700, 1.0), // first free-fall segment (~180ms discretized)
        (700, 720, 28.0), // first impact (mid-stairs)
        (720, 900, 14.0), // tumbling — not still
        (900, 1100, 1.5), // second free-fall segment (~180ms discretized)
        (1100, 1120, 32.0), // final impact
        (1120, 3300, 9.7), // now still at the bottom
      ]);

      final result = detector.evaluate(samples);
      expect(result.confirmed, isTrue);
      // Confirms on the second (genuine) impact — the first is correctly
      // rejected because the "tumbling" window afterwards isn't still.
      expect(result.impactAt, const Duration(milliseconds: 1100));
    });
  });
}
