import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meudin_app/services/user_service.dart';
import 'package:meudin_app/utils/constants.dart';
import 'package:meudin_app/utils/styles.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

import 'settings_menu_item_widget.dart';

class SettingsComponent extends StatefulWidget {
  @override
  _SettingsComponentState createState() => _SettingsComponentState();
}

class _SettingsComponentState extends State<SettingsComponent> {
  
  late UserService _userService;

  _SettingsComponentState() {
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
              'Configurações',
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

  _goToInstagram() async {
    var url = Constants.instagramUrl;

    await launch(
      url,
      forceSafariVC: false,
      universalLinksOnly: true,
    );
  }

  _getPrivacyPolicy() async {
    var url = Constants.privacyPolicyUrl;

    await launch(
      url,
      forceSafariVC: false,
      universalLinksOnly: true,
    );
  }

  _goToChangePasswordPage() {
    print('change password');
  }

  Future<void> _logout() async {
    await _userService.signOut();
    Phoenix.rebirth(context);
  }

  _openAboutDialog() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appName = packageInfo.appName;
    String appVersion = packageInfo.version;

    showAboutDialog(
      context: context,
      applicationName: appName,
      applicationVersion: appVersion,
      // applicationIcon: Container(
      //   child: Image.asset(
      //     'assets/ic_launcher.png',
      //     width: 50,
      //   ),
      // ),
      children: [
        Text(
          '...',
          style: TextStyle(color: Colors.grey.shade800),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.mainBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildAppBar(),
              const SizedBox(
                height: 40,
                width: double.infinity,
              ),
              SettingsMenuItemWidget(
                icon: FontAwesomeIcons.instagram,
                label: 'Instagram',
                handlerFunction: _goToInstagram,
              ),
              SettingsMenuItemWidget(
                icon: FontAwesomeIcons.lock,
                label: 'Alterar senha',
                handlerFunction: _goToChangePasswordPage,
              ),
              SettingsMenuItemWidget(
                icon: FontAwesomeIcons.shieldAlt,
                label: 'Política de privacidade',
                handlerFunction: _getPrivacyPolicy,
              ),
              SettingsMenuItemWidget(
                icon: FontAwesomeIcons.infoCircle,
                label: 'Sobre',
                handlerFunction: _openAboutDialog,
              ),
              SettingsMenuItemWidget(
                icon: FontAwesomeIcons.signOutAlt,
                label: 'Sair',
                handlerFunction: _logout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
