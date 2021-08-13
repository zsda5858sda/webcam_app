import 'package:flutter/material.dart';

class HomeScreenLogo extends StatelessWidget {
  const HomeScreenLogo({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 150,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.005),
              child: Image.asset(
                'assets/images/UB_LOGO_B.png',
                height: 50.0,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              width: 10.0,
            ),
          ],
        ),
      ],
    );
  }
}
