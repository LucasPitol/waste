import 'package:meudin_ai_app/ui/joy_ui.dart';
import 'package:flutter/material.dart';

class JoyModal {
  static Widget errorBottomSheet({
    required BuildContext context,
    required List<String> errorList,
    String title = 'Ops... Algo deu errado',
    String imagePath = 'assets/form_error.png',
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
      child: SizedBox(
        height: 380,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Grey bar at the very top
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
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
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
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
                          style: const TextStyle(fontSize: 16, color: Colors.black87),
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
    List<Widget> errorTileList = [];
    for (var i = 0; i < errorList.length; i++) {
      var errorText = errorList[i];
      errorTileList.add(JoyText.secundaryText('• $errorText'));
    }

    return Container(
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
