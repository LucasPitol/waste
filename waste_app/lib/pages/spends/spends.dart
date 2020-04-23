import 'package:flutter/material.dart';

class SpendsComponent extends StatefulWidget {
  @override
  _SpendsComponentState createState() => _SpendsComponentState();
}

class _SpendsComponentState extends State<SpendsComponent>
    with TickerProviderStateMixin {
  bool headerExpanded = false;
  double appbarHeight = 80.0;
  double menuHeight = 0.0;

  Animation<double> openAnimation, closeAnimation;
  AnimationController openController, closeController;

  void initState() {
    super.initState();
    openController = AnimationController(
      duration: const Duration(
        milliseconds: 200,
      ),
      vsync: this,
    );
    closeController = AnimationController(
      duration: const Duration(
        milliseconds: 200,
      ),
      vsync: this,
    );
    openAnimation = Tween(begin: 0.0, end: 1.0).animate(openController)
      ..addListener(() {
        setState(() {
          menuHeight = openAnimation.value;
        });
      });
    closeAnimation = Tween(begin: 1.0, end: 0.0).animate(closeController)
      ..addListener(
        () {
          setState(() {
            menuHeight = closeAnimation.value;
          });
        },
      );
  }

  _handleHeaderPress() {
    setState(() {
      openController.reset();
      closeController.reset();
      headerExpanded = !headerExpanded;
      headerExpanded ? openController.forward() : closeController.forward();
    });
  }

  @override
  void dispose() {
    openController.dispose();
    closeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            GestureDetector(
              onTap: _handleHeaderPress,
              child: Container(
                color: Colors.deepPurple,
                height: menuHeight,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      width: double.infinity,
                      height: 10.0,
                    ),
                    Stack(
                      children: <Widget>[
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(left: 30, top: 10),
                          child: Text(
                            'Junho',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          margin: EdgeInsets.only(right: 30, top: 10),
                          child: Text(
                            '130,00',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 18.0,
                            ),
                          ),
                          // child: IconButton(
                          //   icon: Icon(
                          //       headerExpanded ? Icons.cancel : Icons.menu),
                          //   color: Colors.white,
                          //   onPressed: _handleHeaderPress,
                          // ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Expanded(
                      child: ListView(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(bottom: 20),
                            alignment: Alignment.center,
                            child: Text(
                              "Procurar vizinho",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(bottom: 20),
                            alignment: Alignment.center,
                            child: Text(
                              "Horário da van",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(bottom: 20),
                            alignment: Alignment.center,
                            child: GestureDetector(
                              onTap: () {
                                print('evidenciei');
                              },
                              child: Text(
                                "Conversas",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(bottom: 20),
                            alignment: Alignment.center,
                            child: Text(
                              "Reuniões",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(bottom: 20),
                            alignment: Alignment.center,
                            child: Text(
                              "Ajuda",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  margin: EdgeInsets.only(
                      top: menuHeight * (constraints.maxHeight - 60) + 60),
                  color: Colors.transparent,
                  child: Material(
                    elevation: 16.0,
                    child: Center(
                      child: Text('Gastos'),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
