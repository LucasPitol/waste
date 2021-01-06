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
    this.updateData();
    this.authService.userExists(context);
  }

  updateData() {
    print('update');
  }

  _infoBottomSheet() {
    print('info');
  }

  _openCalendar() {
    print('calendar');
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
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                Container(
                  child: Stack(
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        child: Text(
                          isPtLanguage ? 'Visão geral' : 'Overview',
                          style: TextStyle(
                            color: Colors.grey.shade100,
                            fontWeight: FontWeight.w600,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              margin: EdgeInsets.only(right: 15),
                              child: InkWell(
                                borderRadius: Styles.circularBorderRadius,
                                onTap: () {
                                  this.updateData();
                                },
                                child: Icon(
                                  Icons.refresh,
                                  color: Colors.grey.shade100,
                                ),
                              ),
                            ),
                            InkWell(
                              borderRadius: Styles.circularBorderRadius,
                              onTap: () {
                                this._infoBottomSheet();
                              },
                              child: Icon(
                                Icons.help_outline,
                                color: Colors.grey.shade100,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      alignment: Alignment.topRight,
                      margin: EdgeInsets.symmetric(vertical: 20),
                      decoration: Styles.contentBox2,
                      width: 250,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        // alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '01/01/2020 - ',
                              style: Styles.poppinsTextLight,
                            ),
                            Text(
                              '21/12/2020',
                              style: Styles.poppinsTextLight,
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 10),
                              child: InkWell(
                                borderRadius: Styles.circularBorderRadius,
                                onTap: () {
                                  this._openCalendar();
                                },
                                child: Icon(
                                  Icons.calendar_today,
                                  color: Styles.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
