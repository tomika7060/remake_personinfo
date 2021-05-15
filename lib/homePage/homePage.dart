import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:widgetsampule/homePage/homePageModel.dart';
import 'package:widgetsampule/inputPage/inputPage.dart';

class HomePage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ホーム'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout,
              size: 25,
            ),
            onPressed: ()async{
             await FirebaseAuth.instance.signOut();
            },
          )
        ],
      ),
      body: ListFireStore(),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
        ),
        onPressed: (){
          Navigator.push(context,
          MaterialPageRoute(builder: (context) => InputPage())
          );
        },
      ),
    );
  }
}

