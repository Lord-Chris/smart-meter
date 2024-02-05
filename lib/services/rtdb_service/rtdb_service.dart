import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:smart_meter/core/utilities/outlier_analyzer.dart';
import 'package:smart_meter/models/energy_model.dart';
import 'package:smart_meter/models/reading_model.dart';
import 'package:smart_meter/services/notification_service/notification_service.dart';

import 'i_rtdb_service.dart';

class RTDBService extends IRTDBService {
  final _database = FirebaseDatabase.instance;
  final _notification = NotificationService.instance;

  Future<List<ReadingModel>> getData() async {
    DataSnapshot res = await _database.ref('Smart_Meter/data').get();
    final data = (res.value as Map);
    var values = data.values.cast<Map>().toList();

    return values
        .map((e) => ReadingModel.fromMap(e.cast<String, dynamic>()))
        .toList();
  }

  Stream<List<ReadingModel>> streamPower() {
    final stream = _database.ref('Smart_Meter').child('data').onValue;

    return stream.transform(
      StreamTransformer<DatabaseEvent, List<ReadingModel>>.fromHandlers(
        handleData: (event, sink) {
          DataSnapshot res = event.snapshot;
          final data = (res.value as Map);
          var values = data.values.cast<Map>().toList();

          final parsedValues = values
              .map((e) => ReadingModel.fromMap(e.cast<String, dynamic>()))
              .toList();
          parsedValues.sort((a, b) => a.time.compareTo(b.time));
          sink.add(parsedValues);
        },
      ),
    );
  }

  Stream<List<EnergyModel>> streamEnergy() {
    final stream = _database.ref('Smart_Meter').child('data').onValue;

    return stream.transform(
      StreamTransformer<DatabaseEvent, List<EnergyModel>>.fromHandlers(
        handleData: (event, sink) {
          DataSnapshot res = event.snapshot;
          final data = (res.value as Map);
          var values = data.values.cast<Map>().toList();

          final powerValues = values
              .map((e) => ReadingModel.fromMap(e.cast<String, dynamic>()))
              .toList();

          List<EnergyModel> energyValues = [];

          for (var i = 1; i < powerValues.length; i++) {
            final time = powerValues[i].time;
            final power = powerValues[i].power;
            final prevTime = powerValues[i - 1].time;

            final energy = EnergyModel(
              power: power,
              interval: time.difference(prevTime),
            );

            energyValues.add(energy);
          }

          OutlierAnalyzer analyzer = OutlierAnalyzer(
            [...energyValues.reversed.toList().sublist(1).reversed],
          );
          final isStrange = analyzer.isOutlier(energyValues.last);
          if (isStrange) {
            _notification.showNotification();
          }

          sink.add(energyValues);
        },
      ),
    );
  }
}
