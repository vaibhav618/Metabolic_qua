class BreathingSettings {
  final BreathingPhase inhale;
  final HoldPhase hold;
  final BreathingPhase exhale;

  const BreathingSettings({
    required this.inhale,
    required this.hold,
    required this.exhale,
  });

  factory BreathingSettings.fromJson(dynamic json) {
    final Map<String, dynamic> data =
    json is Map<String, dynamic> ? json : const {};

    return BreathingSettings(
      inhale: BreathingPhase.fromJson(data['inhale'], fallback: const BreathingPhase.defaultsInhale()),
      hold: HoldPhase.fromJson(data['hold'], fallback: const HoldPhase.defaults()),
      exhale: BreathingPhase.fromJson(data['exhale'], fallback: const BreathingPhase.defaultsExhale()),
    );
  }

  factory BreathingSettings.defaults() => const BreathingSettings(
    inhale: BreathingPhase.defaultsInhale(),
    hold: HoldPhase.defaults(),
    exhale: BreathingPhase.defaultsExhale(),
  );

  Map<String, dynamic> toJson() => {
    'inhale': inhale.toJson(),
    'hold': hold.toJson(),
    'exhale': exhale.toJson(),
  };
}

class HoldPhase {
  final int timeMs;

  const HoldPhase({
    required this.timeMs,
  });

  factory HoldPhase.fromJson(
      dynamic json, {
        required HoldPhase fallback,
      }) {
    final Map<String, dynamic> data =
    json is Map<String, dynamic> ? json : const {};

    final int ms = _toInt(data['time_ms'], fallback.timeMs);
    final int safeMs = _clamp(ms, min: 500, max: 30000);

    return HoldPhase(timeMs: safeMs);
  }

  const HoldPhase.defaults() : timeMs = 5000;

  Map<String, dynamic> toJson() => {
    'time_ms': timeMs,
  };

  static int _toInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value.trim()) ?? fallback;
    if (value is double) return value.toInt();
    return fallback;
  }

  static int _clamp(int v, {required int min, required int max}) {
    if (v < min) return min;
    if (v > max) return max;
    return v;
  }
}

class BreathingPhase {
  final int threshold;
  final int timeMs;
  final int minBand;
  final int maxBand;

  const BreathingPhase({
    required this.threshold,
    required this.timeMs,
    required this.minBand,
    required this.maxBand,
  });

  factory BreathingPhase.fromJson(
      dynamic json, {
        required BreathingPhase fallback,
      }) {
    final Map<String, dynamic> data =
    json is Map<String, dynamic> ? json : const {};

    final int threshold = _clamp(_toInt(data['threshold'], fallback.threshold), min: 1, max: 20);
    final int timeMs = _clamp(_toInt(data['time_ms'], fallback.timeMs), min: 200, max: 30000);

    final int minBand = _clamp(_toInt(data['min_band'], fallback.minBand), min: 0, max: 100);
    final int maxBand = _clamp(_toInt(data['max_band'], fallback.maxBand), min: 0, max: 100);

    final int safeMinBand = minBand <= maxBand ? minBand : maxBand;
    final int safeMaxBand = maxBand >= minBand ? maxBand : minBand;

    return BreathingPhase(
      threshold: threshold,
      timeMs: timeMs,
      minBand: safeMinBand,
      maxBand: safeMaxBand,
    );
  }

  const BreathingPhase.defaultsInhale()
      : threshold = 5,
        timeMs = 3000,
        minBand = 25,
        maxBand = 80;

  const BreathingPhase.defaultsExhale()
      : threshold = 4,
        timeMs = 3000,
        minBand = 25,
        maxBand = 80;

  Map<String, dynamic> toJson() => {
    'threshold': threshold,
    'time_ms': timeMs,
    'min_band': minBand,
    'max_band': maxBand,
  };

  static int _toInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value.trim()) ?? fallback;
    if (value is double) return value.toInt();
    return fallback;
  }

  static int _clamp(int v, {required int min, required int max}) {
    if (v < min) return min;
    if (v > max) return max;
    return v;
  }
}
