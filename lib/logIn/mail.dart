import 'package:flutter/material.dart';
import 'package:widgetsampule/logIn/loginWidget.dart';


class AccountCreate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ログインページ'),
      ),
      body: Column(
        children: [
          EmailSignUp('email'),
          EmailSignUp('pass'),
          EmailSignUp('passCheck',),
          EmailSignUp('button'),
        ],
      )
    );
  }

}

class MailAuth extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}