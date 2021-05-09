import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final _listProvider =ChangeNotifierProvider(
      (ref) => ListChange(),);

final _textControlProvider =ChangeNotifierProvider.autoDispose(
    (ref) => TextControl(),
);


class TextForm extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context,watch,child) {
        return TextField(
          controller: watch(_textControlProvider)
              .myController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'テキストボックス',
            hintText: '何か',
          ),
        );
      });
  }
}

class AddButton extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed:(){
          context.read(_listProvider).listAdd(context.read(_textControlProvider).myController.text);
          Navigator.pop(context);
        },
        child: Text('追加'));
  }
}

class ListDisplay extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Consumer(
        builder: (context,watch,child) {
          return ListView.builder(
              itemCount: watch(_listProvider).listItems.length,
              itemBuilder: (context,index){
                return ListTile(
                    leading: Icon(Icons.account_circle,
                    size: 45,),
                    title: Text(watch(_listProvider).listItems[index],
                    style: TextStyle(
                      fontSize: 22
                    ),
                    ),
                  trailing: IconButton(
                    icon: Icon(Icons.arrow_forward_ios,
                    size: 35,),
                    onPressed: (){
                      //todo
                    },
                  ),
                );
              }
          );
        } );
  }
}

class ListChange extends ChangeNotifier{

  var _listItems = ["aaaaa"];

  List get listItems => _listItems;

  void listAdd(String text){
    //firebaseに書き込む処理に今後変更
    _listItems.add(text);
    notifyListeners();
  }
  void listDelete(){}
}

class TextControl extends ChangeNotifier{

  final _myController =TextEditingController();
  TextEditingController get myController => _myController;
}

class ListFireStore extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Consumer(
        builder: (context,watch,child) {
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
              .collection('users').doc('qSPMM3xhfdp3Friamfv7')
              .collection('info')
              .snapshots(),
              builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot){
              if(snapshot.hasError) return Text('Error: ${snapshot.error}');
              switch (snapshot.connectionState){
                case ConnectionState.waiting:
                  return Text('Loading...');
                default:
                  return ListView(
                    children: snapshot.data.docs.map((DocumentSnapshot document){
                      return ListTile(
                        title: Text(document['name']),
                      );
                    }).toList()
                  );
              }
              }
        );
        });
  }
}




