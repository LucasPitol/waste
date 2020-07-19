import 'package:flutter/material.dart';
import 'package:waste_app/models/user_dto.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/utils/constants.dart';
import 'package:waste_app/utils/styles.dart';

class ResetPasswordComponent extends StatefulWidget {
  String userMail;
  ResetPasswordComponent(this.userMail);
  @override
  _ResetPasswordComponentState createState() =>
      _ResetPasswordComponentState(userMail);
}

class _ResetPasswordComponentState extends State<ResetPasswordComponent> {
  bool loading = false;
  UserDto userDto = AuthService.currentUser;
  final _formKey = GlobalKey<FormState>();
  TextEditingController userMailController;

  _ResetPasswordComponentState(String userMail) {
    this.userMailController = TextEditingController();
    this.userMailController.text = userMail;
  }

  _goBack()
  {
    Navigator.pop(context, false);
  }

  _register() {
    print('reset');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              Form(
                key: this._formKey,
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(
                        top: 200,
                        bottom: 20,
                        left: 20,
                        right: 20,
                      ),
                      child: TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        controller: userMailController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return Constants.getDefaultEmptyFieldMsg(
                                userDto.language);
                          }

                          if (!value.contains('.com') || !value.contains('@')) {
                            return Constants.getDefaultInvalidEmailMsg(
                                userDto.language);
                          }
                          return null;
                        },
                        decoration: Styles.getTextFieldDecoration('e-mail'),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          top: 10, bottom: 20, left: 20, right: 20),
                      child: ButtonTheme(
                        minWidth: double.infinity,
                        height: 60.0,
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: Styles.defaultTextFieldBorderRadius,
                          ),
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
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
                            userDto.language == Constants.languages[0]
                                ? 'Redefinir'
                                : 'Reset',
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
                margin: EdgeInsets.only(top: 15, right: 10),
                alignment: Alignment.topRight,
                child: GestureDetector(
                  child: Icon(
                    Icons.close,
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
      ),
    );
  }
}
