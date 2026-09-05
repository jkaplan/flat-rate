import 'package:flutter/material.dart';

import 'data/logbook.dart';
import 'data/sqflite_logbook.dart';
import 'logic/pay_periods.dart';
import 'ui/add_job_screen.dart';
import 'ui/end_of_day_screen.dart';
import 'ui/period_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(FlatRateApp(logbook: await SqfliteLogbook.open()));
}

class FlatRateApp extends StatelessWidget {
  const FlatRateApp({super.key, required this.logbook});

  final Logbook logbook;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Flat Rate',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
          useMaterial3: true,
        ),
        home: Home(logbook: logbook),
      );
}

class Home extends StatefulWidget {
  const Home({super.key, required this.logbook});

  final Logbook logbook;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  /// Opens on logging, because that is what happens in the bay. Reading the
  /// numbers happens later, sitting down.
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final anchor = _mondayOf(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: const Text('Flat Rate')),
      body: switch (_tab) {
        0 => AddJobScreen(logbook: widget.logbook),
        1 => EndOfDayScreen(logbook: widget.logbook),
        _ => PeriodScreen(
            logbook: widget.logbook,
            schedule: PaySchedule.weekly,
            anchor: anchor,
          ),
      },
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.add), label: 'Job'),
          NavigationDestination(icon: Icon(Icons.bedtime), label: 'Day'),
          NavigationDestination(icon: Icon(Icons.insights), label: 'Period'),
        ],
      ),
    );
  }
}

DateTime _mondayOf(DateTime day) =>
    DateTime(day.year, day.month, day.day - (day.weekday - 1));
