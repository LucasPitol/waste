import 'package:flutter/services.dart';
import 'package:waste_app/pages/dialogs/alert_dialog_component.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/models/forms/login_form.dart';
import 'package:waste_app/models/user_dto.dart';
import 'package:waste_app/utils/constants.dart';
import 'package:waste_app/utils/styles.dart';
import 'package:flutter/material.dart';
import 'new_member_component.dart';
import 'reset_password_component.dart';

class LoginComponent extends StatefulWidget {
  final Function selectHandler;

  LoginComponent(this.selectHandler);

  @override
  _LoginComponentState createState() =>
      _LoginComponentState(this.selectHandler);
}

class _LoginComponentState extends State<LoginComponent> {
  double defaultMargin = 10.0;
  BorderRadius defaultBorderRadius = BorderRadius.all(Radius.circular(50.0));
  Color mainColor = Colors.grey.shade50;
  bool isPtLanguage;

  bool loading = false;

  AuthService authService;

  UserDto userDto;

  LoginForm _loginForm;

  final _formKey = GlobalKey<FormState>();

  Function selectHandler;

  _LoginComponentState(selectHandlerTemp) {
    this.authService = AuthService();
    this._loginForm = LoginForm();
    this.userDto = AuthService.currentUser;
    this.isPtLanguage = userDto.language == Constants.languages[0];
    this.selectHandler = selectHandlerTemp;
  }

  @override
  void initState() {
    super.initState();
    this.tryPreviousLogin();
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

    if (refresh) {
      this.selectHandler();
    }
  }

  goToResetPasswordPage() async {
    String email = this._loginForm.userMail.text;

    var reset = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => ResetPasswordComponent(email)));

    if (reset != null && reset) {
      //abrir modal de sucesso?
    }
  }

  Future<void> tryPreviousLogin() async {
    String uid = await _getLastUserId();

    if (uid != null) {
      setState(() {
        this.loading = true;
      });

      var x = await this.authService.loginByUid(uid);

      setState(() {
        this.loading = false;
      });

      this.selectHandler();
    }
  }

  Future<String> _getLastUserId() async {
    String uidStored;
    final prefs = await SharedPreferences.getInstance();
    uidStored = prefs.getString('uid');

    return uidStored;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
      backgroundColor: Styles.mainBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(
                          left: 20, right: 20, bottom: 20, top: 60),
                      decoration: Styles.loginBox,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(top: defaultMargin),
                              child: Image.asset(
                                'assets/images/ic_launcher_circle.png',
                                width: 80,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                top: 20,
                                bottom: defaultMargin,
                                left: 20,
                                right: 20,
                              ),
                              child: TextFormField(
                                style: TextStyle(color: Colors.grey.shade100),
                                keyboardType: TextInputType.emailAddress,
                                controller: _loginForm.userMail,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return Constants.getDefaultEmptyFieldMsg(
                                        isPtLanguage);
                                  }

                                  return null;
                                },
                                decoration:
                                    Styles.getTextFieldDecoration('email'),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  top: 10,
                                  bottom: defaultMargin,
                                  left: 20,
                                  right: 20),
                              child: TextFormField(
                                style: TextStyle(color: Colors.grey.shade100),
                                controller: _loginForm.password,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return Constants.getDefaultEmptyFieldMsg(
                                        isPtLanguage);
                                  }

                                  return null;
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: defaultBorderRadius,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: defaultBorderRadius,
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade900),
                                  ),
                                  labelStyle: TextStyle(color: Colors.grey),
                                  labelText: this.userDto.language ==
                                          Constants.languages[0]
                                      ? 'senha'
                                      : 'password',
                                ),
                                obscureText: true,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  top: defaultMargin,
                                  bottom: 30,
                                  left: 20,
                                  right: 20),
                              child: ButtonTheme(
                                minWidth: double.infinity,
                                height: 60.0,
                                child: RaisedButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: defaultBorderRadius,
                                  ),
                                  onPressed: () {
                                    if (_formKey.currentState.validate()) {
                                      _login();
                                    }
                                  },
                                  color: Colors.deepPurple,
                                  child: Text(
                                    this.userDto.language ==
                                            Constants.languages[0]
                                        ? 'Entrar'
                                        : 'Login',
                                    style: TextStyle(
                                        color: Styles.mainBackgroundColor,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w500),
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
                                      onPressed: this.goToResetPasswordPage,
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
                  ],
                ),
              ),
            ),
            // Container(
            //   alignment: Alignment.topRight,
            //   margin: EdgeInsets.only(right: defaultMargin),
            //   child: DropdownButton<String>(
            //     value: dropdownValue,
            //     icon: Icon(Icons.keyboard_arrow_down),
            //     iconSize: 24,
            //     elevation: 16,
            //     style: TextStyle(
            //       color: Colors.grey,
            //     ),
            //     underline: Container(
            //       height: 1,
            //       color: Colors.white10,
            //     ),
            //     onChanged: (String newValue) {
            //       changeLanguage(newValue);
            //     },
            //     items: Constants.languages
            //         .map<DropdownMenuItem<String>>((String value) {
            //       return DropdownMenuItem<String>(
            //         value: value,
            //         child: Text(value),
            //       );
            //     }).toList(),
            //   ),
            // ),
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
      ),
    );
  }
}
