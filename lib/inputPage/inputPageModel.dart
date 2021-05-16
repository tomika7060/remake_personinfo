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
import 'package:uuid/uuid.dart';

final _listFirebaseProvider=ChangeNotifierProvider.autoDispose(
      (ref) => ListChangeFirebase(),
);

final _textControlProvider =ChangeNotifierProvider.autoDispose(
    (ref) => TextControl(),
);

final _datePickProvider=ChangeNotifierProvider.autoDispose(
      (ref) => DatePick(),
);

final tabTypeProvider =StateProvider.autoDispose<TabWidgetType>((ref) => TabWidgetType.ImageForm);

enum TabWidgetType{
  ImageForm,
  ImageFormBusiness,
}

class TabInfo {
  String label;
  Widget widget;
  TabInfo(this.label, this.widget);
}

class TextForm extends StatelessWidget{
  String category;
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
                    child: Center(child: Text('$category : ',
                    style: TextStyle(
                    fontSize: 15,
                         ),))),
                Flexible(
                  child: TextField(
                    autofocus: (category=='名前') ? true:false,
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
                        child: Center(
                            child: Text('$category : ',
                            style: TextStyle(
                            fontSize: 15,
                            ),))),
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
  File _image;
  String imageName;
  String imageUrl;
  final picker = ImagePicker();
  var uuid=Uuid().v4();

  CollectionReference<Map<String, dynamic>> _stream = FirebaseFirestore.instance
      .collection('users').doc(uid)
      .collection('friends');
  CollectionReference<Map<String, dynamic>> get stream =>_stream;


  void calenderAdd(date,content){
    print(uuid);
    stream.doc(uuid).collection('Calender').doc().set({
      'CreateAt':DateTime.now(),
      '日付':date,
      '内容':content,
    });
  }
  void contentsCheck(String content){
    if(content.isEmpty){
      throw('内容が書かれていません');
    }
  }

  void nameCheck(String text){
    if(text.isEmpty){
      throw('名前を入力してください');
    }
  }

  void storageDelete(uuid)async{
    final storage = FirebaseStorage.instance;
    storage
        .ref()
        .child('users')
        .child('user[$uid]')
        .child(uuid)
        .child('icon')
        .delete();
  }


  void listAdd (Map<String, TextEditingController> map ){

      stream.doc(uuid).set({
        '名前':map['名前'].text,
        '所属':map['所属'].text,
        '電話番号':map['電話番号'].text,
        'メールアドレス':map['メールアドレス'].text,
        '趣味':map['趣味'].text,
        'メモ1':map['メモ1'].text,
        'メモ2':map['メモ2'].text,
        'メモ3':map['メモ3'].text,
        'imageUrl':(imageUrl==null) ? '' : imageUrl,
        'CreatedAt':Timestamp.now(),
        'uuid':uuid,
    });
  }
  void listDelete(document){
    stream.doc(document.id)
        .delete();
  }

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

  Future<String> _uploadImage(_image,name) async {
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

  void showBottomSheet(context,name) async {
    //ボトムシートから受け取った値によって操作を変える
    final result = await showCupertinoBottomBar(context);
    File imageFile;
    if (result == 0) {
      imageFile = await ImageUpload(ImageSource.camera).getImageFromDevice();
    } else if (result == 1) {
      imageFile = await ImageUpload(ImageSource.gallery).getImageFromDevice();
    }
    _image = imageFile;
    imageUrl= await _uploadImage(_image,name);
    notifyListeners();
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
          child: Text('保存して戻る'));}
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

class ImageTab extends StatelessWidget{

  final List<Tab> tabs = <Tab>[
    Tab(
      text: 'アイコン',
    ),
    Tab(
      text: "名刺",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer(
        builder: (context,watch,child){
          return Column(
            children: [
              TabBar(
                tabs: tabs,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorWeight: 2,
                indicatorPadding: EdgeInsets.symmetric(horizontal: 18.0,
                    vertical: 8),
                labelColor: Colors.black,
              ),
            ],
          );
        });
  }
}

class ImageForm extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context,watch,child){
      return (watch(_listFirebaseProvider)._image == null) ?
      IconButton(
      icon: Icon(Icons.account_circle),
      color: Colors.grey,
      iconSize: 120.0,
      onPressed: () async{
          watch(_listFirebaseProvider).showBottomSheet(context, context
              .read(_textControlProvider)
              .nameController
              .text);
        },
      )
        : Column(
         children: [
        SizedBox(
          height: 20,
        ),
        ClipOval(
          child: GestureDetector(
            onTap: (){
              try {
                watch(_listFirebaseProvider).nameCheck(context.read(_textControlProvider).nameController.text);
                watch(_listFirebaseProvider).showBottomSheet(context, context
                    .read(_textControlProvider)
                    .nameController
                    .text);
              }catch(e){
                watch(_listFirebaseProvider).alertFunc(context,e);
              }
              },
            child: Image.memory(
              watch(_listFirebaseProvider)._image.readAsBytesSync(),
              width: 100,
              height: 100,
              fit: BoxFit.fill,
            ),
          ),
        ),
      ],
      );
    }
    );
  }
}

class ImageFormBusiness extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context,watch,child){
      return (watch(_listFirebaseProvider)._image == null) ?
      IconButton(
        icon: Icon(Icons.account_circle),
        color: Colors.grey,
        iconSize: 120.0,
        onPressed: () async{
          watch(_listFirebaseProvider).showBottomSheet(context, context
              .read(_textControlProvider)
              .nameController
              .text);
        },
      )
          : Column(
        children: [
          SizedBox(
            height: 20,
          ),
          ClipOval(
            child: GestureDetector(
              onTap: (){
                try {
                  watch(_listFirebaseProvider).nameCheck(context.read(_textControlProvider).nameController.text);
                  watch(_listFirebaseProvider).showBottomSheet(context, context
                      .read(_textControlProvider)
                      .nameController
                      .text);
                }catch(e){
                  watch(_listFirebaseProvider).alertFunc(context,e);
                }
              },
              child: Image.memory(
                watch(_listFirebaseProvider)._image.readAsBytesSync(),
                width: 100,
                height: 100,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ],
      );
    }
    );
  }
}


class ImageUpload {
  ImageUpload(this.inputSource, {this.inputQuality = 50});
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

class DatePicker extends StatelessWidget{
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

class DatePick extends ChangeNotifier{
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

class CalenderList extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
   return Consumer(
       builder: (context,watch,child){
         return StreamBuilder<QuerySnapshot>(
           stream: watch(_listFirebaseProvider).stream.doc(watch(_listFirebaseProvider).uuid).collection('Calender').snapshots(),
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

class CalenderTextBox extends StatelessWidget{
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
                  controller: watch(_textControlProvider)
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

class CalenderAddButton extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Consumer(
        builder: (context,watch,child){
          return ElevatedButton(
              onPressed:(){
                try{
                  context.read(_listFirebaseProvider).contentsCheck(context.read(_textControlProvider).calenderContentController.text);
                  context.read(_listFirebaseProvider).calenderAdd(context.read(_datePickProvider).dateValue,
                  context.read(_textControlProvider).calenderContentController.text,);
                  context.read(_textControlProvider).contentDispose();
                }
                catch(e){
                  context.read(_listFirebaseProvider).alertFunc(context, e);
                }
              },
              child: Text('追加'));}
    );
  }
}

