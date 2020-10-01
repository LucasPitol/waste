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
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                Container(
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Container(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Rombado',
                              style: TextStyle(
                                color: Colors.grey.shade100,
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Plano básico',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () {
                            print('settings');
                          },
                          child: Icon(
                            Icons.settings,
                            color: Colors.grey.shade100,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
