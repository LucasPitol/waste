import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:waste_app/models/dtos/plan_specs_dto.dart';
import 'package:waste_app/pages/shared/loading_widget.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/models/user_dto.dart';
import 'package:flutter/material.dart';
import 'package:waste_app/services/plans_service.dart';
import 'package:waste_app/utils/styles.dart';

class PlansCarouselComponent extends StatefulWidget {
  @override
  _PlansCarouselComponentState createState() => _PlansCarouselComponentState();
}

class _PlansCarouselComponentState extends State<PlansCarouselComponent> {
  PageController _pageViewController = PageController(
    initialPage: 0,
  );
  UserDto userDto = AuthService.currentUser;
  List<PlanSpecsDto> plans;
  bool loadingPlans;
  PlansService _plansService;

  _PlansCarouselComponentState() {
    this.plans = [];
    this.loadingPlans = true;
    this._plansService = PlansService();
  }

  void initState() {
    super.initState();
    this._getPlans();
  }

  _getPlans() {
    setState(() {
      this.loadingPlans = true;
    });

    this._plansService.getPlans().then((value) {
      if (value == null) {
        // tratar server erro
      } else {
        if (value.success) {
          this.plans = value.data;
        } else {
          // tratar erro
        }
      }

      setState(() {
        this.loadingPlans = false;
      });
    });
  }

  Widget createDescriptionTile(String desc) {
    String value = '• ' + desc;

    return Text(
      value,
      style: Styles.poppinsTextGrey,
    );
  }

  Widget createCard(PlanSpecsDto item) {
    var margin = EdgeInsets.symmetric(horizontal: 15);

    return Container(
      margin: margin,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: Styles.contentBox,
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: Text(
              item.name,
              style: Styles.montTextTitle,
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(top: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: item.descriptionList
                  .map((e) => createDescriptionTile(e))
                  .toList(),
            ),
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.displayPrice,
                  style: Styles.poppinsText,
                ),
                TextButton(
                  onPressed: () {
                    print('Conhecer');
                  },
                  style: Styles.textButtonStyle,
                  child: Text('Conhecer'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return loadingPlans
        ? LoadingWidget()
        : Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 20),
                width: double.infinity,
                height: 200,
                child: PageView(
                  controller: this._pageViewController,
                  scrollDirection: Axis.horizontal,
                  children: plans.map((item) => createCard(item)).toList(),
                ),
              ),
              Container(
                child: SmoothPageIndicator(
                  controller: _pageViewController,
                  count: plans.length,
                  axisDirection: Axis.horizontal,
                  onDotClicked: (i) {
                    _pageViewController.animateToPage(
                      i,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.ease,
                    );
                  },
                  effect: WormEffect(
                    // expansionFactor: 2,
                    spacing: 8,
                    radius: 16,
                    dotWidth: 12,
                    dotHeight: 12,
                    // dotColor: Color(0xFF1A1A1B),
                    dotColor: Colors.grey.shade900,
                    activeDotColor: Styles.primaryColor,
                    paintStyle: PaintingStyle.fill,
                  ),
                ),
              ),
            ],
          );
  }
}
