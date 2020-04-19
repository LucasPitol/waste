import 'package:flutter/material.dart';
import 'package:waste_app/models/login_form.dart';
import 'package:waste_app/models/user_dto.dart';
import 'package:waste_app/pages/doalogs/alert_dialog_component.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/utils/constants.dart';
import 'package:waste_app/utils/styles.dart';

import 'new_member_component.dart';

class LoginComponent extends StatefulWidget {
  Function selectHandler;

  LoginComponent(this.selectHandler);

  @override
  _LoginComponentState createState() =>
      _LoginComponentState(this.selectHandler);
}

class _LoginComponentState extends State<LoginComponent> {
  double defaultMargin = 10.0;
  BorderRadius defaultBorderRadius = BorderRadius.all(Radius.circular(50.0));
  Color mainColor = Colors.grey.shade50;

  String dropdownValue = 'Português';

  bool loading = false;

  AuthService authService;

  UserDto userDto;

  LoginForm _loginForm;

  Function selectHandler;

  _LoginComponentState(selectHandlerTemp) {
    this.authService = AuthService();
    this._loginForm = LoginForm();
    this.userDto = AuthService.currentUser;
    this.userDto.language = dropdownValue;
    this.selectHandler = selectHandlerTemp;
  }

  void changeLAnguage(String language) {
    AuthService.changeLanguage(language);

    setState(() {
      this.userDto = AuthService.currentUser;
      this.dropdownValue = this.userDto.language;
    });
  }

  Future<void> _login() async {
    setState(() {
      this.loading = true;
    });

    if (_loginForm.userMail.text == '' || _loginForm.password.text == '') {
      String title =
          this.userDto.language == Constants.languages[0] ? 'Alerta' : 'Alert';
      String content = this.userDto.language == Constants.languages[0]
          ? 'Campo não preenchido'
          : 'Must complete all the fields';

      await _openInfoDialog(title, content);
    } else {
      UserDto userTemp = await this.authService.login(_loginForm);

      if (userTemp == null) {
        String title = this.userDto.language == Constants.languages[0]
            ? 'Alerta'
            : 'Alert';
        String content = this.userDto.language == Constants.languages[0]
            ? 'Usuário não encontrado'
            : 'User not found';
        await _openInfoDialog(title, content);
      } else {
        setState(() {
          this.userDto = AuthService.currentUser;
          this.selectHandler();
        });
      }
    }

    setState(() {
      this.loading = false;
    });
  }

  Future<void> _openInfoDialog(String title, String content) async {
    await showDialog<String>(
        context: context,
        builder: (builder) {
          return AlertDialogComponent(title, content);
        });
  }

  void _goToNewMemberPage() async {
    var refresh = await Navigator.push(context, NewMemberComponent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    height: 300.0,
                    margin: EdgeInsets.only(
                        left: 20, right: 20, bottom: 10, top: 100),
                    decoration: Styles.loginBox,
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(
                              top: 20,
                              bottom: defaultMargin,
                              left: 20,
                              right: 20),
                          child: TextField(
                            controller: _loginForm.userMail,
                            decoration: Styles.getTextFieldDecoration('e-mail'),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              top: 10,
                              bottom: defaultMargin,
                              left: 20,
                              right: 20),
                          child: TextField(
                            controller: _loginForm.password,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: defaultBorderRadius,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: defaultBorderRadius,
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              labelText: this.userDto.language ==
                                      Constants.languages[0]
                                  ? 'senha'
                                  : 'pasword',
                            ),
                            obscureText: true,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              top: defaultMargin,
                              bottom: defaultMargin,
                              left: 20,
                              right: 20),
                          child: ButtonTheme(
                            minWidth: double.infinity,
                            height: 60.0,
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: defaultBorderRadius,
                              ),
                              onPressed: _login,
                              color: Colors.deepPurple,
                              child: Text(
                                this.userDto.language == Constants.languages[0]
                                    ? 'Entrar'
                                    : 'Login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                child: Text(
                                  this.userDto.language ==
                                          Constants.languages[0]
                                      ? 'Esqueceu a senha?'
                                      : "Can't remember password?",
                                  style: TextStyle(
                                      fontSize: 14.0, color: Colors.grey),
                                ),
                              ),
                              Container(
                                child: FlatButton(
                                  onPressed: () {},
                                  child: Text(
                                    this.userDto.language ==
                                            Constants.languages[0]
                                        ? 'Recuperar'
                                        : 'Recover',
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.deepPurple),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          child: Text(
                            this.userDto.language == Constants.languages[0]
                                ? 'Novo por aqui?'
                                : 'New member?',
                            style:
                                TextStyle(fontSize: 14.0, color: Colors.grey),
                          ),
                        ),
                        Container(
                          child: FlatButton(
                            onPressed: _goToNewMemberPage,
                            child: Text(
                              this.userDto.language == Constants.languages[0]
                                  ? 'Cadastrar'
                                  : 'Register',
                              style: TextStyle(
                                  fontSize: 14.0, color: Colors.deepPurple),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        top: 20, bottom: defaultMargin, left: 20, right: 20),
                    child: ButtonTheme(
                      height: 40.0,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: defaultBorderRadius,
                        ),
                        onPressed: () {},
                        color: mainColor,
                        child: Text(
                          this.userDto.language == Constants.languages[0]
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
          ),
          Container(
            alignment: Alignment.topRight,
            margin: EdgeInsets.only(top: 40, right: defaultMargin),
            child: DropdownButton<String>(
              value: dropdownValue,
              icon: Icon(Icons.keyboard_arrow_down),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(
                color: Colors.grey,
              ),
              underline: Container(
                height: 1,
                color: Colors.white10,
              ),
              onChanged: (String newValue) {
                changeLAnguage(newValue);
              },
              items: Constants.languages
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          this.loading
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
  }
}
