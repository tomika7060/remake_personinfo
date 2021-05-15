import 'package:flutter/material.dart';
import 'package:widgetsampule/personalPage/personalPageModel.dart';

class PersonalPage extends StatelessWidget{
  final document;
  PersonalPage(this.document);
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text('個人ページ'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ImageFormEdit(document['imageUrl'],document['uuid']),
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
                    TextFormEdit(document,'名前'),
                    TextFormEdit(document,'所属'),
                    TextFormEdit(document,'電話番号'),
                    TextFormEdit(document,'メールアドレス'),
                    TextFormEdit(document,'趣味'),
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
                  TextFormMultilineEdit(document,'メモ1'),
                  TextFormMultilineEdit(document,'メモ2'),
                  TextFormMultilineEdit(document,'メモ3'),
                ],
              ),
            ),
            Text('予定'),
            Card(
              child: CalenderListEdit(document['uuid']),
            ),
            Card(
              child: Column(
                children: [
                  DatePickerEdit(),
                  Text('予定や過去の出来事を入力してください'),
                  CalenderTextBoxEdit(),
                  SizedBox(height: 5,),
                  CalenderAddButtonEdit(document['uuid']),
                  SizedBox(height: 5,),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            AddButtonEdit(document.id),
          ],
        ),
      )
    );
  }
}