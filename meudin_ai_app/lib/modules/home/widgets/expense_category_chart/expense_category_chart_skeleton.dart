import 'package:flutter/material.dart';
import 'package:meudin_ai_app/modules/home/widgets/wallet_section/wallet_vision_skeleton.dart';

class ExpenseCategoryChartSkeleton extends StatelessWidget {
  const ExpenseCategoryChartSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.03),
            offset: const Offset(0, 2),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonLoader(width: 140, height: 20),
              SkeletonLoader(width: 100, height: 16),
            ],
          ),
          const SizedBox(height: 24),
          // Chart and Legend skeleton
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Donut Chart skeleton (circular)
              SizedBox(
                width: 140,
                height: 140,
                child: SkeletonLoader(
                  width: 140,
                  height: 140,
                  borderRadius: BorderRadius.circular(70),
                ),
              ),
              const SizedBox(width: 20),
              // Legend skeleton
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(4, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          SkeletonLoader(
                            width: 12,
                            height: 12,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SkeletonLoader(width: 80, height: 16),
                          ),
                          SkeletonLoader(width: 30, height: 16),
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
