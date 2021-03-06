import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ScoreChart extends StatelessWidget {
  final List<ChartDataEntry> data;

  const ScoreChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final List<ChartDataEntry> sortedData = data;
    sortedData.sort((a, b) => a.score.compareTo(b.score));
    return Container(
        padding: EdgeInsets.all(20),
        height: 300,
        //color: Colors.red,
        child: BarChart(BarChartData(
            alignment: BarChartAlignment.spaceEvenly,
            maxY: getMaxY(),
            barGroups: sortedData
                .map((e) => BarChartGroupData(
                      x: e.score,
                      barRods: [
                        BarChartRodData(
                            y: e.count.toDouble(),
                            width: 15,
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(10)),
                            colors: [
                              Colors.deepPurple,
                              Theme.of(context).accentColor,
                            ])
                      ],
                      showingTooltipIndicators: [0],
                    ))
                .toList(),
            barTouchData: BarTouchData(
              enabled: false,
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: Colors.transparent,
                tooltipPadding: const EdgeInsets.all(0),
                tooltipMargin: 4,
                getTooltipItem: (
                  BarChartGroupData group,
                  int groupIndex,
                  BarChartRodData rod,
                  int rodIndex,
                ) {
                  return BarTooltipItem(
                    rod.y.round().toString(),
                    TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
                leftTitles: SideTitles(
                  showTitles: true,
                  interval: 4,
                  getTextStyles: (value) {
                    return TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12);
                  },
                ),
                bottomTitles: SideTitles(
                  showTitles: true,
                  getTextStyles: (value) {
                    return TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12);
                  },
                  getTitles: (value) => value.toInt().toString(),
                )))));
  }

  double getMinY() {
    int min = 9999999;
    for (final element in data) {
      if (element.count < min) min = element.count;
    }
    return min - 5;
  }

  double getMaxY() {
    int max = 0;
    for (final element in data) {
      if (element.count > max) max = element.count;
    }
    return max + 4;
  }
}

class ChartDataEntry {
  final int score;
  final int count;
  ChartDataEntry({required this.score, required this.count});
}
