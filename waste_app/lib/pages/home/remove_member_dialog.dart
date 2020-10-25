import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waste_app/models/dtos/member-dto.dart';
import 'package:waste_app/models/user_dto.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/utils/constants.dart';
import 'package:waste_app/utils/styles.dart';

class RemoveMemberDialogComponent extends StatefulWidget {
  final MemberDto member;

  RemoveMemberDialogComponent(this.member);
  @override
  _RemoveMemberDialogComponentState createState() =>
      _RemoveMemberDialogComponentState(member);
}

class _RemoveMemberDialogComponentState
    extends State<RemoveMemberDialogComponent> {
  UserDto userDto = AuthService.currentUser;
  MemberDto member;
  bool isPtLanguage;

  AuthService authService;

  _RemoveMemberDialogComponentState(MemberDto member) {
    this.isPtLanguage = userDto.language == Constants.languages[0];
    this.member = member;
    this.authService = AuthService();
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => this._showDialog());
    this.authService.userExists(context);
  }

  _showDialog() {
    String memberName = this.member.name;
    String memberEmail = this.member.email;
    String contentText = isPtLanguage
        ? 'Tem certeza que deseja remover o acesso de ' +
            memberName +
            ' à carteira?'
        : 'Are you sure you want to remove ' +
            memberName +
            ' access to that wallet?';

    return showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
          return Transform(
            transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                backgroundColor: Colors.black,
                shape: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade900),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                title: Text(
                  isPtLanguage ? 'Remover membro' : 'Remove member',
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade100,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                content: Theme(
                  data: Styles.mainTheme,
                  child: Container(
                    height: 75,
                    child: Column(
                      children: [
                        Text(
                          contentText,
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(top: 10),
                          child: Text(
                            '(' + memberEmail + ')',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                actions: <Widget>[
                  FlatButton(
                    textColor: Colors.grey,
                    onPressed: () {
                      closeDialog(false);
                    },
                    child: Text(
                      isPtLanguage ? 'Cancelar' : 'Cancel',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                  ),
                  FlatButton(
                    textColor: Colors.deepPurple,
                    onPressed: () async {
                      closeDialog(true);
                    },
                    child: Text(
                      isPtLanguage ? 'Remover' : 'Remove',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: false,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {});
  }

  closeDialog(bool action) {
    Navigator.pop(context, action);
    Navigator.pop(context, action);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
