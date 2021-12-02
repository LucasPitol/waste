import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:meudin_app/models/forms/login_form.dart';
import 'package:meudin_app/pages/new_user/new_user_component.dart';
import 'package:meudin_app/pages/shared/info_bottom_sheet_widget.dart';
import 'package:meudin_app/pages/shared/loading_block.dart';
import 'package:meudin_app/services/user_service.dart';
import 'package:meudin_app/utils/constants.dart';
import 'package:meudin_app/utils/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../new_user/new_user_component.dart';

class LoginComponent extends StatefulWidget {
  final Function selectHandler;

  LoginComponent(this.selectHandler);

  @override
  _LoginComponentState createState() => _LoginComponentState(selectHandler);
}

class _LoginComponentState extends State<LoginComponent> {
  final _formKey = GlobalKey<FormState>();

  late Function selectHandler;
  late UserService _userService;
  late LoginForm _loginForm;

  bool loading = false;

  _LoginComponentState(selectHandlerTemp) {
    selectHandler = selectHandlerTemp;
    _userService = UserService();
    _loginForm = LoginForm();
  }

  @override
  void initState() {
    super.initState();
    tryPreviousLogin();
  }

  Future<void> _login() async {
    setState(() {
      loading = true;
    });

    FocusScope.of(context).unfocus();

    _userService.logIn(_loginForm).then((res) {
      if (res.success) {
        selectHandler();
      } else {
        if (res.errorMsg.isNotEmpty) {
          String title = 'Ops...';
          String message = res.errorMsg;

          _openInfoBottomSheet(title, message);
        } else {
          String title = 'Ops...';
          String message =
              AppLocalizations.of(context)!.unableToConnectTheServer;

          _openInfoBottomSheet(title, message);
        }
      }
      setState(() {
        loading = false;
      });
    });
  }

  void _openInfoBottomSheet(String title, String message) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Styles.cardColor,
        builder: (builder) {
          return InfoBottomSheetWidget(title: title, message: message);
        });
  }

  void _goToNewMemberPage() async {
    bool? refresh = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return RegisterUserComponent();
    }));

    if (refresh != null && refresh) {
      selectHandler();
    }
  }

  Future<void> tryPreviousLogin() async {
    setState(() {
      loading = true;
    });

    await _userService.loginByUid();

    setState(() {
      loading = false;
    });

    selectHandler();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
      backgroundColor: Styles.mainBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(
                        left: 20, right: 20, bottom: 20, top: 60),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.only(top: 20),
                            child: Image.asset(
                              'assets/images/ic_launcher_circle.png',
                              width: 80,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                              top: 20,
                              bottom: 20,
                              left: 20,
                              right: 20,
                            ),
                            child: TextFormField(
                              style: TextStyle(color: Colors.grey.shade100),
                              keyboardType: TextInputType.emailAddress,
                              controller: _loginForm.userMail,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return Constants.getDefaultEmptyFieldMsg(context);
                                }

                                return null;
                              },
                              decoration:
                                  Styles.getTextFieldDecorationUnderline(
                                      'email'),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                                top: 10, bottom: 20, left: 20, right: 20),
                            child: TextFormField(
                              style: TextStyle(color: Colors.grey.shade100),
                              controller: _loginForm.password,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return Constants.getDefaultEmptyFieldMsg(context);
                                }

                                return null;
                              },
                              decoration:
                                  Styles.getTextFieldDecorationUnderline(
                                      AppLocalizations.of(context)!.password),
                              obscureText: true,
                            ),
                          ),
                          Container(
                            alignment: Alignment.bottomCenter,
                            margin: const EdgeInsets.all(20),
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _login();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Styles.primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: Styles.defaultBorderRadius,
                                  ),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.signIn,
                                  style: Styles.buttonTextStyle,
                                ),
                              ),
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
                        Text(
                          AppLocalizations.of(context)!.newArroundHere,
                          style: TextStyle(fontSize: 14.0, color: Colors.grey),
                        ),
                        TextButton(
                          onPressed: _goToNewMemberPage,
                          child: Text(
                            AppLocalizations.of(context)!.signUp,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Styles.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            LoadingBlock(loading),
          ],
        ),
      ),
    );
  }
}
