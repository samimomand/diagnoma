import 'package:diagnoma/classes/database.dart';
import 'package:diagnoma/classes/result.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'historyResult.dart';

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  late Database _database;

  Future<List<Result>> _loadResults() async {
    await DatabaseFileRoutines().readResults().then((resultsJson) {
      _database = databaseFromJson(resultsJson);
      _database.result
          .sort((comp1, comp2) => comp2.dateTime.compareTo(comp1.dateTime));
    });
    return _database.result;
  }

  String getLabelWithHighestProbability(List<Probability> probabilities) {
    double highestConf = 0.0;
    var label;
    for (var value in probabilities) {
      if (value.confidence > highestConf) {
        highestConf = value.confidence;
        label = value.label;
      }
    }
    return label;
  }

  Widget _buildListViewSeparated(AsyncSnapshot snapshot) {
    return ListView.separated(
        itemBuilder: (BuildContext context, int index) {
          String _titleDate = DateFormat.yMMMd()
              .format(DateTime.parse(snapshot.data[index].dateTime));
          String _subtitle = getLabelWithHighestProbability(
              snapshot.data[index].probabilities);
          return Dismissible(
            key: Key(snapshot.data[index].id),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 16.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            secondaryBackground: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            child: ListTile(
              leading: Column(
                children: <Widget>[
                  Text(
                    DateFormat.d()
                        .format(DateTime.parse(snapshot.data[index].dateTime)),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 32.0,
                      color: Colors.blue,
                    ),
                  ),
                  Text(DateFormat.E()
                      .format(DateTime.parse(snapshot.data[index].dateTime))),
                ],
              ),
              title: Text(
                _titleDate,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(_subtitle),
              onTap: () {
                _openHistoryResult(
                  index: index,
                  result: snapshot.data[index],
                  label: getLabelWithHighestProbability(
                      snapshot.data[index].probabilities),
                );
              },
            ),
            onDismissed: (direction) {
              setState(() {
                _database.result.removeAt(index);
              });
              DatabaseFileRoutines().writeResults(databaseToJson(_database));
            },
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider(
            color: Colors.grey,
          );
        },
        itemCount: snapshot.data.length);
  }

  void _openHistoryResult({required int index, required Result result, required String label}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            HistoryResult(index: index, result: result, label: label),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      initialData: [],
      future: _loadResults(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return !snapshot.hasData
            ? Center(
                child: CircularProgressIndicator(),
              )
            : _buildListViewSeparated(snapshot);
      },
    );
  }
}
