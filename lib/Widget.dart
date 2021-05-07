import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final _listProvider =ChangeNotifierProvider(
      (ref) => ListAdd(),);

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

class ListAdd extends ChangeNotifier{

  var _listItems = [];

  List get listItems => _listItems;

  void listAdd(String text){
    _listItems.add(text);
    notifyListeners();
  }
}

class TextControl extends ChangeNotifier{

  final _myController =TextEditingController();
  TextEditingController get myController => _myController;

}

