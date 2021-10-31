import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:waste_app/models/forms/login_form.dart';
import 'package:waste_app/pages/dialogs/alert_dialog_component.dart';
import 'package:waste_app/pages/shared/loading_block.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/utils/constants.dart';
import 'package:waste_app/utils/styles.dart';

class ChangePasswordComponent extends StatefulWidget {
  @override
  _ChangePasswordComponentState createState() =>
      _ChangePasswordComponentState();
}

class _ChangePasswordComponentState extends State<ChangePasswordComponent> {
  final _formKey = GlobalKey<FormState>();

  bool loading = false;
  bool verified = false;

  bool isPtLanguage;
  TextEditingController previousPasswordController;
  TextEditingController newPasswordController;
  TextEditingController confirmNewPasswordController;
  AuthService _authService;

  _ChangePasswordComponentState() {
    this.isPtLanguage =
        AuthService.currentUser.language == Constants.languages[0];
    this.previousPasswordController = TextEditingController();
    this.newPasswordController = TextEditingController();
    this.confirmNewPasswordController = TextEditingController();
    this._authService = AuthService();
  }

  Widget _getAppBar() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Text(
              isPtLanguage ? 'Alteração de senha' : 'Change password',
              style: Styles.pageTitleStyle,
            ),
          ),
          Container(
            child: InkWell(
              borderRadius: Styles.circularBorderRadius,
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                padding: EdgeInsets.all(5),
                child: FaIcon(
                  FontAwesomeIcons.times,
                  size: 22,
                  color: Colors.grey.shade100,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _changePassword() {
    setState(() {
      this.loading = true;
    });

    var newPassword = newPasswordController.text;
    var userId = AuthService.currentUser.uid;

    this._authService.changePassword(newPassword, userId).then((value) async {
      if (value) {
        await _openInfoDialog('Sucesso!', 'Senha alterada');
        Navigator.pop(context);
      } else {
        String title = 'Ops...';
        String content = isPtLanguage
            ? 'Não foi possível alterar a senha, tente novamente mais tarde'
            : 'Unable to change password, please try again later';

        _openInfoDialog(title, content);
      }

      setState(() {
        this.loading = false;
      });
    });
  }

  _verifyUser() {
    setState(() {
      this.loading = true;
    });

    var _loginForm = LoginForm();

    _loginForm.password.text = previousPasswordController.text;
    _loginForm.userMail.text = AuthService.currentUser.email;

    this._authService.login(_loginForm).then((value) {
      if (value != null) {
        setState(() {
          this.verified = true;
        });
      } else {
        String title = 'Ops...';
        String content = isPtLanguage ? 'Senha inválida' : 'Invalid password';

        _openInfoDialog(title, content);
      }

      setState(() {
        this.loading = false;
      });
    });
  }

  Future<void> _openInfoDialog(String title, String content) async {
    await showDialog<String>(
        context: context,
        builder: (builder) {
          return AlertDialogComponent(title, content);
        });
  }

  Widget _getActionBtn() {
    String displayName;
    Function action;

    if (verified) {
      action = () => _changePassword();
      displayName = isPtLanguage ? 'Salvar' : 'Save';
    } else {
      action = () => _verifyUser();
      displayName = isPtLanguage ? 'Proximo' : 'Next';
    }

    return Container(
      alignment: Alignment.bottomCenter,
      margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            if (verified) {
              if (_formKey.currentState.validate()) {
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
              fontWeight: FontWeight.w500,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _getPageContent() {
    Widget content = !verified
        ? Container(
            margin: EdgeInsets.only(top: 20),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                style: Styles.montText,
                keyboardType: TextInputType.visiblePassword,
                controller: previousPasswordController,
                obscureText: true,
                validator: (value) {
                  if (value.isEmpty) {
                    return Constants.getDefaultEmptyFieldMsg(isPtLanguage);
                  }

                  return null;
                },
                decoration: Styles.getTextFieldDecorationUnderline(isPtLanguage
                    ? 'Confirme a senha atual'
                    : 'Type your current password'),
              ),
            ),
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Form(
                key: _formKey,
                child: Container(
                  // height: 280,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: TextFormField(
                          style: Styles.montText,
                          keyboardType: TextInputType.visiblePassword,
                          controller: newPasswordController,
                          obscureText: true,
                          validator: (value) {
                            if (value.isEmpty) {
                              return Constants.getDefaultEmptyFieldMsg(
                                  isPtLanguage);
                            }

                            if (value.length <= 5) {
                              return 'Senha deve ter mais de 5 caracteres';
                            }

                            if (value.length >= 50) {
                              return 'Senha maior que 50 caracteres';
                            }

                            return null;
                          },
                          decoration: Styles.getTextFieldDecorationUnderline(
                              isPtLanguage ? 'Nova senha' : 'New password'),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: TextFormField(
                          style: Styles.montText,
                          keyboardType: TextInputType.visiblePassword,
                          controller: confirmNewPasswordController,
                          obscureText: true,
                          validator: (value) {
                            if (value.isEmpty) {
                              return Constants.getDefaultEmptyFieldMsg(
                                  isPtLanguage);
                            }

                            if (value.length <= 5) {
                              return 'Senha deve ter mais de 5 caracteres';
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
                              isPtLanguage
                                  ? 'Confirme a nova senha'
                                  : 'Confirm new password'),
                        ),
                      ),
                    ],
                  ),
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
                _getAppBar(),
                _getPageContent(),
              ],
            ),
            _getActionBtn(),
            LoadingBlock(loading),
          ],
        ),
      ),
    );
  }
}
