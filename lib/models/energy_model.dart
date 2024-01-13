import 'dart:convert';

class EnergyModel {
  final num current;
  final num voltage;
  final Duration duration;

  const EnergyModel({
    required this.current,
    required this.voltage,
    required this.duration,
  });

  EnergyModel.initial()
      : current = 0,
        voltage = 0,
        duration = Duration.zero;

  Map<String, dynamic> toMap() {
    return {
      'current': current,
      'voltage': voltage,
      'duration': duration.inMicroseconds,
    };
  }

  factory EnergyModel.fromMap(Map<String, dynamic> map) {
    return EnergyModel(
      current: map['current'] ?? 0,
      voltage: map['voltage'] ?? 0,
      duration: Duration(microseconds: map['duration']),
    );
  }

  String toJson() => json.encode(toMap());

  factory EnergyModel.fromJson(String source) =>
      EnergyModel.fromMap(json.decode(source));

  /// Power in Watts
  num get power => (current * voltage) / 1000;
  String get powerString => power.toStringAsFixed(2);
  String get currentString => current.toStringAsFixed(2);
  String get voltageString => voltage.toStringAsFixed(2);

  /// Energy in kWh
  num get energy => power * duration.inHours;
  String get energyString => energy.toStringAsFixed(2);
  String get energyInExponential => energy.toStringAsExponential(2);
}
