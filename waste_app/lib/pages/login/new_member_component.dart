import 'package:flutter/material.dart';
import 'package:waste_app/models/user_dto.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/utils/constants.dart';
import 'package:waste_app/utils/styles.dart';

class NewMemberComponent extends MaterialPageRoute<bool> {
  NewMemberComponent()
      : super(
          builder: (BuildContext context) {
            UserDto userDto = AuthService.currentUser;

            void _goBack() {
              Navigator.pop(context);
            }

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
                            height: 430.0,
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
                                    decoration: userDto.language ==
                                            Constants.languages[0]
                                        ? Styles.getTextFieldDecoration('nome')
                                        : Styles.getTextFieldDecoration('name'),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                    top: 10,
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
                                Container(
                                  margin: EdgeInsets.only(
                                    top: 10,
                                    bottom: 10,
                                    left: 20,
                                    right: 20,
                                  ),
                                  child: TextField(
                                    // controller: _loginForm.password,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            Styles.defaultTextFieldBorderRadius,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            Styles.defaultTextFieldBorderRadius,
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      labelText: userDto.language ==
                                              Constants.languages[0]
                                          ? 'senha'
                                          : 'pasword',
                                    ),
                                    obscureText: true,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                    top: 10,
                                    bottom: 10,
                                    left: 20,
                                    right: 20,
                                  ),
                                  child: TextField(
                                    // controller: _loginForm.password,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            Styles.defaultTextFieldBorderRadius,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            Styles.defaultTextFieldBorderRadius,
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      labelText: userDto.language ==
                                              Constants.languages[0]
                                          ? 'confirme a senha'
                                          : 'confirm pasword',
                                    ),
                                    obscureText: true,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      top: 10, bottom: 10, left: 20, right: 20),
                                  child: ButtonTheme(
                                    minWidth: double.infinity,
                                    height: 60.0,
                                    child: RaisedButton(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            Styles.defaultTextFieldBorderRadius,
                                      ),
                                      onPressed: () {},
                                      color: Colors.deepPurple,
                                      child: Text(
                                        userDto.language ==
                                                Constants.languages[0]
                                            ? 'Cadastrar'
                                            : 'Register',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                top: 20, bottom: 10, left: 20, right: 20),
                            child: ButtonTheme(
                              height: 40.0,
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      Styles.defaultTextFieldBorderRadius,
                                ),
                                onPressed: () {},
                                color: Styles.mainBackgroundColor,
                                child: Text(
                                  userDto.language == Constants.languages[0]
                                      ? 'Continuar com Google'
                                      : 'Login with Google',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 45, right: 10),
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        child: Icon(
                          Icons.cancel,
                          color: Colors.grey,
                        ),
                        onTap: () {
                          _goBack();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
}
