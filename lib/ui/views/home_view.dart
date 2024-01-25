import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_meter/core/extensions/context_extenstion.dart';
import 'package:smart_meter/models/reading_model.dart';
import 'package:smart_meter/services/rtdb_service/rtdb_service.dart';
import 'package:smart_meter/ui/shared/app_constants.dart';
import 'package:smart_meter/ui/shared/spacing.dart';
import 'package:smart_meter/ui/views/drawer.dart';

import 'chart.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomePageSView();
}

class _HomePageSView extends State<HomeView> {
  final RTDBService _rtdbService = RTDBService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentPageIndex: 0),
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
          '${AppConstants.appName} (Power)',
          style: context.tTheme.titleLarge?.copyWith(
            color: context.cScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<List<ReadingModel>>(
        future: _rtdbService.getData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: context.tTheme.bodyMedium,
              ),
            );
          }
          final data = snapshot.data;
          if (data == null) {
            return Center(
              child: Text(
                'No data found',
                style: context.tTheme.bodyMedium,
              ),
            );
          }
          final sortedReadings =
              ([...data]..sort((a, b) => b.power.compareTo(a.power)));
          final latestReading = data.last;
          return ListView(
            padding: REdgeInsets.all(16),
            children: [
              CurrentReading(
                label: 'Current Reading',
                reading: latestReading,
              ),
              Spacing.vertRegular(),
              CurrentReading(
                label: 'Maximum Reading',
                reading: sortedReadings.first,
              ),
              Spacing.vertRegular(),
              CurrentReading(
                label: 'Minimum Reading',
                reading: sortedReadings.last,
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
                        'Reading Comparison',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Spacing.vertSmall(),
                      PowerComparisonChart(
                        readings: [
                          sortedReadings.last,
                          latestReading,
                          sortedReadings.first,
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class CurrentReading extends StatelessWidget {
  final String label;
  final ReadingModel reading;
  const CurrentReading({
    Key? key,
    required this.label,
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
              label,
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
            Spacing.vertSmall(),
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
