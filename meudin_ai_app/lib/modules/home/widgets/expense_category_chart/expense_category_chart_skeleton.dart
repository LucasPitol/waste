import 'package:flutter/material.dart';
import 'package:meudin_ai_app/modules/home/widgets/wallet_section/wallet_vision_skeleton.dart';
import 'package:meudin_ai_app/ui/styles.dart';

class ExpenseCategoryChartSkeleton extends StatelessWidget {
  const ExpenseCategoryChartSkeleton({super.key});

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
        children: [
          SkeletonLoader(width: 140, height: 16),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SkeletonLoader(
                width: 100,
                height: 100,
                borderRadius: BorderRadius.circular(50),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(4, (index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: index < 3 ? 8 : 0),
                      child: Row(
                        children: [
                          SkeletonLoader(
                            width: 8,
                            height: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SkeletonLoader(width: 80, height: 14),
                          ),
                          SkeletonLoader(width: 24, height: 12),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
