import 'dart:convert';
import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:smart_meter/models/reading_model.dart';

import 'i_rtdb_service.dart';

class RTDBService extends IRTDBService {
  final _database = FirebaseDatabase.instance;

  Future<ReadingModel> getData() async {
    final res = await _database.ref('Smart_Meter').get();
    log(jsonEncode({"voltage": 3.2, "current": 0.1}).toString());
    // print(res.);
    // final data = (res.value as Map).cast<String, dynamic>();
    // {Voltage: 0, Current: 0.20517}
    // print(data);
    // return data.value;
    return ReadingModel(
      current: 1,
      voltage: 1,
      time: DateTime.now(),
    );
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
