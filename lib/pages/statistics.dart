import 'package:diagnoma/classes/database.dart';
import 'package:diagnoma/classes/result.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late Database _database;
  int _totalResults = 0;
  int _noDR = 0;
  int _mildDR = 0;
  int _moderateDR = 0;
  int _severeDR = 0;
  int _proliferativeDR = 0;
  late List<ChartData> _chartData;

  Future<List<Result>> _loadResults() async {
    await DatabaseFileRoutines().readResults().then((resultsJson) {
      _database = databaseFromJson(resultsJson);
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

  void getStatistics() async {
    await _loadResults().then((resultsList) {
      setState(() {
        _totalResults = resultsList.length;
      });
      for (Result result in resultsList) {
        switch (getLabelWithHighestProbability(result.probabilities)) {
          case 'No DR':
            setState(() {
              _noDR++;
            });
            break;
          case 'Mild DR':
            setState(() {
              _mildDR++;
            });
            break;
          case 'Moderate DR':
            setState(() {
              _moderateDR++;
            });
            break;
          case 'Severe DR':
            setState(() {
              _severeDR++;
            });
            break;
          case 'Proliferative DR':
            setState(() {
              _proliferativeDR++;
            });
            break;
          default:
            break;
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getStatistics();
  }

  @override
  Widget build(BuildContext context) {
    _chartData = [
      ChartData('No DR', _noDR),
      ChartData('Mild DR', _mildDR),
      ChartData('Moderate DR', _moderateDR),
      ChartData('Severe DR', _severeDR),
      ChartData('Proliferative DR', _proliferativeDR)
    ];
    return Scaffold(
      body: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Flexible(
                fit: FlexFit.loose,
                flex: 1,
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  color: Colors.blue[100],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('Total patients diagnosed:'),
                      SizedBox(
                        width: 30.0,
                      ),
                      Text(_totalResults.toString()),
                    ],
                  ),
                ),
              ),
              Flexible(
                fit: FlexFit.tight,
                flex: 9,
                child: Container(
                  child: SfCircularChart(
                      tooltipBehavior: TooltipBehavior(enable: true),
                      title: ChartTitle(
                          text: 'Chart showing Statistics of various stages'),
                      legend: Legend(
                          isVisible: true,
                          title: LegendTitle(
                              text: 'Diabetic Retinopathy Stage',
                              textStyle: ChartTextStyle(
                                  color: Colors.red,
                                  fontSize: 15,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w900)),
                          overflowMode: LegendItemOverflowMode.wrap),
                      series: <CircularSeries>[
                        // Render pie chart
                        PieSeries<ChartData, String>(
                            enableSmartLabels: true,
                            dataSource: _chartData,
                            pointColorMapper: (ChartData data, _) => data.color,
                            xValueMapper: (ChartData data, _) => data.x,
                            yValueMapper: (ChartData data, _) => data.y,
                            enableTooltip: true,
                            selectionSettings: SelectionSettings(
                              enable: true,
                              selectedColor: Colors.red,
                              unselectedColor: Colors.grey,
                            ),
                            dataLabelSettings: DataLabelSettings(
                              isVisible: true,
                              textStyle: ChartTextStyle(color: Colors.white),
                              labelPosition: ChartDataLabelPosition.outside,
                              useSeriesColor: true,
                            )),
                      ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChartData {
  final String x;
  final int y;
  final Color color;
  ChartData(this.x, this.y, [this.color=Colors.black]);
}
