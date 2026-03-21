import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:flutter/material.dart';

class PieChart extends StatefulWidget {
  const PieChart({super.key});

  @override
  State<PieChart> createState() => _PieChartState();
}

class _PieChartState extends State<PieChart> {
  int touchedIndex = -1;

  static const _sectionColors = [
    Color(0xFF2196F3),
    Color(0xFFFFC107),
    Color(0xFF9C27B0),
    Color(0xFF4CAF50),
  ];

  static const _sectionLabels = ['First', 'Second', 'Third', 'Fourth'];
  static const _sectionValues = [40.0, 30.0, 15.0, 15.0];

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Row(
        children: [
          const SizedBox(height: 18),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: fl.PieChart(
                fl.PieChartData(
                  pieTouchData: fl.PieTouchData(
                    touchCallback:
                        (fl.FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex =
                                pieTouchResponse
                                    .touchedSection!
                                    .touchedSectionIndex;
                          });
                        },
                  ),
                  borderData: fl.FlBorderData(show: false),
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  sections: _buildSections(),
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < _sectionLabels.length; i++) ...[
                _Indicator(
                  color: _sectionColors[i],
                  text: _sectionLabels[i],
                ),
                const SizedBox(height: 4),
              ],
              const SizedBox(height: 18),
            ],
          ),
          const SizedBox(width: 28),
        ],
      ),
    );
  }

  List<fl.PieChartSectionData> _buildSections() {
    return List.generate(_sectionValues.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      return fl.PieChartSectionData(
        color: _sectionColors[i],
        value: _sectionValues[i],
        title: '${_sectionValues[i].toInt()}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: shadows,
        ),
      );
    });
  }
}

class _Indicator extends StatelessWidget {
  final Color color;
  final String text;

  const _Indicator({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}