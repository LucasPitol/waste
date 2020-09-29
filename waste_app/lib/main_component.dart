import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:waste_app/pages/profile/profile_component.dart';
import 'package:waste_app/pages/spends/spends.dart';

import 'pages/new_revenue/new_revenue_component.dart';
import 'pages/new_spend/new_spend_component.dart';

class MainComponent extends StatefulWidget {
  @override
  _MainComponentState createState() => _MainComponentState();
}

GlobalKey<SpendsComponentState> spendsComponentGlobalKey = GlobalKey();
GlobalKey<ProfileComponentState> profileComponentGlobalKey = GlobalKey();

final GlobalKey<FabCircularMenuState> fabKey = GlobalKey();

class _MainComponentState extends State<MainComponent> {
  FloatingActionButtonLocation _addFabLocation =
      FloatingActionButtonLocation.centerDocked;

  int _selectedIndex = 0;

  void _goToNewSpendPage() async {
    fabKey.currentState.close();

    var refresh = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => NewSpendComponent()));

    if (refresh != null && refresh) {
      _refreshData();
    }
  }

  void _goToNewRevenuePage() async {
    fabKey.currentState.close();

    var refresh = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => NewRevenueComponent()));

    if (refresh != null && refresh) {
      _refreshData();
    }
  }

  void _refreshData() {
    switch (_selectedIndex) {
      case 0:
        _updateSpendsPage();
        break;
      case 1:
        _updateProfilePage();
        break;
      default:
        break;
    }
  }

  void _updateSpendsPage() {
    spendsComponentGlobalKey.currentState.refreshData();
  }

  void _updateProfilePage() {
    profileComponentGlobalKey.currentState.refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      body: Container(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      floatingActionButton: FabCircularMenu(
        key: fabKey,
        alignment: Alignment.bottomCenter,
        fabMargin: EdgeInsets.only(bottom: 45, right: 35),
        animationDuration: Duration(milliseconds: 300),
        ringDiameter: 200,
        ringColor: Colors.white10,
        fabColor: Colors.black,
        fabCloseIcon: Icon(
          Icons.close,
          color: Colors.deepPurple,
        ),
        fabOpenIcon: Icon(
          Icons.add,
          color: Colors.deepPurple,
        ),
        children: [
          IconButton(
            icon: Icon(
              Icons.trending_down,
              color: Colors.red,
            ),
            onPressed: _goToNewSpendPage,
          ),
          IconButton(
            icon: Icon(
              Icons.trending_up,
              color: Colors.green,
            ),
            onPressed: _goToNewRevenuePage,
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.all(Radius.circular(50)),
      //     side: BorderSide(color: Colors.grey.shade900),
      //   ),
      //   onPressed: _goToNewSpendPage,
      //   backgroundColor: Colors.black,
      //   splashColor: Colors.deepPurple.shade300,
      //   child: Icon(
      //     Icons.add,
      //     color: Colors.deepPurple,
      //   ),
      // ),
      floatingActionButtonLocation: this._addFabLocation,
      bottomNavigationBar: this._buildBottomNavAppBar(),
    );
  }

  final List<Widget> _widgetOptions = <Widget>[
    SpendsComponent(key: spendsComponentGlobalKey),
    ProfileComponent(key: profileComponentGlobalKey),
  ];

  void _onItemTapped(int index) {
    if (fabKey.currentState.isOpen) {
      fabKey.currentState.close();
    }

    if (_selectedIndex == 1 && index == 0) {
      if (profileComponentGlobalKey.currentState.isEndDrawerOpen()) {
        Navigator.pop(profileComponentGlobalKey.currentContext);
      }
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  BottomNavigationBar _buildBottomNavAppBar() {
    return BottomNavigationBar(
      showSelectedLabels: false,
      showUnselectedLabels: false,
      unselectedItemColor: Colors.grey,
      selectedItemColor: Colors.deepPurple,
      backgroundColor: Colors.black,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.money_off),
          title: Text(''),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          title: Text(''),
        ),
      ],
    );
  }
}
