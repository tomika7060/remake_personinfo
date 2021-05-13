import 'package:flutter/material.dart';
import 'package:widgetsampule/logIn/loginWidget.dart';

class MailAuth extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: Column(
        children: [
          EmailSignIn('email'),
          EmailSignIn('pass'),
          EmailSignIn('button'),
        ],
      ),
    );
  }
}