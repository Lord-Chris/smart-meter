import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_meter/core/extensions/context_extenstion.dart';
import 'package:smart_meter/models/energy_model.dart';
import 'package:smart_meter/models/reading_model.dart';

class PowerComparisonChart extends StatelessWidget {
  final List<ReadingModel> readings;
  const PowerComparisonChart({
    Key? key,
    required this.readings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            show: true,
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 100,
                reservedSize: 22,
                getTitlesWidget: (value, _) {
                  return Text(
                    () {
                      switch (value.toInt()) {
                        case 0:
                          return 'Min';
                        case 1:
                          return 'Current';
                        case 2:
                          return 'Max';
                        default:
                          return '';
                      }
                    }(),
                    style: context.tTheme.labelSmall,
                    textAlign: TextAlign.left,
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 100,
                reservedSize: 22,
                getTitlesWidget: (value, _) {
                  return Text(
                    value.toInt().toString(),
                    style: context.tTheme.labelSmall,
                    textAlign: TextAlign.left,
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade400,
              ),
              left: BorderSide(
                color: Colors.grey.shade400,
              ),
            ),
          ),
          minY: 0,
          maxY: (readings.last.power.toDouble() + 30).ceilToDouble(),
          barGroups: readings
              .map(
                (reading) => BarChartGroupData(
                  x: readings.indexOf(reading),
                  barRods: [
                    BarChartRodData(
                      toY: reading.power.toDouble(),
                      color: context.cScheme.inversePrimary,
                      width: 100.r,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(10),
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class EnergyChart extends StatefulWidget {
  final String freq;
  final Map<String, EnergyModel> readings;
  const EnergyChart({
    Key? key,
    required this.freq,
    required this.readings,
  }) : super(key: key);

  @override
  State<EnergyChart> createState() => _EnergyChartState();
}

class _EnergyChartState extends State<EnergyChart> {
  bool showAvg = false;
  List<Color> gradientColors = [
    Colors.yellow,
    Colors.amber,
    Colors.orangeAccent,
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.3,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 18,
              left: 12,
              top: 24,
              bottom: 12,
            ),
            child: LineChart(
              mainData(widget.freq, widget.readings),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData mainData(String freq, Map<String, EnergyModel> readings) {
    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(
        show: true,
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          axisNameWidget: Text(freq, style: context.tTheme.labelSmall),
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, _) {
              return Text(
                value.toInt().toString(),
                style: context.tTheme.labelSmall,
                textAlign: TextAlign.left,
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          axisNameWidget: Text(
            'Energy (kWh)',
            style: context.tTheme.labelSmall,
          ),
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 25,
            getTitlesWidget: (value, _) {
              return Padding(
                padding: REdgeInsets.only(left: 2),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value.toInt().toString(),
                    style: context.tTheme.labelSmall,
                    textAlign: TextAlign.left,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade400),
          left: BorderSide(color: Colors.grey.shade400),
        ),
      ),
      minX: 0,
      lineBarsData: [
        LineChartBarData(
          spots: [
            for (var item in readings.entries)
              FlSpot(
                double.parse(item.key),
                item.value.energy.toDouble(),
              ),
          ],
          barWidth: 3,
          preventCurveOverShooting: true,
          isCurved: true,
          gradient: LinearGradient(colors: gradientColors),
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
