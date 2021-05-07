import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetsampule/calender.dart';
import 'package:widgetsampule/homePage.dart';

void main() {
  runApp(
      ProviderScope(
          child:MaterialApp(
             home: MyApp())));
}

final pageTypeProvider =StateProvider<PageType>((ref) => PageType.homePage);

enum PageType {
  homePage,
  Calender,
}

class TabInfo {
  String label;
  Widget widget;
  TabInfo(this.label, this.widget);
}

class MyApp extends StatelessWidget {

  final List<Widget> _pageList = <Widget>[
    HomePage(),
    Calender(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer(
        builder: (context, watch, child) {
          final pageType = watch(pageTypeProvider);
          final tabItems =[
            const BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: '',
            ),
            const BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                label: '',
            )
          ];
          return Scaffold(
            body: _pageList[pageType.state.index],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: pageType.state.index,
              onTap: (index){
                pageType.state=PageType.values[index];
              },
              items: tabItems,
            ),
          );
        }
    );
  }
}
