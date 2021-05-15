import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:widgetsampule/homePage/home.dart';
import 'package:widgetsampule/inputPage/inputPageModel.dart';

final _listFirebaseProvider=ChangeNotifierProvider.autoDispose(
      (ref) => ListChangeFirebase(),
);

final _listFirebaseEditProvider=ChangeNotifierProvider(
      (ref) => ListChangeFirebaseEdit(),
);

final _textControlEditProvider =ChangeNotifierProvider.autoDispose(
      (ref) => TextControlEdit(),
);

final _imageProvider=ChangeNotifierProvider.autoDispose(
      (ref) => ImageFuncEdit(),
);

final _datePickProvider=ChangeNotifierProvider.autoDispose(
      (ref) => DatePickEdit(),
);


String imageUrlEdit;


class TextFormEdit extends StatelessWidget{
  DocumentSnapshot<Object> document;
  String category;
  TextFormEdit(this.document,this.category);
  @override
  Widget build(BuildContext context) {
    //ここでテキストコントローラーに初期値を渡している
    context.read(_textControlEditProvider).getFirebaseKey()[category].text=document[category];
    return Consumer(
        builder: (context,watch,child) {
          return Column(
            children: [
              Row(
                  children:[
                    ConstrainedBox(
                        constraints: BoxConstraints.tight(Size(70,70)),
                        child: Center(child: Text('$category : ',
                        style: TextStyle(
                          fontSize: 15,
                        ),))),
                    Flexible(
                      child: TextField(
                        controller: watch(_textControlEditProvider)
                            .getFirebaseKey()[category],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ] ),
            ],
          );
        });
  }
}

class TextFormMultilineEdit extends StatelessWidget{
  DocumentSnapshot<Object> document;
  String category;
  TextFormMultilineEdit(this.document,this.category);

  @override
  Widget build(BuildContext context) {
    context.read(_textControlEditProvider).getFirebaseKey()[category].text=document[category];
    return Consumer(
        builder: (context,watch,child) {
          return Column(
            children: [
              Row(
                  children:[
                    ConstrainedBox(
                        constraints: BoxConstraints.tight(Size(70,70)),
                        child: Center(
                            child: Text('$category : ',
                            style: TextStyle(
                            fontSize: 15,
                            ),))),
                    Flexible(
                      child: TextField(
                        controller: watch(_textControlEditProvider)
                            .getFirebaseKey()[category],
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ] ),
            ],
          );
        });
  }
}


class ListChangeFirebaseEdit extends ChangeNotifier{
  CollectionReference<Map<String, dynamic>> _stream = FirebaseFirestore.instance
      .collection('users').doc(uid)
      .collection('friends');
  CollectionReference<Map<String, dynamic>> get stream =>_stream;


  void calenderAddEdit(DateTime date,String content,String uuid){
    if(content==''){
      throw('内容が書かれていません');
    }
    stream.doc(uuid).collection('Calender').add({
      'CreateAt':DateTime.now(),
      '日付':date,
      '内容':content,
    });
  }

  void nameCheck(String text){
    if(text.isEmpty){
      throw('名前を入力してください');
    }
  }
  void listUpdate(String id,Map<String, TextEditingController> map ){

    stream.doc(id).update({
      '名前':map['名前'].text,
      '所属':map['所属'].text,
      '電話番号':map['電話番号'].text,
      'メールアドレス':map['メールアドレス'].text,
      '趣味':map['趣味'].text,
      'メモ1':map['メモ1'].text,
      'メモ2':map['メモ2'].text,
      'メモ3':map['メモ3'].text,
      'imageUrl':imageUrlEdit,
    });
  }
}

class AddButtonEdit extends StatelessWidget{
  String id;
  AddButtonEdit(this.id);
  @override
  Widget build(BuildContext context) {
    return Consumer(
        builder: (context,watch,child){
          return ElevatedButton(
              onPressed:()async{
                try{
                  context.read(_listFirebaseEditProvider).nameCheck(context.read(_textControlEditProvider).nameController.text);
                  context.read(_listFirebaseEditProvider).listUpdate(id,context.read(_textControlEditProvider).getFirebaseKey());

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
              child: Text('保存して戻る'));}
    );
  }
}

class TextControlEdit extends ChangeNotifier {
  String text;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController belongsController = TextEditingController();
  final TextEditingController telController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController hobbyController = TextEditingController();
  final TextEditingController memo1Controller = TextEditingController();
  final TextEditingController memo2Controller = TextEditingController();
  final TextEditingController memo3Controller = TextEditingController();
  final TextEditingController calenderContentController = TextEditingController();

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
        '内容':calenderContentController,
      };

  void contentDispose(){
    calenderContentController.text='';
    notifyListeners();
  }
}



//↓画像関係

class ImageFormEdit extends StatelessWidget{
  String imageUrl;
  String uid;
  ImageFormEdit(this.imageUrl,this.uid);
  @override
  Widget build(BuildContext context) {
    imageUrlEdit=imageUrl;
    return Consumer(builder: (context,watch,child){
      return (watch(_imageProvider)._image == null && imageUrlEdit==null || imageUrlEdit=='') ?
      IconButton(
        icon: Icon(Icons.account_circle),
        color: Colors.grey,
        iconSize: 120.0,
        onPressed: () async{
          try {
            watch(_listFirebaseEditProvider).nameCheck(context.read(_textControlEditProvider).nameController.text);
            watch(_imageProvider).showBottomSheet(context,uid);
          }catch(e){
            watch(_imageProvider).alertFunc(context, e);
          }
        },
      )
          : Column(
             children: [
          SizedBox(
            height: 20,
          ),
               (watch(_imageProvider)._image != null ) ? ClipOval(
                      child: GestureDetector(
                        onTap: (){
                         try {
                         watch(_listFirebaseEditProvider).nameCheck(context.read(_textControlEditProvider).nameController.text);
                         watch(_imageProvider).showBottomSheet(context,context.read(_listFirebaseEditProvider).stream);
                        }catch(e){
                             watch(_imageProvider).alertFunc(context,e);
                             }
                           },
                             child: Image.memory(
                                  watch(_imageProvider)._image.readAsBytesSync(),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.fill,
              ),
            ),
          ):ClipOval(
            child: GestureDetector(
                   onTap: (){
                       watch(_imageProvider).showBottomSheet(context,uid);
                   },
                   child: Image.network(
                     imageUrlEdit,
                     width: 100,
                     height: 100,
                     fit: BoxFit.fill,
                   ),
                 ),
          )
        ],
      );
    }
    );
  }
}



class ImageFuncEdit extends ChangeNotifier{

  File _image;
  String imageName;
  final picker = ImagePicker();

  dynamic alertFunc(context,e){
    showDialog(
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

  Future<String> _uploadImage(_image,uuid) async {
    if ( _image == null) {
      return '';
    }
    else {
        final storage = FirebaseStorage.instance;
        TaskSnapshot snapshot = await storage
            .ref()
            .child('users')
            .child('user[$uid]')
            .child(uuid)
            .child('icon')
            .putFile(_image);
        final String downloadUrl = await snapshot.ref.getDownloadURL();
        return downloadUrl;
      }
      }




  Future<int> showCupertinoBottomBar(context) {
    //選択するためのボトムシートを表示
    return showCupertinoModalPopup<int>(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            message: Text('写真をアップロードしますか？'),
            actions: <Widget>[
              CupertinoActionSheetAction(
                child: Text(
                  'カメラで撮影',
                ),
                onPressed: () {
                  Navigator.pop(context, 0);
                },
              ),
              CupertinoActionSheetAction(
                child: Text(
                  'アルバムから選択',
                ),
                onPressed: () {
                  Navigator.pop(context, 1);
                },
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              child: const Text('キャンセル'),
              onPressed: () {
                Navigator.pop(context, 2);
              },
              isDefaultAction: true,
            ),
          );
        }
    );
  }

  void showBottomSheet(context,uuid) async {
    //ボトムシートから受け取った値によって操作を変える
    final result = await showCupertinoBottomBar(context);
    File imageFile;
    if (result == 0) {
      imageFile = await ImageUploadEdit(ImageSource.camera).getImageFromDevice();
    } else if (result == 1) {
      imageFile = await ImageUploadEdit(ImageSource.gallery).getImageFromDevice();
    }
    _image = imageFile;
    imageUrlEdit= await _uploadImage(_image,uuid);
    notifyListeners();
  }
}

class ImageUploadEdit {
  ImageUploadEdit(this.inputSource, {this.inputQuality = 50});
  final ImageSource inputSource;
  final int inputQuality;
  Future<File> getImageFromDevice() async {
    // 撮影/選択したFileが返ってくる
    final imageInputFile = await ImagePicker().getImage(source: inputSource);
    // Androidで撮影せずに閉じた場合はnullになる
    if (imageInputFile == null) {
      return null;
    }
    //画像を圧縮
    final File compressedFile = await FlutterNativeImage.compressImage(
        imageInputFile.path,
        quality: inputQuality);
    return compressedFile;
  }
}

//↑画像関係

class CalenderListEdit extends StatelessWidget{
  String uuid;
  CalenderListEdit(this.uuid);
  @override
  Widget build(BuildContext context) {
    return Consumer(
        builder: (context,watch,child){
          return StreamBuilder<QuerySnapshot>(
              stream: watch(_listFirebaseEditProvider).stream.doc(uuid).collection('Calender').snapshots(),
              builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot){
                if(snapshot.hasError) return Text('Error: ${snapshot.error}');
                switch (snapshot.connectionState){
                  case ConnectionState.waiting:
                    return Text('Loading...');
                  default:
                    return ListView(
                        shrinkWrap: true,
                        children: snapshot.data.docs.map((DocumentSnapshot document){
                          return Card(
                            child: ListTile(
                              leading: Text(DateFormat('yyyy/MM/dd').format(document['日付'].toDate())),
                              title: Text(document['内容']),
                            ),
                          );
                        }
                        ).toList()
                    );
                }
              }
          );
        }
    );
  }
}
class CalenderAddButtonEdit extends StatelessWidget{
  String uid;
  CalenderAddButtonEdit(this.uid);
  @override
  Widget build(BuildContext context) {
    return Consumer(
        builder: (context,watch,child){
          return ElevatedButton(
              onPressed:(){
                try{
                  context.read(_listFirebaseEditProvider).calenderAddEdit(
                    context.read(_datePickProvider).dateValue,
                    context.read(_textControlEditProvider).calenderContentController.text,
                    uid
                  );
                  context.read(_textControlEditProvider).contentDispose();
                }
                catch(e){
                  context.read(_listFirebaseProvider).alertFunc(context, e);
                }
              },
              child: Text('追加'));}
    );
  }
}

class CalenderTextBoxEdit extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Consumer(
        builder: (context,watch,child) {
          return Row(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints.tight(Size(20,70)),
              ),
              Flexible(
                child: TextField(
                  controller: watch(_textControlEditProvider)
                      .getFirebaseKey()['内容'],
                  decoration: InputDecoration(
                    labelText: '内容',
                  ),
                ),
              ),
            ],
          );
        });
  }
}

class DatePickerEdit extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Consumer(
        builder: (context,watch,child) {
          return  Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(DateFormat('yyyy/ MM/dd').format(watch(_datePickProvider).dateValue),
                style: TextStyle(
                  color: CupertinoColors.black,
                  fontSize: 22.0,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  //datePicker表示
                  watch(_datePickProvider).showCupercinoDatePicker(context);
                },
                child: Text('日付選択'),
              ),
            ],
          );
        } );
  }
}

class DatePickEdit extends ChangeNotifier{
  DateTime dateValue=DateTime.now();
  void showCupercinoDatePicker(context){
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context){
          return Column(
              mainAxisAlignment:
              MainAxisAlignment.end,
              children: <Widget>[
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 0.0,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,
                            children: <Widget>[
                              /// クパチーノデザインのボタン表示
                              CupertinoButton(
                                child: Text('キャンセル'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                padding: const EdgeInsets
                                    .symmetric(
                                  horizontal: 16.0,
                                  vertical: 5.0,
                                ),
                              ),
                              CupertinoButton(
                                child: Text('追加'),
                                onPressed: () {
                                  print(dateValue);
                                  notifyListeners();
                                  Navigator.pop(context);
                                },
                                padding: const EdgeInsets
                                    .symmetric(
                                  horizontal: 16.0,
                                  vertical: 5.0,
                                ),
                              )
                            ],
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height / 3,
                            child: CupertinoDatePicker(
                              /// datePickerを日付のみの表示にする
                              initialDateTime: DateTime.now(),
                              onDateTimeChanged:
                                  (DateTime newDateTime) {
                                //日付が変わった時の処理
                                dateValue=newDateTime;
                              },
                              mode: CupertinoDatePickerMode.date,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ]
          );
        }
    );
  }
}
