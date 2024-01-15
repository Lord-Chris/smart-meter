import 'dart:math';

import 'package:smart_meter/models/reading_model.dart';
import 'package:statistics/statistics.dart';

// void dmain() {
//   List<ReadingModel> data = [...mockReadings.sublist(0, 10)];
//   OutlierAnalyzer analyzer = OutlierAnalyzer(data);

//   // Add a new integer to the list
//   final newValue =
//       ReadingModel(current: .1, voltage: 200, time: DateTime.now());
//   analyzer.addDataPoint(newValue);

//   // Check if the new value is an outlier
//   if (analyzer.isOutlier(newValue)) {
//     print('$newValue is an outlier!');
//   } else {
//     print('$newValue is within the expected range.');
//   }
// }

class OutlierAnalyzer {
  List<ReadingModel> data;
  late double mean;
  late double stdDev;
  late double zScoreThreshold;

  OutlierAnalyzer(this.data) {
    analyzeData();
  }

  /// Analyzes the data and calculates the mean, standard deviation and threshold
  /// for outliers
  void analyzeData() {
    mean = data.map((e) => e.power).mean;
    stdDev = data.map((e) => e.power).standardDeviation;
    List<double> zScores =
        data.map((value) => (value.power - mean) / stdDev).toList();
    zScoreThreshold = determineThreshold(zScores, factor: 2.0);
  }

  /// Returns the threshold for outliers
  ///
  /// The threshold is calculated as the standard deviation of the z-scores
  /// multiplied by the factor. The default factor is 2.0.
  double determineThreshold(List<double> zScores, {double factor = 2.0}) {
    double sum = zScores.fold(0, (a, b) => a + b);
    double mean = sum / zScores.length;

    double sumOfSquaredDifferences =
        zScores.map((z) => (z - mean) * (z - mean)).fold(0, (a, b) => a + b);

    double stdDev = sqrt(sumOfSquaredDifferences / zScores.length);

    return stdDev * factor;
  }

  /// Adds a new data point to the list and re-analyzes the data
  void addDataPoint(ReadingModel value) {
    data.add(value);
    analyzeData();
  }

  /// Returns true if the value is an outlier
  bool isOutlier(ReadingModel value) {
    double zScore = (value.power - mean) / stdDev;
    return zScore.abs() > zScoreThreshold;
  }
}
