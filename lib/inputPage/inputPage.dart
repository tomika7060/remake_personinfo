import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:widgetsampule/inputPage/inputPageModel.dart';

class InputPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('入力ページ'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ImageForm(),
            SizedBox(
              height: 20,
            ),
            Text('基本情報'),
            Card(
                child: Column(
                  children: [
                    SizedBox(
                      height: 5,
                    ),
                    TextForm('名前'),
                    TextForm('所属'),
                    TextForm('電話番号'),
                    TextForm('メールアドレス'),
                    TextForm('趣味'),
                  ],
                )
            ),
            SizedBox(
              height: 20,
            ),
            Text('自由'),
            Card(
              child: Column(
                children: [
                  SizedBox(
                    height: 5,
                  ),
                  TextFormMultiline('メモ1'),
                  TextFormMultiline('メモ2'),
                  TextFormMultiline('メモ3'),
                ],
              ),
            ),
            Text('予定'),
            Card(
              child: CalenderList(),
            ),
            Card(
              child: Column(
                children: [
                  DatePicker(),
                  Text('予定や過去の出来事を入力してください'),
                  CalenderTextBox(),
                  CalenderAddButton(),
                ],
              ),
            ),
            AddButton(),
          ],
        ),
      )
    );
  }
}