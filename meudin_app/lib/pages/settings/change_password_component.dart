import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meudin_app/models/forms/login_form.dart';
import 'package:meudin_app/pages/shared/info_bottom_sheet_widget.dart';
import 'package:meudin_app/pages/shared/loading_block.dart';
import 'package:meudin_app/services/user_service.dart';
import 'package:meudin_app/utils/constants.dart';
import 'package:meudin_app/utils/styles.dart';

class ChangePasswordComponent extends StatefulWidget {
  @override
  _ChangePasswordComponentState createState() =>
      _ChangePasswordComponentState();
}

class _ChangePasswordComponentState extends State<ChangePasswordComponent> {
  final _formKey = GlobalKey<FormState>();

  bool loading = false;
  bool verified = false;

  late TextEditingController previousPasswordController;
  late TextEditingController newPasswordController;
  late TextEditingController confirmNewPasswordController;
  late UserService _userService;

  _ChangePasswordComponentState() {
    previousPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmNewPasswordController = TextEditingController();
    _userService = UserService();
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      alignment: Alignment.topRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            child: Text(
              'Alteração de senha',
              style: Styles.montTextTitle,
            ),
          ),
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.times,
              color: Styles.mainTextColor,
              size: 22,
            ),
            onPressed: () {
              _goBack(false);
            },
          ),
        ],
      ),
    );
  }

  _goBack(bool refresh) {
    Navigator.pop(context, refresh);
  }

  _changePassword() {
    setState(() {
      loading = true;
    });

    var newPassword = newPasswordController.text;
    var userId = UserService.currentUser!.id;

    _userService.changePassword(newPassword, userId).then((res) async {
      if (res.success) {
        _goBack(true);
      } else {
        String title = 'Ops...';
        String message = res.errorMsg;

        _openInfoBottomSheet(title, message);
      }

      setState(() {
        loading = false;
      });
    });
  }

  Widget _buildActionBtn() {
    String displayName;
    Function action;

    if (verified) {
      action = () => _changePassword();
      displayName = 'Salvar';
    } else {
      action = () => _verifyUser();
      displayName = 'Proximo';
    }

    return Container(
      alignment: Alignment.bottomCenter,
      margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            if (verified) {
              if (_formKey.currentState!.validate()) {
                action();
              }
            } else {
              if (previousPasswordController.text.isNotEmpty) {
                action();
              }
            }
          },
          style: Styles.elevatedButtonStyle,
          child: Text(
            displayName,
            style: TextStyle(
              color: Styles.mainBackgroundColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  void _openInfoBottomSheet(String title, String message) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Styles.cardColor,
        builder: (builder) {
          return InfoBottomSheetWidget(title: title, message: message);
        });
  }

  _verifyUser() {
    setState(() {
      loading = true;
    });

    var _loginForm = LoginForm();

    _loginForm.password.text = previousPasswordController.text;
    _loginForm.userMail.text = UserService.currentUser!.email;

    _userService.logIn(_loginForm).then((res) {
      if (res.success) {
        setState(() {
          verified = true;
        });
      } else {
        String title = 'Ops...';
        String message = res.errorMsg;

        _openInfoBottomSheet(title, message);
      }

      setState(() {
        loading = false;
      });
    });
  }

  Widget _buildPageContent() {
    Widget content = !verified
        ? Container(
            margin: const EdgeInsets.only(top: 20),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                style: Styles.montText,
                keyboardType: TextInputType.visiblePassword,
                controller: previousPasswordController,
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return Constants.getDefaultEmptyFieldMsg(context);
                  }

                  return null;
                },
                decoration: Styles.getTextFieldDecorationUnderline(
                    'Confirme a senha atual'),
              ),
            ),
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      child: TextFormField(
                        style: Styles.montText,
                        keyboardType: TextInputType.visiblePassword,
                        controller: newPasswordController,
                        obscureText: true,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return Constants.getDefaultEmptyFieldMsg(context);
                          }

                          if (value.length <= 6) {
                            return 'Senha deve ter mais de 6 caracteres';
                          }

                          if (value.length >= 50) {
                            return 'Senha maior que 50 caracteres';
                          }

                          return null;
                        },
                        decoration: Styles.getTextFieldDecorationUnderline(
                            'Nova senha'),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        style: Styles.montText,
                        keyboardType: TextInputType.visiblePassword,
                        controller: confirmNewPasswordController,
                        obscureText: true,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return Constants.getDefaultEmptyFieldMsg(context);
                          }

                          if (value.length <= 6) {
                            return 'Senha deve ter mais de 6 caracteres';
                          }

                          if (value.length >= 50) {
                            return 'Senha maior que 50 caracteres';
                          }

                          if (value != newPasswordController.text) {
                            return 'Senhas diferentes';
                          }

                          return null;
                        },
                        decoration: Styles.getTextFieldDecorationUnderline(
                            'Confirme a nova senha'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

    return content;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.mainBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildAppBar(),
                _buildPageContent(),
              ],
            ),
            _buildActionBtn(),
            LoadingBlock(loading),
          ],
        ),
      ),
    );
  }
}
