import 'pages/new_revenue/new_revenue_component.dart';
import 'package:waste_app/pages/spends/spends.dart';
import 'pages/new_spend/new_spend_component.dart';
import 'pages/overview/overview_component.dart';
import 'pages/profits/profits_component.dart';
import 'package:waste_app/utils/layout.dart';
import 'package:waste_app/utils/styles.dart';
import 'pages/home/home_conponent.dart';
import 'package:flutter/material.dart';

import 'utils/fab_with_icons.dart';

class MainComponent extends StatefulWidget {
  @override
  _MainComponentState createState() => _MainComponentState();
}

GlobalKey<HomeComponentState> homeComponentGlobalKey = GlobalKey();
GlobalKey<SpendsComponentState> spendsComponentGlobalKey = GlobalKey();
GlobalKey<ProfitsComponentState> profitsComponentGlobalKey = GlobalKey();
GlobalKey<OverviewComponentState> overviewComponentGlobalKey = GlobalKey();

class _MainComponentState extends State<MainComponent> {
  FloatingActionButtonLocation _addFabLocation =
      FloatingActionButtonLocation.centerDocked;

  final fabIcons = [Icons.trending_up, Icons.trending_down];

  int _selectedIndex = 0;

  void _goToNewSpendPage() async {

    var refresh = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => NewSpendComponent()));

    _updateLayout();

    if (refresh != null && refresh) {
      _refreshData();
    }
  }

  void _goToNewRevenuePage() async {

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
      case 2:
        _updateProfitsPage();
        break;

      default:
        break;
    }
  }

  void _updateProfitsPage() {
    profitsComponentGlobalKey.currentState.updateData();
  }

  void _updateHomePage() {
    homeComponentGlobalKey.currentState.updatePageContent();
  }

  void _updateSpendsPage() {
    spendsComponentGlobalKey.currentState.refreshData();
  }

  void _selectedFab(int index) {
    switch (index) {
      case 0:
        this._goToNewRevenuePage();
        break;

      case 1:
        this._goToNewSpendPage();
        break;

      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Styles.mainBackgroundColor,
      body: Container(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      floatingActionButton: AnchoredOverlay(
        showOverlay: true,
        overlayBuilder: (context, offset) {
          return CenterAbout(
            position: Offset(offset.dx, offset.dy - fabIcons.length * 35.0),
            child: FabWithIcons(
              icons: fabIcons,
              onIconTapped: _selectedFab,
            ),
          );
        },
        child: FloatingActionButton(
          backgroundColor: Styles.boxColor,
          onPressed: () {},
          child: Icon(
            Icons.add,
            color: Styles.primaryColor,
          ),
          elevation: 2.0,
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Styles.boxColor,
      //   child: Icon(
      //     Icons.add,
      //     color: Styles.primaryColor,
      //   ),
      //   onPressed: () {
      //     print('fab');
      //   },
      // ),
      floatingActionButtonLocation: this._addFabLocation,
      bottomNavigationBar: this._buildBottomNavAppBar(),
    );
  }

  final List<Widget> _widgetOptions = <Widget>[
    HomeComponent(key: homeComponentGlobalKey),
    SpendsComponent(key: spendsComponentGlobalKey),
    ProfitsComponent(key: profitsComponentGlobalKey),
    OverviewComponent(key: overviewComponentGlobalKey),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  BottomAppBar _buildBottomNavAppBar() {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      color: Styles.boxColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(
              Icons.home,
              color: _selectedIndex == 0 ? Styles.primaryColor : Colors.grey,
            ),
            onPressed: () {
              this._onItemTapped(0);
            },
          ),
          IconButton(
            icon: Icon(
              Icons.money_off,
              color: _selectedIndex == 1 ? Styles.primaryColor : Colors.grey,
            ),
            onPressed: () {
              this._onItemTapped(1);
            },
          ),
          Container(
            width: 24,
            height: 24,
          ),
          IconButton(
            icon: Icon(
              Icons.attach_money,
              color: _selectedIndex == 2 ? Styles.primaryColor : Colors.grey,
            ),
            onPressed: () {
              this._onItemTapped(2);
            },
          ),
          IconButton(
            icon: Icon(
              Icons.pie_chart_outline_outlined,
              color: _selectedIndex == 3 ? Styles.primaryColor : Colors.grey,
            ),
            onPressed: () {
              this._onItemTapped(3);
            },
          ),
        ],
      ),
    );
  }
}
