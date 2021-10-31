import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meudin_app/models/forms/new_user_form.dart';
import 'package:meudin_app/pages/shared/info_bottom_sheet_widget.dart';
import 'package:meudin_app/pages/shared/loading_block.dart';
import 'package:meudin_app/services/user_service.dart';
import 'package:meudin_app/utils/constants.dart';
import 'package:meudin_app/utils/styles.dart';

class RegisterUserComponent extends StatefulWidget {
  @override
  _RegisterUserComponentState createState() => _RegisterUserComponentState();
}

class _RegisterUserComponentState extends State<RegisterUserComponent> {
  final _formKey = GlobalKey<FormState>();

  late UserService _userService;
  late NewUserForm newUserForm;

  bool loading = false;

  _RegisterUserComponentState() {
    _userService = UserService();
    newUserForm = NewUserForm();
  }

  void _goBack(bool loggedIn) {
    Navigator.pop(context, loggedIn);
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      alignment: Alignment.topRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Cadastro',
            style: Styles.montTextTitle,
          ),
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.times,
              color: Styles.mainTextColor,
              size: 22,
            ),
            onPressed: () {
              if (!loading) {
                _goBack(false);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SizedBox(
      height: 340,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 20, right: 20),
              child: TextFormField(
                style: TextStyle(color: Styles.mainTextColor),
                maxLength: 50,
                controller: newUserForm.name,
                textCapitalization: TextCapitalization.words,
                keyboardType: TextInputType.name,
                validator: (value) {
                  if (value!.isEmpty) {
                    return Constants.getDefaultEmptyFieldMsg();
                  }
                  return null;
                },
                decoration: Styles.getTextFieldDecorationUnderline('Nome'),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 20, right: 20),
              child: TextFormField(
                style: TextStyle(color: Styles.mainTextColor),
                maxLength: 200,
                controller: newUserForm.email,
                keyboardType: TextInputType.emailAddress,
                textCapitalization: TextCapitalization.none,
                validator: (value) {
                  if (value!.isEmpty) {
                    return Constants.getDefaultEmptyFieldMsg();
                  }

                  if ((!value.contains('.com') || !value.contains('@'))) {
                    return Constants.getDefaultInvalidEmailMsg();
                  }

                  return null;
                },
                decoration: Styles.getTextFieldDecorationUnderline('Email'),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 20, right: 20),
              child: TextFormField(
                style: TextStyle(color: Styles.mainTextColor),
                maxLength: 200,
                controller: newUserForm.password,
                keyboardType: TextInputType.visiblePassword,
                textCapitalization: TextCapitalization.none,
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return Constants.getDefaultEmptyFieldMsg();
                  }

                  if (value.length <= 6) {
                    return 'Senha deve ter mais de 6 caractere';
                  }

                  return null;
                },
                decoration: Styles.getTextFieldDecorationUnderline('Senha'),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (!loading) {
                        _createNewUser();
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Styles.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: Styles.defaultBorderRadius,
                    ),
                  ),
                  child: Text(
                    'Cadastrar',
                    style: Styles.buttonTextStyle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _createNewUser() {
    setState(() {
      loading = true;
    });

    _userService.createNewUser(newUserForm).then((res) {
      if (res == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Não foi possivel comunicar com o servidor, tente novamente mais tarde'),
          ),
        );
      } else {
        if (res.success) {
          _goBack(true);
        } else {
          String title = 'Ops...';
          String message = res.errorMsg;

          _openLoginBottomSheet(title, message);
        }
      }
      setState(() {
        loading = false;
      });
    });
  }

  void _openLoginBottomSheet(String title, String message) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Styles.cardColor,
        builder: (builder) {
          return InfoBottomSheetWidget(title: title, message: message);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Styles.mainBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  _buildAppBar(),
                  const SizedBox(
                    width: double.infinity,
                    height: 20,
                  ),
                  _buildForm(),
                  const SizedBox(
                    width: double.infinity,
                    height: 80,
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
