import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waste_app/models/dtos/language_and_code_dto.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/utils/constants.dart';
import 'package:waste_app/utils/styles.dart';

class ChangeLanguageDialogComponent extends StatefulWidget {
  @override
  _ChangeLanguageDialogComponentState createState() =>
      _ChangeLanguageDialogComponentState();
}

class _ChangeLanguageDialogComponentState
    extends State<ChangeLanguageDialogComponent> {
  AuthService authService;
  String dropdownWalletValue;
  List<LanguageAndCodeDto> options;
  String currentLanguageCode = AuthService.currentUser.language;

  _ChangeLanguageDialogComponentState() {
    this.authService = AuthService();
    this.options = List<LanguageAndCodeDto>();
    this.setOptions();
  }

  setOptions() {
    this.dropdownWalletValue = currentLanguageCode;

    String autoCode = 'auto';
    this.options.add(LanguageAndCodeDto('Auto', autoCode));

    String enCode = Constants.languages[1];
    this.options.add(LanguageAndCodeDto('English', enCode));

    String ptCode = Constants.languages[0];
    this.options.add(LanguageAndCodeDto('Português', ptCode));
  }

  void switchLanguage(String languageCode) {
    setState(() {
      this.dropdownWalletValue = languageCode;
    });

    this.authService.changeLanguage(languageCode);

    closeDialog(true);
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => this._showDialog());
    this.authService.userExists(context);
  }

  _showDialog() {
    return showGeneralDialog(
      transitionBuilder: (context, a1, a2, widget) {
        final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
          child: Opacity(
            opacity: a1.value,
            child: AlertDialog(
              shape: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              title: Text(
                this.currentLanguageCode == Constants.languages[0]
                    ? 'Alterar idioma'
                    : 'Change language',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w400),
              ),
              content: Theme(
                data: Styles.mainTheme,
                child: Container(
                  height: 80,
                  child: DropdownButton<String>(
                    value: dropdownWalletValue,
                    icon: Icon(Icons.keyboard_arrow_down),
                    iconSize: 24,
                    elevation: 16,
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                    underline: Container(
                      height: 1,
                      color: Colors.white10,
                    ),
                    onChanged: (String newValue) {
                      switchLanguage(newValue);
                    },
                    items: options.map<DropdownMenuItem<String>>(
                        (LanguageAndCodeDto item) {
                      return DropdownMenuItem<String>(
                        value: item.code,
                        child: Text(item.displayName),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 200),
      barrierDismissible: false,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {},
    );
  }

  closeDialog(bool action) {
    String newLanguage = this.dropdownWalletValue;

    Navigator.pop(context, [action, newLanguage]);
    Navigator.pop(context, [action, newLanguage]);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
