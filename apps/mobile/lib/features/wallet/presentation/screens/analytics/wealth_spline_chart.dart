import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Production-grade executive spline chart powered by `fl_chart`.
/// Features native Bezier curve interpolation, automatic data tweening,
/// interactive friction-free scrubbing with haptics, and zero-snap tab transitions.
class WealthSplineChart extends StatefulWidget {
  final List<double> points;
  final Color lineColor;
  final Color glowColor;
  final bool isDark;
  final double height;
  final double? minY;
  final double? maxY;
  final ValueChanged<int>? onPointSelected;
  final void Function(double fraction, double value)? onScrubContinuous;
  final void Function(int index, double value)? onScrubUpdate;
  final VoidCallback? onScrubEnd;
  final String Function(double value, int index)? tooltipFormatter;

  const WealthSplineChart({
    super.key,
    required this.points,
    this.lineColor = Colors.white,
    this.glowColor = Colors.white,
    required this.isDark,
    this.height = 200.0,
    this.minY,
    this.maxY,
    this.onPointSelected,
    this.onScrubContinuous,
    this.onScrubUpdate,
    this.onScrubEnd,
    this.tooltipFormatter,
  });

  @override
  State<WealthSplineChart> createState() => _WealthSplineChartState();
}

class _WealthSplineChartState extends State<WealthSplineChart> {
  int _lastHapticIndex = -1;

  @override
  Widget build(BuildContext context) {
    final rawPoints = widget.points;
    final effectivePoints = rawPoints.length < 2
        ? (rawPoints.isEmpty ? [0.0, 0.0] : [rawPoints.first, rawPoints.first])
        : rawPoints;

    final spots = <FlSpot>[];
    for (var i = 0; i < effectivePoints.length; i++) {
      spots.add(FlSpot(i.toDouble(), effectivePoints[i]));
    }

    final double effectiveMinY = widget.minY ?? 0.0;
    double effectiveMaxY = widget.maxY ??
        (effectivePoints.isEmpty ? 100.0 : effectivePoints.reduce(math.max));
    if (effectiveMaxY <= effectiveMinY) {
      effectiveMaxY = effectiveMinY + 100.0;
    }

    // Give 8% breathing headroom above so peaks never touch the top boundary
    final range = effectiveMaxY - effectiveMinY;
    final chartMinY = effectiveMinY;
    final chartMaxY = effectiveMaxY + range * 0.08;

    final barData = LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.35,
      preventCurveOverShooting: true,
      barWidth: 3.2,
      isStrokeCapRound: true,
      color: widget.lineColor,
      shadow: const Shadow(color: Colors.transparent),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            widget.lineColor.withValues(alpha: widget.isDark ? 0.22 : 0.12),
            widget.lineColor.withValues(alpha: widget.isDark ? 0.05 : 0.02),
            widget.lineColor.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.60, 1.0],
        ),
      ),
      dotData: FlDotData(
        show: true,
        checkToShowDot: (spot, barData) => spot.x == barData.spots.last.x,
        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
          radius: 5.5,
          color: widget.lineColor,
          strokeWidth: 3.0,
          strokeColor: widget.isDark ? const Color(0xFF09090C) : Colors.white,
        ),
      ),
    );

    final touchData = LineTouchData(
      enabled: true,
      handleBuiltInTouches: true,
      touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
        if (event is FlPanEndEvent ||
            event is FlTapUpEvent ||
            event is FlPanCancelEvent ||
            !event.isInterestedForInteractions) {
          _lastHapticIndex = -1;
          widget.onScrubEnd?.call();
          return;
        }

        if (touchResponse != null &&
            touchResponse.lineBarSpots != null &&
            touchResponse.lineBarSpots!.isNotEmpty) {
          final spot = touchResponse.lineBarSpots!.first;
          final index = spot.spotIndex;
          final value = spot.y;

          if (_lastHapticIndex != index) {
            HapticFeedback.selectionClick();
            _lastHapticIndex = index;
          }

          widget.onPointSelected?.call(index);
          widget.onScrubUpdate?.call(index, value);
          final total = effectivePoints.length;
          if (total > 1) {
            final fraction = (spot.x / (total - 1)).clamp(0.0, 1.0);
            widget.onScrubContinuous?.call(fraction, value);
          }
        }
      },
      getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
        return spotIndexes.map((index) {
          return TouchedSpotIndicatorData(
            FlLine(
              color: widget.lineColor.withValues(alpha: widget.isDark ? 0.35 : 0.25),
              strokeWidth: 1.5,
              dashArray: [4, 4],
            ),
            FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                radius: 6.5,
                color: widget.lineColor,
                strokeWidth: 3.2,
                strokeColor: widget.isDark ? const Color(0xFF09090C) : Colors.white,
              ),
            ),
          );
        }).toList();
      },
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (_) => Colors.transparent,
        getTooltipItems: (touchedSpots) =>
            touchedSpots.map((_) => null).toList(),
      ),
    );

    final totalSpots = effectivePoints.length;
    final maxX = (totalSpots - 1).toDouble();

    return SizedBox(
      height: widget.height,
      child: LineChart(
        LineChartData(
          minY: chartMinY,
          maxY: chartMaxY,
          minX: 0.0,
          maxX: maxX,
          clipData: const FlClipData.none(),
          lineTouchData: touchData,
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [barData],
        ),
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOutCubic,
      ),
    );
  }
}
