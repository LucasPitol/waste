import 'package:flutter/material.dart';
import 'package:meudin_ai_app/ui/app_icons.dart';
import 'package:meudin_ai_app/models/spending_category.dart';
import 'package:meudin_ai_app/ui/styles.dart';

class CategoryPickerBottomSheet extends StatefulWidget {
  final List<SpendingCategory> categories;
  final String? selectedCategoryId;

  const CategoryPickerBottomSheet({
    super.key,
    required this.categories,
    this.selectedCategoryId,
  });

  @override
  State<CategoryPickerBottomSheet> createState() => _CategoryPickerBottomSheetState();
}

class _CategoryPickerBottomSheetState extends State<CategoryPickerBottomSheet> {
  String _selectedTab = 'personal'; // Abre selecionando pessoal por padrão

  List<SpendingCategory> get _filteredCategories {
    return widget.categories
        .where((category) => category.type == _selectedTab)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark 
            ? theme.colorScheme.surface 
            : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar - mais sutil
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
            
            // Header - simples e limpo
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Categoria do gasto',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyLarge?.color ?? 
                          (theme.brightness == Brightness.dark 
                              ? Colors.white 
                              : Styles.primaryTextColor),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Tabs: Pessoal | Empresarial
                  Row(
                    children: [
                      Expanded(
                        child: _TabButton(
                          label: 'Pessoal',
                          isSelected: _selectedTab == 'personal',
                          onTap: () => setState(() => _selectedTab = 'personal'),
                          theme: theme,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TabButton(
                          label: 'Empresarial',
                          isSelected: _selectedTab == 'business',
                          onTap: () => setState(() => _selectedTab = 'business'),
                          theme: theme,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Categories Grid - mais limpo
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: _filteredCategories.length,
                  itemBuilder: (context, index) {
                    final category = _filteredCategories[index];
                    final isSelected = category.id == widget.selectedCategoryId;
                    
                    return _CategoryCard(
                      category: category,
                      isSelected: isSelected,
                      onTap: () => Navigator.pop(context, category),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? (theme.brightness == Brightness.dark
                  ? Styles.primaryColor.withOpacity(0.2)
                  : Styles.primaryColor.withOpacity(0.1))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Styles.primaryColor
                : (theme.brightness == Brightness.dark
                    ? Colors.grey.shade700
                    : Colors.grey.shade300),
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? Styles.primaryColor
                  : (theme.textTheme.bodyMedium?.color?.withOpacity(0.7) ??
                      (theme.brightness == Brightness.dark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600)),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final SpendingCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getBorderColor(),
            width: widget.isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container - menor e mais sutil
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: widget.category.colorData.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: AppIcon(
                  widget.category.iconData,
                  size: 24,
                  color: widget.category.colorData,
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Category name - sempre legível
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                widget.category.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: _getTextColor(),
                  height: 1.2,
                  letterSpacing: -0.2,
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
      return widget.category.colorData.withOpacity(0.08);
    }
    return Colors.transparent;
  }

  Color _getBorderColor() {
    final theme = Theme.of(context);
    if (widget.isSelected) {
      return widget.category.colorData.withOpacity(0.4);
    }
    return theme.brightness == Brightness.dark
        ? Colors.grey.shade700
        : Colors.grey.shade200;
  }

  Color _getTextColor() {
    final theme = Theme.of(context);
    if (widget.isSelected) {
      return widget.category.colorData;
    }
    return theme.textTheme.bodyLarge?.color ?? 
        (theme.brightness == Brightness.dark 
            ? Colors.white 
            : Styles.primaryTextColor);
  }
}

