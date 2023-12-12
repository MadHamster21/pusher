import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart'
    show
        AlwaysStoppedAnimation,
        AssetImage,
        BorderRadius,
        BuildContext,
        ButtonStyle,
        CircularProgressIndicator,
        Color,
        Colors,
        EdgeInsets,
        FontWeight,
        Image,
        MainAxisAlignment,
        MainAxisSize,
        MaterialPageRoute,
        MaterialStateProperty,
        Navigator,
        OutlinedButton,
        Padding,
        RoundedRectangleBorder,
        Row,
        State,
        StatefulWidget,
        Text,
        TextStyle,
        Widget;
import 'package:pusher/screens/pusher_home_page.dart' show PusherHomePage;
import 'package:pusher/auth/authentication.dart' show Authentication;

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({super.key});

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: _isSigningIn
          ? const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
          : OutlinedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),
              onPressed: () async {
                setState(() {
                  _isSigningIn = true;
                });
                User? user =
                    await Authentication.signInWithGoogle(context: context);

                setState(() {
                  _isSigningIn = false;
                });

                if (user != null && context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => PusherHomePage(
                        title: "Signed in as ${user.email}!",
                      ),
                    ),
                  );
                }
              },
              child: const Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image(
                      image: AssetImage("assets/google_logo.png"),
                      height: 35.0,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        'Sign in with Google',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
