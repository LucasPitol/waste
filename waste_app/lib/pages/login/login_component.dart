import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waste_app/models/login_form.dart';
import 'package:waste_app/models/user_dto.dart';
import 'package:waste_app/pages/dialogs/alert_dialog_component.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/services/google_sign_service.dart';
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

  GoogleSignService googleSignService;

  UserDto userDto;

  LoginForm _loginForm;

  final _formKey = GlobalKey<FormState>();

  Function selectHandler;

  _LoginComponentState(selectHandlerTemp) {
    this.authService = AuthService();
    this.googleSignService = GoogleSignService();
    this._loginForm = LoginForm();
    this.userDto = AuthService.currentUser;
    this.userDto.language = dropdownValue;
    this.selectHandler = selectHandlerTemp;
  }

  @override
  void initState() {
    super.initState();
    this.tryPreviousLogin();
  }

  void changeLanguage(String language) {
    AuthService.changeLanguage(language);

    setState(() {
      this.userDto = AuthService.currentUser;
      this.dropdownValue = this.userDto.language;
    });
  }

  Future<void> _loginWithGoogle() async {
    setState(() {
      this.loading = true;
    });
    var user = await googleSignService.googleSignIn();

    this.userDto = AuthService.currentUser;
    setState(() {
      this.loading = false;
    });
    this.selectHandler();
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

  Future<void> tryPreviousLogin() async {
    String uid = await _getLastUserId();

    if (uid != null) {
      setState(() {
        this.loading = true;
      });

      var x = await this.googleSignService.loginByUid(uid);

      setState(() {
        this.loading = false;
      });

      this.selectHandler();
    }
  }

  Future<String> _getLastUserId() async {
    String uidStored;
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getKeys();

    if (userId != null && userId.isNotEmpty) {
      uidStored = userId.first;

      // String loginType = await prefs.getString(uidStored);
    }

    return uidStored;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(vertical: 100),
                      child: Text(
                        'Waste',
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(
                          bottom: defaultMargin, left: 20, right: 20),
                      child: ButtonTheme(
                        height: 40.0,
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: defaultBorderRadius,
                          ),
                          onPressed: () => _loginWithGoogle(),
                          color: mainColor,
                          child: Text(
                            this.userDto.language == Constants.languages[0]
                                ? 'Continuar com Google'
                                : 'Login with Google',
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
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
