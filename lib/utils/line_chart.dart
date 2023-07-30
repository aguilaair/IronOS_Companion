import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../data/iron_data.dart';

LineChartData genLineChartData(List<FlSpot> spots, List<FlSpot> powerSpots,
    List<FlSpot> setpointSpots, IronData? data, int maxTemp) {
  return LineChartData(
    minY: 0,
    maxY:
        max((data?.setpoint.toDouble() ?? 400) * 1.1, maxTemp.toDouble() * 1.1),
    lineTouchData: const LineTouchData(enabled: true),
    gridData: const FlGridData(
      show: false,
    ),
    titlesData: const FlTitlesData(
      show: false,
    ),
    borderData: FlBorderData(
      show: false,
    ),
    lineBarsData: [
      LineChartBarData(
        spots: spots,
        isCurved: true,
        barWidth: 3,
        show: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              Colors.red.withOpacity(0.1),
              Colors.blue.withOpacity(0.1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        gradient: const LinearGradient(
          colors: [
            Colors.red,
            Colors.blue,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      // Power
      LineChartBarData(
        spots: powerSpots,
        isCurved: true,
        barWidth: 3,
        show: true,
        dotData: const FlDotData(show: false),
        gradient: const LinearGradient(
          colors: [
            Colors.green,
            Colors.greenAccent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      // Setpoint
      LineChartBarData(
        spots: setpointSpots,
        isCurved: false,
        barWidth: 2,
        show: true,
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              Colors.orange.withOpacity(0.1),
              Colors.orangeAccent.withOpacity(0.1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        dotData: const FlDotData(show: false),
        gradient: const LinearGradient(
          colors: [
            Colors.orange,
            Colors.orangeAccent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    ],
  );
}
