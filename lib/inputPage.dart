import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:widgetsampule/Widget.dart';

class InputPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('aaaaa'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          TextForm(),
          AddButton(),
        ],
      )
    );
  }
}