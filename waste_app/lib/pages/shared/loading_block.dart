import 'package:flutter/material.dart';

class LoadingBlock extends StatelessWidget {
  final bool loading;

  LoadingBlock(this.loading);

  @override
  Widget build(BuildContext context) {
    return this.loading
        ? Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            color: Colors.black.withOpacity(0.5),
            child: Container(
              width: 100,
              height: 100,
              alignment: Alignment.center,
              child: Theme(
                data:
                    Theme.of(context).copyWith(accentColor: Colors.deepPurple),
                child: new CircularProgressIndicator(),
              ),
            ),
          )
        : new Container();
  }
}
