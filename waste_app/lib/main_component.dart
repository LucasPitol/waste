import 'package:flutter/material.dart';
import 'package:waste_app/pages/profile/profile_component.dart';
import 'package:waste_app/pages/spends/spends.dart';

import 'pages/new-spend/new-spend-component.dart';

class MainComponent extends StatefulWidget {
  @override
  _MainComponentState createState() => _MainComponentState();
}

class _MainComponentState extends State<MainComponent> {
  FloatingActionButtonLocation _addFabLocation =
      FloatingActionButtonLocation.centerDocked;

  int _selectedIndex = 0;

  void _goToNewSpendPage() async {
    var refresh = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => NewSpendComponent()));

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

  void _updateSpendsPage() {}

  void _updateProfilePage() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      body: Container(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToNewSpendPage,
        backgroundColor: Colors.deepPurple,
        child: Icon(
          Icons.add,
          color: Colors.deepPurple.shade50,
        ),
      ),
      floatingActionButtonLocation: this._addFabLocation,
      bottomNavigationBar: this._buildBottomNavAppBar(),
    );
  }

  final List<Widget> _widgetOptions = <Widget>[
    SpendsComponent(),
    ProfileComponent(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  BottomNavigationBar _buildBottomNavAppBar() {
    return BottomNavigationBar(
      showSelectedLabels: false,
      showUnselectedLabels: false,
      unselectedItemColor: Colors.deepPurple.shade300,
      selectedItemColor: Colors.deepPurple.shade100,
      backgroundColor: Colors.deepPurple,
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
