import 'package:flutter/material.dart';
import 'package:meudin_ai_app/modules/home/widgets/wallet_section/wallet_vision_skeleton.dart';
import 'package:meudin_ai_app/ui/styles.dart';

class DailyIncomeExpenseBarChartSkeleton extends StatelessWidget {
  const DailyIncomeExpenseBarChartSkeleton({super.key});

  static const int _barGroups = 8;
  static const double _chartHeight = 200;
  static const double _groupWidth = 28;

  static const List<double> _barHeights = [
    60, 110, 85, 140, 95, 120, 70, 130,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Styles.whiteColor,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.shade200.withOpacity(0.5),
            offset: const Offset(0, 1),
            blurRadius: 1,
          ),
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SkeletonLoader(width: 140, height: 16),
              const Spacer(),
              SkeletonLoader(width: 18, height: 18),
              const SizedBox(width: 8),
              SkeletonLoader(width: 18, height: 18),
            ],
          ),
          const SizedBox(height: 12),
          SkeletonLoader(width: 64, height: 12),
          const SizedBox(height: 16),
          SizedBox(
            height: _chartHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: 36,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      SkeletonLoader(width: 20, height: 10),
                      SkeletonLoader(width: 16, height: 10),
                      SkeletonLoader(width: 20, height: 10),
                      SkeletonLoader(width: 12, height: 10),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(_barGroups, (index) {
                        return SizedBox(
                          width: _groupWidth,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SkeletonLoader(
                                width: 12,
                                height: _barHeights[index],
                                borderRadius: BorderRadius.circular(3),
                              ),
                              const SizedBox(height: 8),
                              const SkeletonLoader(width: 12, height: 10),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
