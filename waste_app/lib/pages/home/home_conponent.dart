import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waste_app/utils/styles.dart';

class HomeComponent extends StatefulWidget {
  // HomeComponent({Key key}) : super(key: key);
  @override
  HomeComponentState createState() => HomeComponentState();
}

class HomeComponentState extends State<HomeComponent> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Styles.mainBackgroundColor,
      statusBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
        backgroundColor: Styles.mainBackgroundColor,
        resizeToAvoidBottomPadding: true,
        body: SafeArea(
          child: Container(
            child: Text(
              'Homee',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ));
  }
}
