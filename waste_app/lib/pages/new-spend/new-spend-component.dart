import 'package:flutter/material.dart';
import 'package:waste_app/models/user_dto.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/utils/constants.dart';
import 'package:waste_app/utils/styles.dart';

class NewSpendComponent extends StatefulWidget {
  @override
  _NewSpendComponenState createState() => _NewSpendComponenState();
}

class _NewSpendComponenState extends State<NewSpendComponent> {
  UserDto userDto = AuthService.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 100,
              color: Colors.deepPurple,
              child: Stack(
                children: <Widget>[
                  Container(
                    alignment: Alignment.topRight,
                    margin: EdgeInsets.only(right: 20, top: 10),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context, false);
                      },
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.only(left: 20, top: 10),
              child: Text(
                this.userDto.language == Constants.languages[0]
                    ? 'Novo gasto'
                    : 'New waste',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: 50),
              decoration: Styles.containerDecoration,
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(
                        top: 20, bottom: 10, left: 20, right: 20),
                    child: TextFormField(
                      // controller: _loginForm.userMail,
                      validator: (value) {
                        if (value.isEmpty) {
                          return Constants.getDefaultEmptyFieldMsg(
                              userDto.language);
                        }
                        return null;
                      },
                      decoration: this.userDto.language ==
                              Constants.languages[0]
                          ? Styles.getTextFieldDecorationUnderline('Motivo')
                          : Styles.getTextFieldDecorationUnderline('Reason'),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        top: 10, bottom: 10, left: 20, right: 20),
                    child: TextFormField(
                      // controller: _loginForm.userMail,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value.isEmpty) {
                          return Constants.getDefaultEmptyFieldMsg(
                              userDto.language);
                        }
                        return null;
                      },
                      decoration:
                          this.userDto.language == Constants.languages[0]
                              ? Styles.getTextFieldDecorationUnderline(
                                  'Desperdício')
                              : Styles.getTextFieldDecorationUnderline('Waste'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
