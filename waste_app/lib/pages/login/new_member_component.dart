import 'package:flutter/material.dart';
import 'package:waste_app/utils/styles.dart';

class NewMemberComponent extends MaterialPageRoute<bool> {
  NewMemberComponent()
      : super(
          builder: (BuildContext context) {
            return MaterialApp(
              theme: Styles.mainTheme,
              home: Scaffold(
                body: Stack(
                  children: <Widget>[
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: double.infinity,
                            height: 500.0,
                            margin: EdgeInsets.only(
                              left: 20,
                              right: 20,
                              bottom: 10,
                              top: 100,
                            ),
                            decoration: Styles.loginBox,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(
                                    top: 20,
                                    bottom: 10,
                                    left: 20,
                                    right: 20,
                                  ),
                                  child: TextField(
                                    // controller: _loginForm.userMail,
                                    decoration:
                                        Styles.getTextFieldDecoration('e-mail'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
}
