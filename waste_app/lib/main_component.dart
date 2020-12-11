import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'pages/new_revenue/new_revenue_component.dart';
import 'package:waste_app/pages/spends/spends.dart';
import 'pages/new_spend/new_spend_component.dart';
import 'pages/profits/profits_component.dart';
import 'pages/home/home_conponent.dart';
import 'package:flutter/material.dart';



class MainComponent extends StatefulWidget {
  @override
  _MainComponentState createState() => _MainComponentState();
}

GlobalKey<HomeComponentState> homeComponentGlobalKey = GlobalKey();
GlobalKey<SpendsComponentState> spendsComponentGlobalKey = GlobalKey();

final GlobalKey<FabCircularMenuState> fabKey = GlobalKey();

class _MainComponentState extends State<MainComponent> {
  FloatingActionButtonLocation _addFabLocation =
      FloatingActionButtonLocation.centerDocked;

  int _selectedIndex = 0;

  void _goToNewSpendPage() async {
    fabKey.currentState.close();

    var refresh = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => NewSpendComponent()));

    _updateLayout();

    if (refresh != null && refresh) {
      _refreshData();
    }
  }

  void _goToNewRevenuePage() async {
    fabKey.currentState.close();

    var refresh = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => NewRevenueComponent()));

    _updateLayout();

    if (refresh != null && refresh) {
      _refreshData();
    }
  }

  _updateLayout() {
    switch (_selectedIndex) {
      case 0:
        homeComponentGlobalKey.currentState.updateAppBar();
        break;
      default:
    }
  }

  void _refreshData() {
    switch (_selectedIndex) {
      case 0:
        _updateHomePage();
        break;
      case 1:
        _updateSpendsPage();
        break;
      default:
        break;
    }
  }

  void _updateHomePage() {
    homeComponentGlobalKey.currentState.updatePageContent();
  }

  void _updateSpendsPage() {
    spendsComponentGlobalKey.currentState.refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      body: Stack(
        children: [
          Container(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 32.5,
              width: 65,
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(40.0),
                        topRight: const Radius.circular(40.0))),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FabCircularMenu(
        key: fabKey,
        alignment: Alignment.bottomCenter,
        fabMargin: EdgeInsets.only(bottom: 45, right: 32),
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
      floatingActionButtonLocation: this._addFabLocation,
      bottomNavigationBar: this._buildBottomNavAppBar(),
    );
  }

  final List<Widget> _widgetOptions = <Widget>[
    HomeComponent(key: homeComponentGlobalKey),
    SpendsComponent(key: spendsComponentGlobalKey),
    Container(),
    ProfitsComponent(),
    Container(),
  ];

  void _onItemTapped(int index) {
    if (fabKey.currentState.isOpen) {
      fabKey.currentState.close();
    }

    // if (_selectedIndex == 2 && _selectedIndex != index) {
    //   if (profileComponentGlobalKey.currentState.isEndDrawerOpen()) {
    //     Navigator.pop(profileComponentGlobalKey.currentContext);
    //   }
    // }

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
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          title: Text(''),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.money_off),
          title: Text(''),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.arrow_drop_down),
          title: Text(''),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.attach_money),
          title: Text(''),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.pie_chart_outlined),
          title: Text(''),
        ),
      ],
    );
  }
}
