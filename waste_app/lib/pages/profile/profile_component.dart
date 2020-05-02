import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waste_app/models/user_dto.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/services/spends-service.dart';
import 'package:waste_app/utils/constants.dart';

class ProfileComponent extends StatefulWidget {
  @override
  _ProfileComponentState createState() => _ProfileComponentState();
}

class _ProfileComponentState extends State<ProfileComponent> {
  UserDto userDto = AuthService.currentUser;
  double totalWasteThisYear = 0.0;
  bool totalWasteThisYearLoading = true;

  SpendsService spendService;

  _ProfileComponentState() {
    this.spendService = SpendsService();
  }

  List<String> wallets = ['Carteira pessoal', 'Carteira secundária'];
  
  String dropdownWalletValue = 'Carteira pessoal';


  void initState() {
    super.initState();
    this._getTotalWasteThisYear();
  }

  void switchWallets(String wallet) {
    setState(() {
      this.dropdownWalletValue = wallet;
    });
  }

  Future<void> _getTotalWasteThisYear() async {
    setState(() {
      totalWasteThisYearLoading = true;
    });

    DateTime now = DateTime.now();

    double total = await this.spendService.getTotalWasteByYear(now);

    this.totalWasteThisYear = total;

    setState(() {
      this.totalWasteThisYearLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        actions: <Widget>[
          GestureDetector(
            onTap: () {},
            child: Container(
              margin: EdgeInsets.only(right: 10),
              child: Icon(
                Icons.menu,
                color: Colors.white,
              ),
            ),
          ),
        ],
        title: Text(
          'Waste',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              child: Stack(
                children: <Widget>[
                  Container(
                    alignment: Alignment.topLeft,
                    margin: EdgeInsets.only(left: 10),
                    child: DropdownButton<String>(
                      value: dropdownWalletValue,
                      icon: Icon(Icons.keyboard_arrow_down),
                      iconSize: 24,
                      elevation: 16,
                      style: GoogleFonts.quicksand(
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                      underline: Container(
                        height: 1,
                        color: Colors.white10,
                      ),
                      onChanged: (String newValue) {
                        switchWallets(newValue);
                      },
                      items:
                          wallets.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  Container(
                    alignment: Alignment.topRight,
                    child: FlatButton(
                      onPressed: () {},
                      child: Text(
                        this.userDto.language == Constants.languages[0]
                            ? 'Gerenciar carteiras'
                            : 'Manage wallets',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.topCenter,
              margin: EdgeInsets.only(top: 20),
              width: 200,
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 10, bottom: 5),
                    child: Text(
                      'Gastos em 2020',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: totalWasteThisYearLoading
                        ? Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: Theme(
                              data: Theme.of(context)
                                  .copyWith(accentColor: Colors.deepPurple),
                              child: new CircularProgressIndicator(),
                            ),
                          )
                        : Text(
                            '-' +
                                Constants.getAmountFormated(totalWasteThisYear),
                            style: TextStyle(
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
