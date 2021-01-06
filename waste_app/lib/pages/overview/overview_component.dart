import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waste_app/models/user_dto.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/utils/constants.dart';
import 'package:waste_app/utils/styles.dart';

class OverviewComponent extends StatefulWidget {
  OverviewComponent({Key key}) : super(key: key);
  @override
  OverviewComponentState createState() => OverviewComponentState();
}

class OverviewComponentState extends State<OverviewComponent> {
  AuthService authService;
  UserDto userDto = AuthService.currentUser;
  bool isPtLanguage;

  OverviewComponentState() {
    this.isPtLanguage = userDto.language == Constants.languages[0];
    this.authService = AuthService();
  }

  void initState() {
    super.initState();
    this.updateAppBar();
    // this.updateData();
    this.authService.userExists(context);
  }

  updateAppBar() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Styles.mainBackgroundColor,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.mainBackgroundColor,
      resizeToAvoidBottomPadding: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(),
        ),
      ),
    );
  }
}
