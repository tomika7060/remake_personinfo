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



final _datePickProvider=ChangeNotifierProvider.autoDispose(
      (ref) => DatePickEdit(),
);



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
  String imageUrlEdit;
  String imageUrlEditBusinessCard;
  CollectionReference<Map<String, dynamic>> _stream = FirebaseFirestore.instance
      .collection('users').doc(uid)
      .collection('friends');
  CollectionReference<Map<String, dynamic>> get stream =>_stream;

  File _image;
  File _imageBusinessCard;
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

  Future<String> _uploadImage(File _image,String uuid,int index) async {
    if(index==0){
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
      }}else if(index==1){
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
            .child('BusinessCard')
            .putFile(_image);
        final String downloadUrl = await snapshot.ref.getDownloadURL();
        return downloadUrl;
      }
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

  void showBottomSheet(BuildContext context, uuid,int index) async {
    //ボトムシートから受け取った値によって操作を変える
    final result = await showCupertinoBottomBar(context);
    File imageFile;
    if (result == 0) {
      imageFile = await ImageUploadEdit(ImageSource.camera).getImageFromDevice();
    } else if (result == 1) {
      imageFile = await ImageUploadEdit(ImageSource.gallery).getImageFromDevice();
    }
    if(index==0){
      _image = imageFile;
      imageUrlEdit= await _uploadImage(_image,uuid,index);
      notifyListeners();
    }else if(index==1){
      _imageBusinessCard=imageFile;
      imageUrlEditBusinessCard= await _uploadImage(_imageBusinessCard, uuid, index);
      notifyListeners();
    }
  }


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
    if(imageUrlEdit != null && imageUrlEdit != '' && imageUrlEditBusinessCard != null && imageUrlEditBusinessCard != ''){
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
        'imageUrlBusinessCard':imageUrlEditBusinessCard,
      });
    }else if(imageUrlEdit!=null && imageUrlEdit!='' && imageUrlEditBusinessCard==null && imageUrlEditBusinessCard==''){
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
    }else if(imageUrlEdit==null && imageUrlEdit=='' && imageUrlEditBusinessCard!=null && imageUrlEditBusinessCard!=''){
      stream.doc(id).update({
        '名前':map['名前'].text,
        '所属':map['所属'].text,
        '電話番号':map['電話番号'].text,
        'メールアドレス':map['メールアドレス'].text,
        '趣味':map['趣味'].text,
        'メモ1':map['メモ1'].text,
        'メモ2':map['メモ2'].text,
        'メモ3':map['メモ3'].text,
        'imageUrlBusinessCard':imageUrlEditBusinessCard,
      });
    }else{
      stream.doc(id).update({
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
    return Consumer(builder: (context,watch,child){
      return (watch(_listFirebaseEditProvider)._image == null && imageUrl==null || imageUrl=='') ?
      IconButton(
        icon: Icon(Icons.account_circle),
        color: Colors.grey,
        iconSize: 120.0,
        onPressed: () async{
            watch(_listFirebaseEditProvider).showBottomSheet(context,uid,0);
        },
      )
          : Column(
             children: [
          SizedBox(
            height: 20,
          ),
               (watch(_listFirebaseEditProvider)._image != null ) ? ClipOval(
                      child: GestureDetector(
                        onTap: (){
                         watch(_listFirebaseEditProvider).showBottomSheet(context,uid,0);
                           },
                             child: Image.memory(
                                  watch(_listFirebaseEditProvider)._image.readAsBytesSync(),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.fill,
              ),
            ),
          ):ClipOval(
            child: GestureDetector(
                   onTap: (){
                       watch(_listFirebaseEditProvider).showBottomSheet(context,uid,0);
                   },
                   child: Image.network(
                     imageUrl,
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

class ImageFormEditBusinessCard extends StatelessWidget{
  String imageUrlBusinessCard;
  String uid;
  ImageFormEditBusinessCard(this.imageUrlBusinessCard,this.uid);
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context,watch,child){
      return (watch(_listFirebaseEditProvider)._imageBusinessCard == null && imageUrlBusinessCard==null || imageUrlBusinessCard=='') ?
      IconButton(
        icon: Icon(Icons.account_circle),
        color: Colors.grey,
        iconSize: 120.0,
        onPressed: () async{
            watch(_listFirebaseEditProvider).showBottomSheet(context,uid,1);
        },
      )
          : Column(
           children: [
            SizedBox(
            height: 20,
            ),
             (watch(_listFirebaseEditProvider)._imageBusinessCard != null ) ? GestureDetector(
              onTap: (){
               watch(_listFirebaseEditProvider).showBottomSheet(context,uid,1);
              },
              child: Image.memory(
             watch(_listFirebaseEditProvider)._imageBusinessCard.readAsBytesSync(),
             width: 100,
             height: 100,
             fit: BoxFit.fill,
              ),
            ):GestureDetector(
              onTap: (){
              watch(_listFirebaseEditProvider).showBottomSheet(context,uid,1);
              },
              child: Image.network(
              imageUrlBusinessCard,
              width: 100,
              height: 100,
              fit: BoxFit.fill,
              ),
            )
        ],
      );
    }
    );
  }
}
class ImageTabEdit extends StatefulWidget{
  String imageUrl;
  String imageUrlBusinessCard;
  String uid;
  ImageTabEdit(this.imageUrl,this.imageUrlBusinessCard,this.uid);
  @override
  _ImageTabEdit createState()=>_ImageTabEdit(imageUrl,imageUrlBusinessCard,uid);

}

class _ImageTabEdit extends State<ImageTabEdit> with TickerProviderStateMixin{
  String imageUrl;
  String imageUrlBusinessCard;
  String uid;
  _ImageTabEdit(this.imageUrl,this.imageUrlBusinessCard,this.uid);

  final List<Tab> tabs = <Tab>[
    Tab(
      text: 'アイコン',
    ),
    Tab(
      text: "名刺",
    ),
  ];

  TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }


  @override
  Widget build(BuildContext context) {
    return Consumer(
        builder: (context,watch,child){
          return SingleChildScrollView(
            child: Column(
              children: [
                TabBar(
                  tabs: tabs,
                  unselectedLabelColor: Colors.grey,
                  controller: _tabController,
                  indicatorColor: Colors.blue,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorWeight: 2,
                  indicatorPadding: EdgeInsets.symmetric(horizontal: 18.0,
                      vertical: 8),
                  labelColor: Colors.black,
                ),
                LimitedBox(
                  maxHeight: 170,
                  child: TabBarView(
                      controller: _tabController,
                      children:[
                        ImageFormEdit(imageUrl, uid),
                        ImageFormEditBusinessCard(imageUrlBusinessCard, uid),
                      ]
                  ),
                ),
              ],
            ),
          );
        });
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
