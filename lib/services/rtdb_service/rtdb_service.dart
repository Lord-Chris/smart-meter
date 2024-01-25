import 'package:firebase_database/firebase_database.dart';
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
    final stream = _database.ref('Smart_Meter').onChildAdded;

    return stream.map((event) {
      DataSnapshot res = event.snapshot;
      final data = (res.value as Map);
      var values = data.values.cast<Map>().toList();

      return values
          .map((e) => ReadingModel.fromMap(e.cast<String, dynamic>()))
          .toList();
    });
  }
}
