import 'package:equatable/equatable.dart';

class EnergyModel extends Equatable {
  final num power; // in Watts
  final Duration interval; 

  const EnergyModel({
    required this.power,
    required this.interval,
  });

  const EnergyModel.initial()
      : power = 0,
        interval = Duration.zero;

  /// Power in Watts
  String get powerString => power.toStringAsFixed(2);

  /// Energy in kWh
  num get energy => power * interval.inMinutes / 60 / 1000;
  String get energyString => energy.toStringAsFixed(2);
  String get energyInExponential => energy.toStringAsExponential(2);

  @override
  List<Object> get props => [power, interval];
}
