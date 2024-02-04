import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_meter/models/energy_model.dart';
import 'package:smart_meter/ui/shared/app_constants.dart';
import 'package:smart_meter/ui/shared/spacing.dart';

import '../../core/_core.dart';
import '../../services/rtdb_service/rtdb_service.dart';
import 'chart.dart';
import 'drawer.dart';

class EnergyView extends StatefulWidget {
  const EnergyView({super.key});

  @override
  State<EnergyView> createState() => _HomePageSView();
}

class _HomePageSView extends State<EnergyView> {
  final RTDBService _rtdbService = RTDBService();
  final freq = [
    'Hour',
    'Day',
    'Week',
    'Month',
    'Year',
  ];

  String selectedFreq = 'Hour';
  final controller = TextEditingController(text: '1');

  List<EnergyModel> _getDataSet(List<EnergyModel> data) {
    /// Filter the data based on the selected frequency
    List<EnergyModel> dataToUse = [];

    /// Add data to `dataToUse` if the total time in `dataToUse` is
    /// less than the selected frequency
    for (var i = 0; i < data.length; i++) {
      if (dataToUse.isEmpty) {
        dataToUse.add(data[i]);
      } else {
        final totalDuration = dataToUse.fold(
          const Duration(),
          (previousValue, element) => previousValue + element.interval,
        );

        if (totalDuration < GeneralUtil.getDuration(selectedFreq)) {
          dataToUse.add(data[i]);
        }
      }
    }

    return dataToUse;
  }

  EnergyModel _getTotalEnergyUsage(List<EnergyModel> dataToUse) {
    return dataToUse.fold<EnergyModel>(
      const EnergyModel.initial(),
      (previousValue, element) => EnergyModel(
        power: previousValue.power + element.power,
        interval: previousValue.interval + element.interval,
      ),
    );
  }

  Map<String, EnergyModel> _getEnergyChartDetails(List<EnergyModel> dataToUse) {
    /// Create a map of the readings based on the selected frequency
    /// e.g. if the selected frequency is `Hour`, the map will be
    /// {
    ///  '0': EnergyModel,
    ///  '1': EnergyModel,
    /// '2': EnergyModel,
    /// '3': EnergyModel,
    /// }
    /// where the key is the index and the value is the total reading
    /// for that index
    final sortedReadings = <String, EnergyModel>{};
    for (int i = 0; i < GeneralUtil.getDivisions(selectedFreq); i++) {
      var maxDuration = Duration(
        minutes: GeneralUtil.getDuration(selectedFreq).inMinutes ~/
            GeneralUtil.getDivisions(selectedFreq) *
            (i + 1),
      );

      final energyList =
          dataToUse.where((e) => e.interval.inMinutes < maxDuration.inMinutes);

      dataToUse = dataToUse.toSet().difference(energyList.toSet()).toList();

      sortedReadings[i.toString()] = energyList.fold(
        const EnergyModel.initial(),
        (previousValue, element) => EnergyModel(
          power: previousValue.power + element.power,
          interval: maxDuration,
        ),
      );
    }

    return sortedReadings;
  }

  @override
  Widget build(BuildContext context) {
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
            onChanged: (value) => setState(() {}),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              hintText: 'Enter cost of 1 unit of electricity',
              prefixText: 'NGN ',
            ),
          ),
          Spacing.vertRegular(),
          StreamBuilder<List<EnergyModel>>(
            stream: _rtdbService.streamEnergy(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Text('An error occured'),
                );
              }

              final data = snapshot.data;

              if (data == null || data.isEmpty) {
                return const Center(
                  child: Text('No data available'),
                );
              }

              final dataSet = _getDataSet(data);
              final totalReading = _getTotalEnergyUsage(dataSet);
              final sortedReadings = _getEnergyChartDetails(dataSet);

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  EnergyReading(reading: totalReading),
                  Spacing.vertRegular(),
                  ElectricityCost(
                    selectedFreq: selectedFreq,
                    totalEnergy: totalReading.energy,
                    cost: double.tryParse(controller.text) ?? 1,
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
                          EnergyChart(
                            freq: selectedFreq,
                            readings: sortedReadings,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
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

class ElectricityCost extends StatelessWidget {
  const ElectricityCost({
    super.key,
    required this.selectedFreq,
    required this.totalEnergy,
    required this.cost,
  });

  final String selectedFreq;
  final num totalEnergy;
  final num cost;

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
                        (totalEnergy * cost).toStringAsFixed(3),
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
                // Expanded(
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.center,
                //     children: [
                //       Text(
                //         'Current(A)',
                //         style: Theme.of(context).textTheme.titleSmall,
                //       ),
                //       Text(
                //         reading.currentString,
                //         style: Theme.of(context).textTheme.bodySmall,
                //       ),
                //     ],
                //   ),
                // ),
                // Expanded(
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.center,
                //     children: [
                //       Text(
                //         'Voltage(V)',
                //         style: Theme.of(context).textTheme.titleSmall,
                //       ),
                //       Text(
                //         reading.voltageString,
                //         style: Theme.of(context).textTheme.bodySmall,
                //       ),
                //     ],
                //   ),
                // ),
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
                Expanded(
                  child: Column(
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
