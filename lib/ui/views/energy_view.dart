import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_meter/core/extensions/context_extenstion.dart';
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
    'Min',
    'Hour',
    'Day',
    'Week',
    'Month',
    'Year',
  ];

  String selectedFreq = 'Min';

  final controller = TextEditingController(text: '1');

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
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              hintText: 'Enter cost of 1 unit of electricity',
              prefixText: 'NGN ',
            ),
          ),
          Spacing.vertRegular(),
          CurrentReading(reading: mockReadings.last),
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
                    'Current Cost of Electricity',
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
                              '0.21',
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
                  SizedBox(
                    height: 37.r,
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
                  Spacing.vertSmall(),
                  const EnergyChart(),
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

class CurrentReading extends StatelessWidget {
  final ReadingModel reading;
  const CurrentReading({
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
              'Current Reading',
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
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Power (W)',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  reading.powerString,
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
