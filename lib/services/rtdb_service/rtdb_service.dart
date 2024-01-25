import 'package:firebase_database/firebase_database.dart';
import 'package:smart_meter/models/reading_model.dart';

import 'i_rtdb_service.dart';

class RTDBService extends IRTDBService {
  final _database = FirebaseDatabase.instance;

  Future<List<ReadingModel>> getData() async {
    DataSnapshot res = await _database.ref('Smart_Meter/data').get();

    print(res.value);
    final data = (res.value as Map);

    for (var val in data.values) {
      print(val);
    }

    var values = data.values.cast<Map>().toList();
    print(values);

    var innerValues = values.map((e) => e['current']).toList();
    print(innerValues);

    // print(values[0].key.runtimeType);

    // for (var val in values) {
    //   print((val as Map).keys.runtimeType);
    // }

    // // values = values.map((e) => e as Map).toList();
    // final values2 = [
    //   for (var val in values) val as Map<Object?, dynamic>,
    // ];
    // print(values2.runtimeType);

    // List<Map<String, dynamic>> values =
    //     List<Map<String, dynamic>>.from(jsonDecode(jsonEncode(data.values)));

    return values
        .map((e) => ReadingModel.fromMap(e.cast<String, dynamic>()))
        .toList();
  }

  Stream<ReadingModel> streamData() {
    final res = _database.ref('Smart_Meter').onChildAdded;

    return res.map((event) {
      final data = (event.snapshot.value as Map).cast<String, dynamic>();
      return ReadingModel(
        current: data['Current'],
        voltage: data['Voltage'],
        time: DateTime.now(),
      );
    });
  }
}
