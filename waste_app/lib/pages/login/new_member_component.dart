import 'package:waste_app/pages/dialogs/alert_dialog_component.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/models/user_dto.dart';
import 'package:waste_app/utils/constants.dart';
import 'package:waste_app/utils/styles.dart';
import 'package:flutter/material.dart';

class NewMemberComponent extends MaterialPageRoute<bool> {
  NewMemberComponent()
      : super(
          builder: (BuildContext context) {
            UserDto userDto = AuthService.currentUser;
            final _formKey = GlobalKey<FormState>();
            AuthService authService = new AuthService();
            TextEditingController name = new TextEditingController();
            TextEditingController userMail = new TextEditingController();
            TextEditingController password = new TextEditingController();
            TextEditingController rePassword = new TextEditingController();
            bool loading = false;

            void _goBack() {
              Navigator.pop(context, false);
            }

            Future<void> _openInfoDialog(String title, String content) async {
              await showDialog<String>(
                  context: context,
                  builder: (builder) {
                    return AlertDialogComponent(title, content);
                  });
            }

            Future<void> _register() async {
              String error = await authService.createNewUser(
                  name.text, userMail.text, password.text);

              if (error == null || error.isEmpty) {
                Navigator.pop(context, true);
              } else {
                await _openInfoDialog('Ops...', error);
              }
            }

            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Scaffold(
                  backgroundColor: Styles.mainBackgroundColor,
                  body: Stack(
                    children: <Widget>[
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(
                                left: 20,
                                right: 20,
                                bottom: 10,
                                top: 100,
                              ),
                              decoration: Styles.loginBox,
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(
                                        top: 20,
                                        bottom: 10,
                                        left: 20,
                                        right: 20,
                                      ),
                                      child: TextFormField(
                                        style: TextStyle(color: Colors.grey.shade100),
                                        textCapitalization:
                                            TextCapitalization.sentences,
                                        controller: name,
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return Constants
                                                .getDefaultEmptyFieldMsg(
                                                    userDto.language);
                                          }
                                          return null;
                                        },
                                        decoration: userDto.language ==
                                                Constants.languages[0]
                                            ? Styles.getTextFieldDecoration(
                                                'nome')
                                            : Styles.getTextFieldDecoration(
                                                'name'),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                        top: 10,
                                        bottom: 10,
                                        left: 20,
                                        right: 20,
                                      ),
                                      child: TextFormField(
                                        style: TextStyle(color: Colors.grey.shade100),
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        controller: userMail,
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return Constants
                                                .getDefaultEmptyFieldMsg(
                                                    userDto.language);
                                          }

                                          if (!value.contains('.com') ||
                                              !value.contains('@')) {
                                            return Constants
                                                .getDefaultInvalidEmailMsg(
                                                    userDto.language);
                                          }
                                          return null;
                                        },
                                        decoration:
                                            Styles.getTextFieldDecoration(
                                                'e-mail'),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                        top: 10,
                                        bottom: 10,
                                        left: 20,
                                        right: 20,
                                      ),
                                      child: TextFormField(
                                        style: TextStyle(
                                            color: Colors.grey.shade100),
                                        controller: password,
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return Constants
                                                .getDefaultEmptyFieldMsg(
                                                    userDto.language);
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: Styles
                                                .defaultTextFieldBorderRadius,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: Styles
                                                .defaultTextFieldBorderRadius,
                                            borderSide: BorderSide(
                                              color: Colors.grey.shade900,
                                            ),
                                          ),
                                          labelStyle: TextStyle(color: Colors.grey),
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
                                      child: TextFormField(
                                        style: TextStyle(
                                            color: Colors.grey.shade100),
                                        controller: rePassword,
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return Constants
                                                .getDefaultEmptyFieldMsg(
                                                    userDto.language);
                                          }

                                          if (value != password.text) {
                                            return Constants
                                                .getPasswordNotMatchMsg(
                                                    userDto.language);
                                          }

                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: Styles
                                                .defaultTextFieldBorderRadius,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: Styles
                                                .defaultTextFieldBorderRadius,
                                            borderSide: BorderSide(
                                              color: Colors.grey.shade900,
                                            ),
                                          ),
                                          labelStyle: TextStyle(color: Colors.grey),
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
                                          top: 10,
                                          bottom: 20,
                                          left: 20,
                                          right: 20),
                                      child: ButtonTheme(
                                        minWidth: double.infinity,
                                        height: 60.0,
                                        child: RaisedButton(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: Styles
                                                .defaultTextFieldBorderRadius,
                                          ),
                                          onPressed: () async {
                                            if (_formKey.currentState
                                                .validate()) {
                                              setState(() {
                                                loading = true;
                                              });
                                              await _register();
                                            }
                                            setState(() {
                                              loading = false;
                                            });
                                          },
                                          color: Colors.deepPurple,
                                          child: Text(
                                            userDto.language ==
                                                    Constants.languages[0]
                                                ? 'Cadastrar'
                                                : 'Register',
                                            style: TextStyle(
                                              color: Styles.mainBackgroundColor,
                                              fontSize: 18.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 50, right: 10),
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          child: Icon(
                            Icons.close,
                            color: Colors.grey.shade100,
                          ),
                          onTap: () {
                            _goBack();
                          },
                        ),
                      ),
                      loading
                          ? Container(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height,
                              color: Colors.black.withOpacity(0.5),
                              child: Container(
                                width: 100,
                                height: 100,
                                alignment: Alignment.center,
                                child: Theme(
                                  data: Theme.of(context)
                                      .copyWith(accentColor: Colors.deepPurple),
                                  child: new CircularProgressIndicator(),
                                ),
                              ),
                            )
                          : new Container(),
                    ],
                  ),
                );
              },
            );
          },
        );
}
