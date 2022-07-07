import 'package:diagnoma/pages/statistics.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite/tflite.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'pages/history.dart';
import 'pages/home.dart';

void main() {
  SyncfusionLicense.registerLicense(
      "NT8mJyc2IWhiZH1nfWN9Z2NoYmF8YGJ8ampqanNiYmlmamlmanMDHmgyNSE6Nzp9IDI3NjYifT4TND4yOj99MDw+");
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  late String _value;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'diagnoma',
      debugShowCheckedModeBanner: false,
      home: MyHome(),
    );
  }
}

class MyHome extends StatefulWidget {
  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  int _currentIndex = 0;
  List _listPages = [];
  late Widget _currentPage;
  @override
  void initState() {
    super.initState();
    _listPages..add(Home())..add(StatisticsScreen())..add(History());
    _currentPage = Home();
  }

  void _changePage(int selectedIndex) {
    setState(() {
      _currentIndex = selectedIndex;
      _currentPage = _listPages[selectedIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('diagnoma'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: _currentPage,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label : 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_chart),
            label: 'Statistics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
        onTap: (selectedIndex) => _changePage(selectedIndex),
      ),
    );
  }
}
