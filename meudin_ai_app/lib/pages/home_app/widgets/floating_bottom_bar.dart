import 'package:flutter/material.dart';
import 'package:meudin_ai_app/pages/home_app/widgets/floating_notched_pill_clipper.dart';
import 'package:meudin_ai_app/ui/app_icons.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';

/// Layout constants shared with [MainAppPage] for FAB docking alignment.
abstract final class FloatingBottomBarLayout {
  static const double height = 56;
  static const double horizontalMargin = 24;
  static const double bottomMargin = 0;
  static const double cornerRadius = 28;
  static const double fabSize = 56;
  static const double notchMargin = 4;

  static FloatingNotchedPillClipper clipper() => const FloatingNotchedPillClipper(
        cornerRadius: cornerRadius,
        fabSize: fabSize,
        notchMargin: notchMargin,
      );

  /// Bar fill — matches FAB [SpeedDial] background in dark mode.
  static Color barBackgroundColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? theme.colorScheme.surface
        : Styles.whiteColor;
  }

  /// Extra space at the bottom of scrollable pages so content clears the bar.
  static double scrollBottomInset(BuildContext context) {
    return bottomMargin +
        height +
        fabSize / 2 +
        MediaQuery.paddingOf(context).bottom +
        8;
  }

  /// [Positioned.bottom] for the pill bar.
  static double barBottomOffset(BuildContext context) {
    return bottomMargin + MediaQuery.paddingOf(context).bottom;
  }

  /// [Positioned.bottom] for the docked FAB / SpeedDial.
  static double fabBottomOffset(BuildContext context) {
    return barBottomOffset(context) + height - fabSize / 2;
  }
}

class FloatingBottomBar extends StatelessWidget {
  const FloatingBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = FloatingBottomBarLayout.barBackgroundColor(context);
    final clipper = FloatingBottomBarLayout.clipper();

    return CustomPaint(
      painter: FloatingBottomBarPainter(
        clipper: clipper,
        color: backgroundColor,
        borderColor: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.07),
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.65 : 0.28),
        elevation: isDark ? 18 : 12,
      ),
      child: SizedBox(
        height: FloatingBottomBarLayout.height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () => onItemTapped(0),
              iconSize: AppIcon.renderSize(24),
              icon: AppIcon(
                selectedIndex == 0 ? AppIcons.houseFilled : AppIcons.house,
                size: 24,
                color:
                    selectedIndex == 0 ? Styles.primaryColor : Styles.grey,
              ),
            ),
            const SizedBox(width: 20),
            IconButton(
              onPressed: () => onItemTapped(1),
              iconSize: AppIcon.renderSize(24),
              icon: AppIcon(
                selectedIndex == 1
                    ? AppIcons.chartDonutFilled
                    : AppIcons.chartDonut,
                size: 24,
                color:
                    selectedIndex == 1 ? Styles.primaryColor : Styles.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
