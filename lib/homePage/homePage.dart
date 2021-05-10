import 'package:flutter/material.dart';
import 'package:widgetsampule/homePage/homePageWidget.dart';
import 'package:widgetsampule/inputPage/inputPage.dart';




class HomePage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ホーム'),
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

