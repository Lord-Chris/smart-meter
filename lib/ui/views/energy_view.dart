import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_meter/core/extensions/context_extenstion.dart';
import 'package:smart_meter/models/energy_model.dart';
import 'package:smart_meter/models/reading_model.dart';
import 'package:smart_meter/ui/shared/app_constants.dart';
import 'package:smart_meter/ui/shared/spacing.dart';

import 'chart.dart';
import 'drawer.dart';

class EnergyView extends StatefulWidget {
  const EnergyView({super.key});

  @override
  State<EnergyView> createState() => _HomePageSView();
}

class _HomePageSView extends State<EnergyView> {
  final freq = [
    'Hour',
    'Day',
    'Week',
    'Month',
    'Year',
  ];

  String selectedFreq = 'Hour';

  final controller = TextEditingController(text: '1');

  Duration _getDuration(String freq) {
    switch (freq) {
      case 'Hour':
        return const Duration(hours: 1);
      case 'Day':
        return const Duration(days: 1);
      case 'Week':
        return const Duration(days: 7);
      case 'Month':
        return const Duration(days: 30);
      case 'Year':
        return const Duration(days: 365);
      default:
        return const Duration(minutes: 1);
    }
  }

  int _getDivisions(String freq) {
    switch (freq) {
      case 'Hour':
        return 60;
      case 'Day':
        return 24;
      case 'Week':
        return 7;
      case 'Month':
        return 30;
      case 'Year':
        return 12;
      default:
        return 60;
    }
  }

  bool _sortData(String freq, int division, ReadingModel reading) {
    switch (freq) {
      case 'Hour':
        return reading.time.hour == division;
      case 'Day':
        return reading.time.day == division;
      case 'Week':
        return reading.time.weekday == division;
      case 'Month':
        return reading.time.month == division;
      case 'Year':
        return reading.time.year == division;
      default:
        return reading.time.hour == division;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedReadings = [...mockReadings].where((element) {
      return element.time
          .isAfter(DateTime.now().subtract(_getDuration(selectedFreq)));
    }).toList();

    final indexes =
        List.generate(_getDivisions(selectedFreq), (index) => index);

    final sortedReadings = {
      for (var item in indexes)
        item.toString(): selectedReadings
            .where((e) => _sortData(selectedFreq, item, e))
            .fold(
              EnergyModel.initial(),
              (previousValue, element) => EnergyModel(
                current: previousValue.current + element.current,
                voltage: previousValue.voltage + element.voltage,
                duration: _getDuration(selectedFreq),
              ),
            ),
    };

    final totalReading = selectedReadings.fold<EnergyModel>(
      EnergyModel.initial(),
      (previousValue, element) => EnergyModel(
        current: previousValue.current + element.current,
        voltage: previousValue.voltage + element.voltage,
        duration: _getDuration(selectedFreq),
      ),
    );
    return Scaffold(
      drawer: const AppDrawer(currentPageIndex: 1),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        iconTheme: IconThemeData(color: context.cScheme.onPrimary),
        leading: Builder(builder: (context) {
          return IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: const Icon(Icons.lightbulb),
          );
        }),
        title: Text(
          '${AppConstants.appName} (Energy)',
          style: context.tTheme.titleLarge?.copyWith(
            color: context.cScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: REdgeInsets.all(16),
        children: [
          SizedBox(
            height: 37.r,
            child: Center(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: freq.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final filter = freq[index];
                  return _buildFilterItem(
                    context,
                    filter,
                    isActive: filter == selectedFreq,
                    onTap: () {
                      setState(() => selectedFreq = filter);
                    },
                  );
                },
              ),
            ),
          ),
          Spacing.vertRegular(),
          const Text('Cost of 1 unit of Electricity:'),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              hintText: 'Enter cost of 1 unit of electricity',
              prefixText: 'NGN ',
            ),
          ),
          Spacing.vertRegular(),
          EnergyReading(reading: totalReading),
          Spacing.vertRegular(),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 3,
            child: Padding(
              padding: REdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    'Cost of Electricity over the last $selectedFreq',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Spacing.vertSmall(),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Cost of Electricity',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              (totalReading.energy *
                                      double.parse(controller.text))
                                  .toStringAsFixed(3),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Currency',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              'NGN',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Spacing.vertRegular(),
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: REdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    'Energy Consumption Chart in kWh',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Spacing.vertSmall(),
                  EnergyChart(freq: selectedFreq, readings: sortedReadings),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterItem(
    BuildContext context,
    String label, {
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: REdgeInsets.fromLTRB(10, 9, 10, 9),
          decoration: BoxDecoration(
            color: isActive ? Colors.amber : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: !isActive ? Border.all(color: Colors.amber) : null,
          ),
          child: Row(
            children: [
              Text(
                label,
                style: context.tTheme.bodySmall?.copyWith(
                  color: isActive ? Colors.white : Colors.amber,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EnergyReading extends StatelessWidget {
  final EnergyModel reading;
  const EnergyReading({
    Key? key,
    required this.reading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 3,
      child: Padding(
        padding: REdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              'Total Energy Reading',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Spacing.vertSmall(),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Current(A)',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        reading.currentString,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Voltage(V)',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        reading.voltageString,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Power (kW)',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        reading.powerString,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Energy (kWh)',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  reading.energyInExponential,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
