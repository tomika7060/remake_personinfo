import 'package:flutter/material.dart';
import 'package:widgetsampule/Widget.dart';
import 'package:widgetsampule/inputPage.dart';



class HomePage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('aaaaa'),
      ),
      body: ListDisplay(),
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

