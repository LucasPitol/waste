import 'package:meudin_ai_app/ui/joy_ui.dart';
import 'package:flutter/material.dart';

class JoyModal {
  static bottomSheetError({
    required context,
    required List<String> errorList,
    String title = 'Ops...',
  }) {
    bool isScroll = false;

    List<Widget> errorTileList = [];
    for (var i = 0; i < errorList.length; i++) {
      var errorText = errorList[i];
      errorTileList.add(JoyText.secundaryText('• $errorText'));
    }

    if (errorList.length > 2) {
      isScroll = true;
    }

    final Widget content = Container(
      decoration: BoxDecoration(
        color: Styles.whiteColor,
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

    showJouBottomSheet(context: context, content: content, isScroll: isScroll);
  }

  static bottomSheetWarning({
    required context,
    required String warningText,
    String title = 'Atenção',
    String imagePath = 'assets/warning.png',
  }) {
    bool isScroll = false;

    final Widget content = Container(
      decoration: BoxDecoration(
        color: Styles.whiteColor,
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

  static showJouBottomSheet({
    required context,
    required content,
    required isScroll,
  }) async {
    await showModalBottomSheet(
        context: context,
        backgroundColor: Styles.whiteColor,
        isScrollControlled: isScroll,
        builder: (builder) {
          return content;
        });
  }
}
