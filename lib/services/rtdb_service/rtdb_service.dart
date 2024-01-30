import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:smart_meter/core/utilities/outlier_analyzer.dart';
import 'package:smart_meter/models/reading_model.dart';

import 'i_rtdb_service.dart';

class RTDBService extends IRTDBService {
  final _database = FirebaseDatabase.instance;

  Future<List<ReadingModel>> getData() async {
    DataSnapshot res = await _database.ref('Smart_Meter/data').get();
    final data = (res.value as Map);
    var values = data.values.cast<Map>().toList();

    return values
        .map((e) => ReadingModel.fromMap(e.cast<String, dynamic>()))
        .toList();
  }

  Stream<List<ReadingModel>> streamData() {
    final stream = _database.ref('Smart_Meter/data').onChildAdded;

    return stream.transform(
      StreamTransformer<DatabaseEvent, List<ReadingModel>>.fromHandlers(
        handleData: (event, sink) {
          DataSnapshot res = event.snapshot;
          final data = (res.value as Map);
          var values = data.values.cast<Map>().toList();

          final parsedValues = values
              .map((e) => ReadingModel.fromMap(e.cast<String, dynamic>()))
              .toList();
          OutlierAnalyzer analyzer = OutlierAnalyzer(
            [...parsedValues.reversed.toList().sublist(1).reversed],
          );
          analyzer.isOutlier(parsedValues.last);
          sink.add(parsedValues);
        },
      ),
    );
  }
}
