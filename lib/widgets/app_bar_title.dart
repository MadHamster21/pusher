import 'package:flutter/material.dart'
    show
        BuildContext,
        CrossAxisAlignment,
        Image,
        MainAxisSize,
        Row,
        SizedBox,
        StatelessWidget,
        Text,
        TextStyle,
        Widget;
import 'package:pusher/res/custom_colors.dart' show CustomColors;

class AppBarTitle extends StatelessWidget {
  const AppBarTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/firebase_logo.png',
          height: 20,
        ),
        const SizedBox(width: 8),
        const Text(
          'FlutterFire',
          style: TextStyle(
            color: CustomColors.firebaseYellow,
            fontSize: 18,
          ),
        ),
        const Text(
          'Authentication',
          style: TextStyle(
            color: CustomColors.firebaseOrange,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}
