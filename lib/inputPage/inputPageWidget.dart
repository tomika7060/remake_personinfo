import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final _listFirebaseProvider=ChangeNotifierProvider.autoDispose(
      (ref) => ListChangeFirebase(),
);

final _imageProvider=ChangeNotifierProvider.autoDispose(
      (ref) => ImageFunc(),
);

final _textControlProvider =ChangeNotifierProvider.autoDispose(
    (ref) => TextControl(),
);

String imageUrl;

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
  CollectionReference<Map<String, dynamic>> _stream = FirebaseFirestore.instance
      .collection('users').doc('qSPMM3xhfdp3Friamfv7')
      .collection('info');
  CollectionReference<Map<String, dynamic>> get stream =>_stream;

  void nameCheck(String text){
    if(text.isEmpty){
      throw('名前を入力してください');
    }
  }

  void storageDelete(name)async{
    final storage = FirebaseStorage.instance;
    storage
        .ref()
        .child('users')
        .child('user[qSPMM3xhfdp3Friamfv7]')
        .child(name)
        .delete();
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
        'imageUrl':imageUrl,
        'CreatedAt':Timestamp.now(),
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

//↓画像関係

class ImageForm extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context,watch,child){
      return (watch(_imageProvider)._image == null) ?
      IconButton(
        icon: Icon(Icons.account_circle),
        color: Colors.grey,
        iconSize: 120.0,
        onPressed: () async{
          try {
            watch(_listFirebaseProvider).nameCheck(context.read(_textControlProvider).nameController.text);
            watch(_imageProvider).showBottomSheet(context, context
                .read(_textControlProvider)
                .nameController
                .text);
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
          ClipOval(
            child: GestureDetector(
              onTap: (){
                try {
                  watch(_listFirebaseProvider).nameCheck(context.read(_textControlProvider).nameController.text);
                  watch(_imageProvider).showBottomSheet(context, context
                      .read(_textControlProvider)
                      .nameController
                      .text);
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
          ),
        ],
      );
    }
    );
  }
}



class ImageFunc extends ChangeNotifier{

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
    notifyListeners();
  }

  Future<String> _uploadImage(_image,name) async {
    if ( _image == null) {
      return '';
    }
    else {
      if(name!='') {
        final storage = FirebaseStorage.instance;
        TaskSnapshot snapshot = await storage
            .ref()
            .child('users')
            .child('user[qSPMM3xhfdp3Friamfv7]')
            .child(name)
            .putFile(_image);
        final String downloadUrl = await snapshot.ref.getDownloadURL();
        return downloadUrl;
      }else{
        throw('名前を入力してください');
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
    print(imageUrl);
    notifyListeners();
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

