import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
  File _imageBusinessCard;
  String imageName;
  String imageUrl;
  String imageUrlBusinessCard;
  final picker = ImagePicker();
  var uuid=Uuid().v4();

  CollectionReference<Map<String, dynamic>> _stream = FirebaseFirestore.instance
      .collection('users').doc(uid)
      .collection('friends');
  CollectionReference<Map<String, dynamic>> get stream =>_stream;

  void calenderDelete(document){
      print(document.id);
      stream.doc(uuid).collection('Calender').doc(document.id).delete();
      notifyListeners();
  }


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

  void storageDelete(uuid,int index)async{
    List<String> category=['icon','BusinessCard'];
    final storage = FirebaseStorage.instance;
    storage
        .ref()
        .child('users')
        .child('user[$uid]')
        .child(uuid)
        .child(category[index])
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
        'imageUrlBusinessCard':(imageUrlBusinessCard==null) ? '':imageUrlBusinessCard,
        'CreatedAt':Timestamp.now(),
        'uuid':uuid,
    });
  }
  void listDelete(document){
    print(document.id);
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

  Future<String> _uploadImage(File _image,int index) async {
    if(index==1) {
      if (_image == null) {
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
    }else if(index==2){
      if (_image == null) {
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
    return '';
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

  void showBottomSheet(BuildContext context,int index) async {
    //ボトムシートから受け取った値によって操作を変える
    final result = await showCupertinoBottomBar(context);
    File imageFile;
    if (result == 0) {
      imageFile = await ImageUpload(ImageSource.camera).getImageFromDevice();
    } else if (result == 1) {
      imageFile = await ImageUpload(ImageSource.gallery).getImageFromDevice();
    }
    if(index==1){
    _image = imageFile;
    imageUrl= await _uploadImage(_image,1);
    notifyListeners();
    }
    else if(index==2){
      _imageBusinessCard = imageFile;
      imageUrlBusinessCard= await _uploadImage(_imageBusinessCard,2);
      notifyListeners();
    }
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
class ImageTab extends StatefulWidget{
  @override
  _ImageTab createState()=>_ImageTab();

}

class _ImageTab extends State<ImageTab> with TickerProviderStateMixin{

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
                        ImageForm(),
                        ImageFormBusiness()
                      ]
                  ),
                ),
              ],
            ),
          );
        });
  }
}

class ImageForm extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context,watch,child){
      return Column(
       children:[
         (watch(_listFirebaseProvider)._image == null) ?
      IconButton(
      icon: Icon(Icons.account_circle),
      color: Colors.grey,
      iconSize: 120.0,
      onPressed: () async{
          watch(_listFirebaseProvider).showBottomSheet(context,1);
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
                watch(_listFirebaseProvider).showBottomSheet(context,1);
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
      ),
      const SizedBox(height: 10,),
          Text("プロフィール",
      style: TextStyle(
      fontWeight: FontWeight.bold,
      ),)
       ]
      );
    }
    );
  }
}

class ImageFormBusiness extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context,watch,child){
      return Column(
      children:[
        (watch(_listFirebaseProvider)._imageBusinessCard == null) ?
      IconButton(
        icon: Icon(Icons.account_box_sharp),
        color: Colors.grey,
        iconSize: 120.0,
        onPressed: () async{
          watch(_listFirebaseProvider).showBottomSheet(context,2);
        },
      )
          : Column(
           children: [
            SizedBox(
            height: 20,
          ),
            GestureDetector(
              onTap: (){
                  watch(_listFirebaseProvider).showBottomSheet(context,2);
              },
              child: Image.memory(
                watch(_listFirebaseProvider)._imageBusinessCard.readAsBytesSync(),
                width: 150,
                height: 100,
                fit: BoxFit.fill,
              ),
            ),
        ],
      ),

          const SizedBox(height: 10,),
           Text("名刺",
               style: TextStyle(
               fontWeight: FontWeight.bold,
               )) ]
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
                         return Slidable(
                           key: Key(document['内容']),
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
                           child: Card(
                             child: ListTile(
                               leading: Text(DateFormat('yyyy/MM/dd').format(document['日付'].toDate())),
                               title: Text(document['内容']),
                             ),
                           ),
                           actionPane: SlidableScrollActionPane(),
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
  alertShow(BuildContext context,DocumentSnapshot document){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text('削除しますか?'),
            actions: <Widget>[
              TextButton(
                  onPressed: (){
                    context.read(_listFirebaseProvider).calenderDelete(document);
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

