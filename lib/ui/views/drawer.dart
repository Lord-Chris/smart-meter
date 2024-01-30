import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_meter/core/extensions/context_extenstion.dart';
import 'package:smart_meter/ui/views/home_view.dart';

import 'energy_view.dart';

class AppDrawer extends StatelessWidget {
  final int currentPageIndex;
  const AppDrawer({
    Key? key,
    required this.currentPageIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.amber,
            ),
            child: Icon(
              Icons.lightbulb,
              size: 100.r,
              color: context.cScheme.onPrimary,
            ),
          ),
          ListTile(
            title: const Text('Power Readings - I & V'),
            onTap: () {
              Navigator.pop(context);
              if (currentPageIndex != 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeView()),
                );
              }
            },
          ),
          Divider(color: context.cScheme.primary),
          ListTile(
            title: const Text('Energy Readings'),
            onTap: () {
              Navigator.pop(context);
              if (currentPageIndex != 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const EnergyView()),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
