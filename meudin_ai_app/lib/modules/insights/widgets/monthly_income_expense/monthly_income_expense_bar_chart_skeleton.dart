import 'package:flutter/material.dart';
import 'package:meudin_ai_app/modules/home/widgets/wallet_section/wallet_vision_skeleton.dart';
import 'package:meudin_ai_app/ui/styles.dart';

class MonthlyIncomeExpenseBarChartSkeleton extends StatelessWidget {
  const MonthlyIncomeExpenseBarChartSkeleton({super.key});

  static const int _barGroups = 4;
  static const double _chartHeight = 200;

  static const List<(double revenue, double expense)> _barHeights = [
    (110, 150),
    (130, 95),
    (155, 120),
    (90, 140),
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
          SkeletonLoader(width: 180, height: 16),
          const SizedBox(height: 12),
          Row(
            children: [
              SkeletonLoader(width: 64, height: 12),
              const SizedBox(width: 16),
              SkeletonLoader(width: 64, height: 12),
            ],
          ),
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
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(_barGroups, (index) {
                      final heights = _barHeights[index];
                      return Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                SkeletonLoader(
                                  width: 10,
                                  height: heights.$1,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                const SizedBox(width: 4),
                                SkeletonLoader(
                                  width: 10,
                                  height: heights.$2,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const SkeletonLoader(width: 22, height: 10),
                          ],
                        ),
                      );
                    }),
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
