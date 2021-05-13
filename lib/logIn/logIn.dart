import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:widgetsampule/logIn/signIn.dart';
import 'package:widgetsampule/logIn/signUp.dart';

class AuthScreen extends StatelessWidget {
  static final facebookLogin = FacebookLogin();
  final _form = GlobalKey<FormState>();
  String _email;
  String _password;
  bool _isLogin = false;

  void facebookLogIn() async {
    final result = await facebookLogin.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final credential = FacebookAuthProvider.credential(
            result.accessToken.token
        );
        final authResult =
        await FirebaseAuth.instance.signInWithCredential(credential);
        print(authResult.user.uid);
        break;
      case FacebookLoginStatus.error:
        print('error, ${result.errorMessage}');
        break;
      case FacebookLoginStatus.cancelledByUser:
        print('cancelled');
        break;
    }
  }
  Future<void> trySubmit() async {
    if (!_form.currentState.validate()) {
      return;
    }
    _form.currentState.save();
    final auth = FirebaseAuth.instance;
    if (_isLogin) {
      final result = await auth.signInWithEmailAndPassword(email: _email, password: _password);
      print(result.user.uid);
    } else {
      final result = await auth.createUserWithEmailAndPassword(email: _email, password: _password);
      print(result.user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Authentication'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: facebookLogIn,
              child: Text('Facebookでログイン'),
            ),
            ElevatedButton(
              onPressed: (){
                Navigator.push(context,
                    MaterialPageRoute(builder: (context)=>
                        MailAuth())
                );
              },
              child: Text('メールアドレスでログイン'),
            ),
            ElevatedButton(
              onPressed: (){
                Navigator.push(context,
                    MaterialPageRoute(builder: (context)=>
                        AccountCreate())
                );
              },
              child: Text('メールアドレスでアカウントを作成'),
            ),
          ],
        ),
      ),
    );
  }
}