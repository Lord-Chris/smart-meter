import 'dart:convert';
import 'dart:math';

import 'package:equatable/equatable.dart';

class ReadingModel extends Equatable {
  final num current;
  final num voltage;
  final DateTime time;

  const ReadingModel({
    required this.current,
    required this.voltage,
    required this.time,
  });

  ReadingModel.initial()
      : current = 0,
        voltage = 0,
        time = DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'current': current,
      'voltage': voltage,
      'time': time.millisecondsSinceEpoch,
    };
  }

  factory ReadingModel.fromMap(Map<String, dynamic> map) {
    return ReadingModel(
      current: map['current'] ?? 0,
      voltage: map['voltage'] ?? 0,
      time: DateTime.fromMillisecondsSinceEpoch(map['time']),
    );
  }

  String toJson() => json.encode(toMap());

  factory ReadingModel.fromJson(String source) =>
      ReadingModel.fromMap(json.decode(source));

  num get power => current * voltage;
  String get powerString => power.toStringAsFixed(2);
  String get currentString => current.toStringAsFixed(2);
  String get voltageString => voltage.toStringAsFixed(2);

  @override
  List<Object> get props => [current, voltage, time];
}

final mockReadings = List.generate(
  1000,
  (index) => ReadingModel(
    current: Random().nextDouble(),
    voltage: Random().nextInt(40) + 200,
    time: DateTime.now().subtract(
      Duration(minutes: index * Random().nextInt(10)),
    ),
  ),
);
