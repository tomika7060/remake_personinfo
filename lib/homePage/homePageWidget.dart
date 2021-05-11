import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:widgetsampule/inputPage/inputPageWidget.dart';
import 'package:widgetsampule/personalPage/personalPage.dart';


final _listFirebaseProvider=ChangeNotifierProvider(
      (ref) => ListChangeFirebase(),
);

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
                            key: Key(document['名前']),
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
                              leading: (document['imageUrl'] == '' || document['imageUrl']==null ) ? Icon(Icons.account_circle,
                                size: 45,):ClipOval(
                                  child: Image.network(document['imageUrl'],
                                    fit: BoxFit.fill,
                                    height: 50,
                                    width: 50,
                                  )
                              ),
                              title: Text(document['名前'],
                                style: TextStyle(
                                    fontSize: 22
                                ),),
                              trailing: IconButton(
                                icon: Icon(Icons.arrow_forward_ios,
                                  size: 35,),
                                onPressed: (){
                                  Navigator.push(
                                    context, 
                                    MaterialPageRoute(builder: (context) => PersonalPage(document))
                                  );
                                },
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
                    context.read(_listFirebaseProvider).storageDelete(document['名前']);
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
