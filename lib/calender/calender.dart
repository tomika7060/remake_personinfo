import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Calender extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text('カレンダー'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout,
              size: 25,
            ),
            onPressed: (){
              FirebaseAuth.instance.signOut();
            },
          )
        ],
      ),
      body: Container(),
      );

  }
}