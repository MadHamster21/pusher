import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart'
    show
        AlwaysStoppedAnimation,
        AppBar,
        BuildContext,
        Center,
        CircularProgressIndicator,
        Color,
        Column,
        ConnectionState,
        FloatingActionButton,
        FutureBuilder,
        Icon,
        Icons,
        MainAxisAlignment,
        Scaffold,
        State,
        StatefulWidget,
        Text,
        Theme,
        Widget;
import 'package:awesome_notifications/awesome_notifications.dart'
    show AwesomeNotifications, NotificationContent;
import 'package:flutter/services.dart' show Color, MethodChannel;
import 'package:pusher/res/custom_colors.dart' show CustomColors;
import 'package:pusher/auth/authentication.dart' show Authentication;
import 'package:pusher/widgets/google_sign_in_button.dart'
    show GoogleSignInButton;

class PusherHomePage extends StatefulWidget {
  const PusherHomePage({super.key, required this.title});

  final String title;

  @override
  State<PusherHomePage> createState() => _PusherHomePageState();
}

class _PusherHomePageState extends State<PusherHomePage> {
  int _counter = 0;
  int _pushUpsCount = 0;
  var platform = const MethodChannel('health_api_channel');

  void showNotification() {
    readPushUpsForToday();
    setState(() {
      _counter++;
    });
    AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: 10,
            channelKey: 'basic_channel',
            title:
                (_counter > 1) ? 'Pressed plus again??' : 'Pressed the button',
            body:
                'Did you know you pressed the button $_counter times already??'));
  }

  Future<void> readPushUpsForToday() async {
    try {
      int? todayPushUps = await platform.invokeMethod('getTodayPushUpsCount');
      _pushUpsCount = todayPushUps ?? 0;
    } catch (e) {
      print('Error calling native getTodayPushUpsCount method: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter (Kotlin says $_pushUpsCount)',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            FutureBuilder(
              future: Authentication.initializeFirebase(context: context),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Error initializing Firebase');
                } else if (snapshot.connectionState == ConnectionState.done) {
                  if (FirebaseAuth.instance.currentUser != null) {
                    return Text('User is signed in! Email: '
                        '${FirebaseAuth.instance.currentUser!.email}');
                  } else {
                    return const GoogleSignInButton();
                  }
                }
                return const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    CustomColors.firebaseOrange,
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showNotification,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
