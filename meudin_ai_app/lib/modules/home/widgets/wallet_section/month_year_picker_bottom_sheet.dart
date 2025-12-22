import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meudin_ai_app/ui/styles.dart';
import 'package:meudin_ai_app/utils/constants.dart';

class MonthYearPickerBottomSheet extends StatefulWidget {
  final DateTime initialDate;

  const MonthYearPickerBottomSheet({
    super.key,
    required this.initialDate,
  });

  @override
  State<MonthYearPickerBottomSheet> createState() =>
      _MonthYearPickerBottomSheetState();
}

class _MonthYearPickerBottomSheetState
    extends State<MonthYearPickerBottomSheet> {
  late int selectedYear;
  late int selectedMonth;

  @override
  void initState() {
    super.initState();
    selectedYear = widget.initialDate.year;
    selectedMonth = widget.initialDate.month;
  }

  final List<String> months = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  List<int> get availableYears {
    final currentYear = DateTime.now().year;
    return List.generate(10, (index) => currentYear - 5 + index);
  }

  void _confirmSelection() {
    final selectedDate = DateTime(selectedYear, selectedMonth, 1);
    Navigator.pop(context, selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark 
            ? theme.colorScheme.surface 
            : Styles.whiteColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? Colors.grey.shade700
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selecione o mês e ano',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Filtre suas transações',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6) 
                          ?? Colors.grey.shade600,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // Month and Year Pickers
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  children: [
                    // Month Picker
                    _buildSectionTitle('Mês'),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 2.5,
                      ),
                      itemCount: months.length,
                      itemBuilder: (context, index) {
                        final month = index + 1;
                        final isSelected = month == selectedMonth;
                        final now = DateTime.now();
                        final isCurrent = month == now.month && selectedYear == now.year;
                        return _MonthCard(
                          label: months[index],
                          isSelected: isSelected,
                          isCurrent: isCurrent,
                          onTap: () {
                            setState(() {
                              selectedMonth = month;
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // Year Picker
                    _buildSectionTitle('Ano'),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 2.5,
                      ),
                      itemCount: availableYears.length,
                      itemBuilder: (context, index) {
                        final year = availableYears[index];
                        final isSelected = year == selectedYear;
                        final now = DateTime.now();
                        final isCurrent = year == now.year;
                        return _YearCard(
                          label: year.toString(),
                          isSelected: isSelected,
                          isCurrent: isCurrent,
                          onTap: () {
                            setState(() {
                              selectedYear = year;
                            });
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Confirm Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _confirmSelection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Styles.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Confirmar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: theme.textTheme.bodyLarge?.color?.withOpacity(0.8) 
              ?? Colors.grey.shade800,
        ),
      ),
    );
  }
}

class _MonthCard extends StatefulWidget {
  final String label;
  final bool isSelected;
  final bool isCurrent;
  final VoidCallback onTap;

  const _MonthCard({
    required this.label,
    required this.isSelected,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  State<_MonthCard> createState() => _MonthCardState();
}

class _MonthCardState extends State<_MonthCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _getBorderColor(),
            width: widget.isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: _getTextColor(),
                ),
              ),
            ),
            if (widget.isCurrent)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Styles.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    final theme = Theme.of(context);
    if (_isPressed) {
      return theme.brightness == Brightness.dark
          ? Colors.grey.shade800
          : Colors.grey.shade100;
    }
    if (widget.isSelected) {
      return Styles.primaryColor.withOpacity(0.1);
    }
    return Colors.transparent;
  }

  Color _getBorderColor() {
    final theme = Theme.of(context);
    if (widget.isSelected) {
      return Styles.primaryColor.withOpacity(0.4);
    }
    return theme.brightness == Brightness.dark
        ? Colors.grey.shade700
        : Colors.grey.shade200;
  }

  Color _getTextColor() {
    final theme = Theme.of(context);
    if (widget.isSelected) {
      return Styles.primaryColor;
    }
    return theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor;
  }
}

class _YearCard extends StatefulWidget {
  final String label;
  final bool isSelected;
  final bool isCurrent;
  final VoidCallback onTap;

  const _YearCard({
    required this.label,
    required this.isSelected,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  State<_YearCard> createState() => _YearCardState();
}

class _YearCardState extends State<_YearCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _getBorderColor(),
            width: widget.isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: _getTextColor(),
                ),
              ),
            ),
            if (widget.isCurrent)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Styles.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    final theme = Theme.of(context);
    if (_isPressed) {
      return theme.brightness == Brightness.dark
          ? Colors.grey.shade800
          : Colors.grey.shade100;
    }
    if (widget.isSelected) {
      return Styles.primaryColor.withOpacity(0.1);
    }
    return Colors.transparent;
  }

  Color _getBorderColor() {
    final theme = Theme.of(context);
    if (widget.isSelected) {
      return Styles.primaryColor.withOpacity(0.4);
    }
    return theme.brightness == Brightness.dark
        ? Colors.grey.shade700
        : Colors.grey.shade200;
  }

  Color _getTextColor() {
    final theme = Theme.of(context);
    if (widget.isSelected) {
      return Styles.primaryColor;
    }
    return theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor;
  }
}
