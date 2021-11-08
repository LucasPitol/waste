import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter/material.dart';

import 'pages/new_revenue/new_revenue_component.dart';
import 'pages/home/home_component.dart';
import 'pages/new_spend/new_spend_component.dart';
import 'utils/styles.dart';

class MainComponent extends StatefulWidget {
  @override
  _MainComponentState createState() => _MainComponentState();
}

GlobalKey<HomeComponentState> homeComponentGlobalKey = GlobalKey();
// GlobalKey<SpendsComponentState> spendsComponentGlobalKey = GlobalKey();
// GlobalKey<ProfitsComponentState> profitsComponentGlobalKey = GlobalKey();
// GlobalKey<OverviewComponentState> overviewComponentGlobalKey = GlobalKey();

class _MainComponentState extends State<MainComponent> {
  final FloatingActionButtonLocation _addFabLocation =
      FloatingActionButtonLocation.centerDocked;

  final List<Widget> _widgetOptions = <Widget>[
    HomeComponent(key: homeComponentGlobalKey), Container(),
    // HomeComponent(
    //     key: homeComponentGlobalKey,
    //     overlayBuilderStatelKey: overlayBuilderStatelKey),
    // SpendsComponent(
    //     key: spendsComponentGlobalKey,
    //     overlayBuilderStatelKey: overlayBuilderStatelKey),
    // ProfitsComponent(
    //     key: profitsComponentGlobalKey,
    //     overlayBuilderStatelKey: overlayBuilderStatelKey),
    // OverviewComponent(
    //     key: overviewComponentGlobalKey,
    //     overlayBuilderStatelKey: overlayBuilderStatelKey),
  ];

  // AnchoredOverlay customFab;

  int _selectedIndex = 0;

  void _refreshData() {
    switch (_selectedIndex) {
      case 0:
        _updateHomePage();
        break;
      case 1:
        print('update overview');
        // _updateOverviewPage();
        break;

      default:
        break;
    }
  }

  _updateHomePage() {
    homeComponentGlobalKey.currentState!.updatePageData();
  }

  _goToNewSpendPage() async {
    bool? refresh = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => NewSpendComponent()));

    if (refresh != null && refresh) {
      _refreshData();
    }
  }

  _goToNewRevenuePage() async {
    bool? refresh = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => NewRevenueComponent()));

    if (refresh != null && refresh) {
      _refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Styles.mainBackgroundColor,
      body: SafeArea(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      floatingActionButton: SpeedDial(
        // activeBackgroundColor: Styles.cardColor,
        backgroundColor: Styles.cardColor,
        icon: FontAwesomeIcons.plus,
        activeIcon: FontAwesomeIcons.times,
        foregroundColor: Styles.primaryColor,
        overlayColor: Styles.mainBackgroundColor,
        children: [
          SpeedDialChild(
            backgroundColor: Styles.cardColor,
            child: const Icon(
              Icons.trending_up,
              color: Colors.green,
            ),
            onTap: () {
              _goToNewRevenuePage();
            },
          ),
          SpeedDialChild(
            backgroundColor: Styles.cardColor,
            child: const Icon(
              Icons.trending_down,
              color: Colors.red,
            ),
            onTap: () {
              _goToNewSpendPage();
            },
          ),
        ],
      ),
      floatingActionButtonLocation: _addFabLocation,
      bottomNavigationBar: _buildBottomNavAppBar(),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  BottomAppBar _buildBottomNavAppBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      color: Styles.cardColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.home,
              size: 20,
              color: _selectedIndex == 0 ? Styles.primaryColor : Colors.grey,
            ),
            onPressed: () {
              _onItemTapped(0);
            },
          ),
          const SizedBox(
            width: 24,
            height: 24,
          ),
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.chartPie,
              size: 20,
              color: _selectedIndex == 1 ? Styles.primaryColor : Colors.grey,
            ),
            onPressed: () {
              _onItemTapped(1);
            },
          ),
        ],
      ),
    );
  }
}
