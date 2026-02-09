import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/routes/app_routes.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';

class JoyModal {
  static Widget errorBottomSheet({
    required BuildContext context,
    required List<String> errorList,
    String title = 'Ops... Algo deu errado',
    String imagePath = 'assets/form_error.png',
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Styles.whiteColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
      child: SizedBox(
        height: 380,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade600 : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Image.asset(
              imagePath,
              height: 140,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ...errorList.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(color: Colors.red, fontSize: 16)),
                      Expanded(
                        child: Text(
                          e,
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.textTheme.bodyMedium?.color ?? (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }

  static Widget bottomSheetError({
    required BuildContext context,
    required List<String> errorList,
    String title = 'Ops...',
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    List<Widget> errorTileList = [];
    for (var i = 0; i < errorList.length; i++) {
      var errorText = errorList[i];
      errorTileList.add(JoyText.secundaryText('• $errorText'));
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Styles.whiteColor,
        borderRadius: Styles.sexyBorderRadius,
      ),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: JoyGeometrics.horizontalBar(),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Image(
                image: AssetImage('assets/form_error.png'),
                height: 200,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 10,
                left: 20,
                right: 20,
              ),
              child: JoyText.h1(title),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: errorTileList,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  static bottomSheetWarning({
    required context,
    required String warningText,
    String title = 'Atenção',
    String imagePath = 'assets/warning.png',
  }) {
    bool isScroll = false;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Widget content = Container(
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Styles.whiteColor,
        borderRadius: Styles.sexyBorderRadius,
      ),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: JoyGeometrics.horizontalBar(),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Image(
                image: AssetImage(imagePath),
                height: 200,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 10,
                left: 20,
                right: 20,
              ),
              child: JoyText.h1(title),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [JoyText.secundaryText(warningText)],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );

    showJouBottomSheet(context: context, content: content, isScroll: isScroll);
  }

  /// Modal de limite atingido com CTA para upgrade
  static Widget limitReachedBottomSheet({
    required BuildContext context,
    required String message,
    String title = 'Limite do plano',
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Styles.whiteColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Icon(
            Icons.info_outline_rounded,
            size: 48,
            color: Styles.primaryColor,
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: 15,
              color: theme.textTheme.bodyMedium?.color ?? Colors.black87,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Get.back(); // Fecha o modal
                Get.toNamed(AppRoutes.plansRoute);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Styles.primaryColor,
                foregroundColor: Styles.whiteColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Fazer upgrade',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Fechar',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static showJouBottomSheet({
    required context,
    required content,
    required isScroll,
  }) async {
    final theme = Theme.of(context);
    final backgroundColor = theme.brightness == Brightness.dark
        ? theme.colorScheme.surface
        : Styles.whiteColor;
    await showModalBottomSheet(
        context: context,
        backgroundColor: backgroundColor,
        isScrollControlled: isScroll,
        builder: (builder) {
          return content;
        });
  }
}
