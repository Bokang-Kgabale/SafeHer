/// A single accelerometer-magnitude reading at a point in time since
/// monitoring started. `magnitude` is `sqrt(ax^2 + ay^2 + az^2)` in m/s^2 —
/// resting gravity alone reads ~9.8; true weightlessness (free fall) reads
/// near 0; a hard impact spikes well above resting gravity.
class AccelMagnitudeSample {
  final Duration t;
  final double magnitude;

  const AccelMagnitudeSample(this.t, this.magnitude);
}

class FallDetectionResult {
  final bool confirmed;
  final Duration? impactAt;

  const FallDetectionResult({required this.confirmed, this.impactAt});
}

/// Three-phase fall detector (SRS FR-PANIC-5, Algorithm Test Plan §4):
/// free-fall dip -> impact spike -> post-impact stillness. Requiring all
/// three in sequence is what distinguishes a genuine fall from a dropped
/// phone (impact with no preceding free-fall), a quick stumble (impact but
/// no subsequent stillness — she caught herself), or jogging (repeated
/// impacts with no free-fall dip at all).
///
/// Tuning defaults are provisional — real acceptance requires evaluating
/// against recorded on-device waveforms (phone-drop, sit-down, jogging,
/// genuine-fall corpora), not just the synthetic fixtures used in this
/// repo's unit tests. See Algorithm Test Plan §4.4.
class FallDetector {
  final double freeFallThreshold;
  final Duration minFreeFallDuration;
  final double impactThreshold;
  final Duration impactWindow;
  final Duration stillnessWindow;
  final double stillnessVarianceThreshold;

  /// Magnitude reads ~9.8 m/s^2 at rest *regardless of device orientation*,
  /// since it's the rotation-invariant magnitude of the gravity vector alone.
  /// "Stillness" therefore means low variance **and** back near this value —
  /// low variance alone isn't enough, or a sustained non-resting magnitude
  /// (e.g. constant acceleration during a controlled movement) would
  /// wrongly count as having come to rest.
  final double restingMagnitude;
  final double restingTolerance;

  const FallDetector({
    this.freeFallThreshold = 2.0,
    this.minFreeFallDuration = const Duration(milliseconds: 150),
    this.impactThreshold = 25.0,
    this.impactWindow = const Duration(seconds: 1),
    this.stillnessWindow = const Duration(seconds: 2),
    this.stillnessVarianceThreshold = 1.5,
    this.restingMagnitude = 9.8,
    this.restingTolerance = 2.5,
  });

  factory FallDetector.defaultTuning() => const FallDetector();

  /// Evaluates a fixed batch of samples (used by tests, and by the offline
  /// evaluation harness). The live [FallDetectionService] instead feeds a
  /// rolling window of the last few seconds through this same method on
  /// every new sensor reading.
  FallDetectionResult evaluate(List<AccelMagnitudeSample> samples) {
    var i = 0;
    while (i < samples.length) {
      if (samples[i].magnitude >= freeFallThreshold) {
        i++;
        continue;
      }

      final freeFallStart = samples[i].t;
      var j = i;
      while (j < samples.length && samples[j].magnitude < freeFallThreshold) {
        j++;
      }
      final freeFallEnd = samples[j - 1].t;

      if (freeFallEnd - freeFallStart < minFreeFallDuration) {
        i = j;
        continue;
      }

      final impactIndex = _findImpact(samples, from: j, after: freeFallEnd);
      if (impactIndex != null && _isStillAfter(samples, impactIndex)) {
        return FallDetectionResult(confirmed: true, impactAt: samples[impactIndex].t);
      }

      i = j;
    }
    return const FallDetectionResult(confirmed: false);
  }

  int? _findImpact(List<AccelMagnitudeSample> samples, {required int from, required Duration after}) {
    final deadline = after + impactWindow;
    for (var k = from; k < samples.length && samples[k].t <= deadline; k++) {
      if (samples[k].magnitude > impactThreshold) return k;
    }
    return null;
  }

  bool _isStillAfter(List<AccelMagnitudeSample> samples, int impactIndex) {
    final impactTime = samples[impactIndex].t;
    final deadline = impactTime + stillnessWindow;
    final window = samples
        .where((s) => s.t > impactTime && s.t <= deadline)
        .map((s) => s.magnitude)
        .toList();

    // Not enough data yet to judge stillness — caller should re-evaluate
    // once more samples arrive rather than treating this as a rejection.
    if (window.length < 3) return false;

    final mean = window.reduce((a, b) => a + b) / window.length;
    final variance =
        window.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b) / window.length;
    final nearResting = (mean - restingMagnitude).abs() <= restingTolerance;
    return variance < stillnessVarianceThreshold && nearResting;
  }
}
