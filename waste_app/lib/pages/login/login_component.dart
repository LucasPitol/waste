import 'package:flutter/material.dart';

class LoginComponent extends StatefulWidget {
  @override
  _LoginComponentState createState() => _LoginComponentState();
}

class _LoginComponentState extends State<LoginComponent> {

  double defaultMargin = 10.0;
  BorderRadius defaultBorderRadius = BorderRadius.all(Radius.circular(50.0));
  Color mainColor = Colors.grey.shade50;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        cursorColor: Colors.deepPurple,
        primaryColor: Colors.deepPurple,
        textSelectionHandleColor: Colors.deepPurple,
      ),
      home: Scaffold(
        body: Stack(
          children: <Widget>[
            Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: 230.0,
                  margin: EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 100),
                  decoration: BoxDecoration(
                    color: mainColor,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade400,
                        offset: Offset(0, 0),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(
                            top: defaultMargin,
                            bottom: defaultMargin,
                            left: 20,
                            right: 20),
                        child: TextField(
                          // controller: _loginForm.userMail,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: defaultBorderRadius,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: defaultBorderRadius,
                              borderSide: BorderSide(color: Colors.grey[100]),
                            ),
                            labelText: 'e-mail',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
