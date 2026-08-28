import 'package:flutter/material.dart';

class BarChartFixedYAxis extends StatelessWidget {
  static const double axisWidth = 36;

  final double height;
  final double minY;
  final double maxY;
  final double interval;
  final Color axisLabelColor;
  final String Function(double value) formatValue;
  final double bottomInset;
  final double topInset;

  const BarChartFixedYAxis({
    super.key,
    required this.height,
    required this.minY,
    required this.maxY,
    required this.interval,
    required this.axisLabelColor,
    required this.formatValue,
    this.bottomInset = 28,
    this.topInset = 0,
  });

  List<double> _tickValues() {
    if (interval <= 0 || maxY <= minY) return [minY];

    final ticks = <double>[];
    for (var value = minY; value <= maxY + (interval * 0.001); value += interval) {
      ticks.add(value);
    }
    return ticks;
  }

  @override
  Widget build(BuildContext context) {
    final range = maxY - minY;
    final plotHeight = height - bottomInset - topInset;

    if (range <= 0 || plotHeight <= 0) {
      return SizedBox(width: axisWidth, height: height);
    }

    return SizedBox(
      width: axisWidth,
      height: height,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset, top: topInset),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (final value in _tickValues())
              _FixedYAxisTick(
                value: value,
                minY: minY,
                range: range,
                plotHeight: plotHeight,
                maxY: maxY,
                formatValue: formatValue,
                axisLabelColor: axisLabelColor,
              ),
          ],
        ),
      ),
    );
  }
}

class _FixedYAxisTick extends StatelessWidget {
  final double value;
  final double minY;
  final double range;
  final double plotHeight;
  final double maxY;
  final String Function(double value) formatValue;
  final Color axisLabelColor;

  const _FixedYAxisTick({
    required this.value,
    required this.minY,
    required this.range,
    required this.plotHeight,
    required this.maxY,
    required this.formatValue,
    required this.axisLabelColor,
  });

  @override
  Widget build(BuildContext context) {
    if (value < minY - 0.001 || value > maxY + 0.001) {
      return const SizedBox.shrink();
    }

    final fraction = (value - minY) / range;
    final isTopTick = (maxY - value).abs() < 0.001;
    const labelHeight = 10.0;

    return Positioned(
      left: 0,
      right: 0,
      bottom: (fraction * plotHeight) - (labelHeight / 2) + (isTopTick ? 5 : 0),
      child: Padding(
        padding: const EdgeInsets.only(right: 6),
        child: Text(
          formatValue(value),
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 10,
            color: axisLabelColor,
          ),
        ),
      ),
    );
  }
}
