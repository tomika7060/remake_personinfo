import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:widgetsampule/homePage/home.dart';


class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}


class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateFormat outputFormat = DateFormat('yyyy-MM-dd');
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay;
  Map<DateTime, List> _eventsList = {};
  List sortedList = [];
  List convert = [];
  List conversion=[];
  List<DateTime> date=[];
  Future<Map<DateTime,List>> _future;

  Future<Map<DateTime,List<dynamic>>> getCalenderContents() async {
    final usersInfo = await FirebaseFirestore.instance.collection('users').doc(
        uid).collection('friends').get();
    for (var userInfo in usersInfo.docs) {
      final calenderContents = await FirebaseFirestore.instance
          .collection('users').doc(uid)
          .collection('friends').doc(userInfo['uuid'])
          .collection('Calender').get();
      for (var calenderContent in calenderContents.docs) {
        conversion.add([
          userInfo['名前'],
          userInfo['imageUrl'],
          calenderContent['内容'],
          userInfo
        ]);

        date.add(DateTime.parse(DateFormat('yyyy-MM-dd').format(calenderContent['日付'].toDate())));
      }
    }
   for(var indexs=0; indexs<date.length;indexs++) {
      for (var index = indexs; index < date.length; index++) {
        if (DateTime.parse(DateFormat('yyyy-MM-dd').format(date[indexs])) ==
            DateTime.parse(DateFormat('yyyy-MM-dd').format(date[index]))) {
          convert.add(conversion[index]);
        }
      }
      print(DateTime.parse(DateFormat('yyyy-MM-dd').format(date[indexs])));
      if(_eventsList.containsKey(date[indexs])==false){
      _eventsList.addAll({
       DateTime.parse(DateFormat('yyyy-MM-dd').format(date[indexs])):convert,
      });
      convert=[];
      }
      else{
        convert=[];
      }
    }
    return _eventsList;
  }

  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _future=getCalenderContents();
  }



    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: SingleChildScrollView(
          child: FutureBuilder(
            future: _future,
            builder: (BuildContext context,AsyncSnapshot snapshot) {
              final _events = LinkedHashMap<DateTime, List>(
                equals: isSameDay,
                hashCode: getHashCode,
              )..addAll(_eventsList);

              List _getEventForDay(DateTime day) {
                return _events[day] ?? [];
              }
              if(snapshot.hasError){
                 return Text('よきせぬエラーが発生しました');
              }
              switch (snapshot.connectionState){
                case ConnectionState.waiting:
                  return CircularProgressIndicator();
                default:
              return Column(
                children: [
                  Card(
                    child: TableCalendar(
                      locale: 'ja_JP',
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      eventLoader: _getEventForDay,
                      calendarFormat: _calendarFormat,
                      onFormatChanged: (format) {
                        if (_calendarFormat != format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        }
                      },
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay, day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        if (!isSameDay(_selectedDay, selectedDay)) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                          _getEventForDay(selectedDay);
                        }
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                    ),
                  ),
                  SizedBox(height: 20,),
                  ListView(
                    shrinkWrap: true,
                    children: _getEventForDay(_focusedDay)
                        .map((event) =>
                        Card(
                          child: ListTile(
                            title: Text(event[0]+': 内容 :'+event[2]),
                          ),
                        ))
                        .toList(),
                  )
                ],
              );}
            }
          ),
        ),
      );
    }
}



