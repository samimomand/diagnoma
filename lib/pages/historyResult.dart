import 'dart:io';

import 'package:diagnoma/classes/result.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class HistoryResult extends StatefulWidget {
  int index;
  Result result;
  String label;

  HistoryResult({required this.index, required this.result, required this.label});

  @override
  _HistoryResultState createState() => _HistoryResultState();
}

class _HistoryResultState extends State<HistoryResult> {
  late int _index;
  late Result _result;
  late String _imagePath;
  late String _label;

  @override
  void initState() {
    super.initState();
    _index = widget.index;
    _result = widget.result;
    _label = widget.label;
    setImagePath();
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  void setImagePath() async {
    await _localPath.then((path) {
      setState(() {
        _imagePath = '$path/${_result.id}.jpg';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Result'),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Flexible(
                  fit: FlexFit.loose,
                  flex: 1,
                  child: Container(
                    padding: EdgeInsets.all(5.0),
                    color: Colors.blue[100],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Text(
                          DateFormat.yMMMEd()
                              .format(DateTime.parse(_result.dateTime)),
                          style: TextStyle(color: Colors.cyan[900]),
                        ),
                        SizedBox(
                          width: 30.0,
                        ),
                        Text(
                          DateFormat.jms()
                              .format(DateTime.parse(_result.dateTime)),
                          style: TextStyle(color: Colors.cyan[900]),
                        ),
                      ],
                    ),
                  ),
                ),
                Flexible(fit: FlexFit.tight, flex: 8, child: Image.file(File(_imagePath)),),
                Flexible(
                  fit: FlexFit.loose,
                  flex: 1,
                  child: Container(
                    color: Colors.blue[100],
                    padding: EdgeInsets.all(20.0),
                    child: Center(
                      child: Text(
                        _label,
                        style: TextStyle(
                          color: Colors.cyan[900],
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('_label', _label));
  }
}
