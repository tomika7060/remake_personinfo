import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';


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
  void listAdd (String text){
       stream.add({
      'name': text,
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
              context.read(_listFirebaseProvider).listAdd(context
                  .read(_textControlProvider)
                  .nameController
                  .text);
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
            Navigator.pop(context);
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

  getFirebaseKey() =>
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

class ListFireStore extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Consumer(
        builder: (context,watch,child) {
          return StreamBuilder<QuerySnapshot>(
            stream: watch(_listFirebaseProvider).stream.snapshots(),
              builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot){
              if(snapshot.hasError) return Text('Error: ${snapshot.error}');
              switch (snapshot.connectionState){
                case ConnectionState.waiting:
                  return Text('Loading...');
                default:
                  return ListView(
                    children: snapshot.data.docs.map((DocumentSnapshot document){
                      return Slidable(
                        key: Key(document['name']),
                        dismissal: SlidableDismissal(
                          dragDismissible: false,
                          child: SlidableDrawerDismissal(),
                          dismissThresholds: <SlideActionType, double>{
                            // 右dismissal(スワイプ)をキャンセルする(1.0にセットする)
                            SlideActionType.secondary: 1.0
                          },
                        ),
                        actions: <Widget>[
                          IconSlideAction(
                            caption: 'Delete',
                            color: Colors.red,
                            icon: Icons.delete,
                            onTap: () {
                              alertShow(context,document);
                            },
                          )
                        ],
                        child: ListTile(
                          leading: Icon(Icons.account_circle,
                            size: 45,),
                          title: Text(document['name'],
                            style: TextStyle(
                                fontSize: 22
                            ),),
                          trailing: IconButton(
                            icon: Icon(Icons.arrow_forward_ios,
                              size: 35,),
                            onPressed: (){},
                          ),
                        ),
                        actionPane: SlidableScrollActionPane(),
                      );
                    }).toList()
                  );
              }
              }
        );
        });
  }

  alertShow(context,document){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text('削除しますか?'),
            actions: <Widget>[
              TextButton(
                  onPressed: (){
                    context.read(_listFirebaseProvider).listDelete(document);
                    Navigator.pop(context);
                  },
                  child: Text('はい')
              ),
              TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text('いいえ')
              ),
            ],
          );
        }
    );
  }
}


//とりあえず現状使ってない

final _listProvider =ChangeNotifierProvider(
      (ref) => ListChange(),);

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

