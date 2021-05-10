import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _listFirebaseProvider=ChangeNotifierProvider(
      (ref) => ListChangeFirebase(),
);

final _textControlProvider =ChangeNotifierProvider.autoDispose(
    (ref) => TextControl(),
);


class TextForm extends StatelessWidget{
  String category='';
  TextForm(this.category);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context,watch,child) {
        return Column(
          children: [
            Row(
              children:[
                ConstrainedBox(
                  constraints: BoxConstraints.tight(Size(70,70)),
                    child: Text('$category : ')),
                Flexible(
                  child: TextField(
                    controller: watch(_textControlProvider)
                        .getFirebaseKey()[category],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'テキストボックス',
                      hintText: '何か',
                    ),
                  ),
                ),
       ] ),

          ],
        );
      });
  }
}

class TextFormMultiline extends StatelessWidget{
  String category='';
  TextFormMultiline(this.category);

  @override
  Widget build(BuildContext context) {
    return Consumer(
        builder: (context,watch,child) {
          return Column(
            children: [
              Row(
                  children:[
                    ConstrainedBox(
                        constraints: BoxConstraints.tight(Size(70,70)),
                        child: Text('$category : ')),
                    Flexible(
                      child: TextField(
                        controller: watch(_textControlProvider)
                            .getFirebaseKey()[category],
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'テキストボックス',
                          hintText: '何か',
                        ),
                      ),
                    ),
                  ] ),

            ],
          );
        });
  }
}


class ListChangeFirebase extends ChangeNotifier{
  CollectionReference<Map<String, dynamic>> _stream = FirebaseFirestore.instance
      .collection('users').doc('qSPMM3xhfdp3Friamfv7')
      .collection('info');
  CollectionReference<Map<String, dynamic>> get stream =>_stream;

  void nameCheck(String text){
    if(text.isEmpty){
      throw('名前を入力してください');
    }
  }
  void listAdd (Map<String, TextEditingController> map ){

      stream.add({
        '名前':map['名前'].text,
        '所属':map['所属'].text,
        '電話番号':map['電話番号'].text,
        'メールアドレス':map['メールアドレス'].text,
        '趣味':map['趣味'].text,
        'メモ1':map['メモ1'].text,
        'メモ2':map['メモ2'].text,
        'メモ3':map['メモ3'].text,
    });
  }
  void listDelete(document){
    stream.doc(document.id)
        .delete();
  }
}

class AddButton extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context,watch,child){
      return ElevatedButton(
          onPressed:()async{
            try{
              context.read(_listFirebaseProvider).nameCheck(context.read(_textControlProvider).nameController.text);
              context.read(_listFirebaseProvider).listAdd(context.read(_textControlProvider).getFirebaseKey());
              Navigator.pop(context);
            }
            catch(e){
             await showDialog(
                  context: context,
                  builder: (BuildContext context){
                    return AlertDialog(
                      title: Text(e.toString()),
                      actions: <Widget>[
                        TextButton(
                            onPressed: (){
                              Navigator.pop(context);
                            },
                            child: Text('OK')
                        ),
                      ],
                    );
                  }
              );
            }
          },
          child: Text('追加'));}
    );
  }
}


class TextControl extends ChangeNotifier {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController belongsController = TextEditingController();
  final TextEditingController telController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController hobbyController = TextEditingController();
  final TextEditingController memo1Controller = TextEditingController();
  final TextEditingController memo2Controller = TextEditingController();
  final TextEditingController memo3Controller = TextEditingController();

  Map<String ,TextEditingController> getFirebaseKey() =>
      {
        '名前': nameController,
        '所属':belongsController,
        '電話番号':telController,
        'メールアドレス':addressController,
        '趣味':hobbyController,
        'メモ1':memo1Controller,
        'メモ2':memo2Controller,
        'メモ3':memo3Controller,
      };

}



