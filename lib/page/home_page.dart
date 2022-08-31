import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mlsdk_flutter/mlsdk_flutter.dart';
import 'package:mlsdk_flutter_example/page/routes.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {

    return _HomePageWidget();
  }
}

typedef CreateMeetingCallback = void Function(MeetingRoom room);

class _HomePageWidget extends State<HomePage> {
  var _dayOfMonth = "03";
  var _dayOfWeek = "周三";
  var _date = "2021年1月";
  var _nickName = "";
  var _identifier = "";

  @override
  void initState() {
    super.initState();
    checkPermission();
    parseDateToYearMonthDayWeek();
  }


  checkPermission() async {
    await [
      Permission.storage,
      Permission.camera,
      Permission.microphone,
    ].request();
  }

  Future<void> createMeeting(CreateMeetingCallback onSuccess) async {
    SmartDialog.showLoading();
    MeetingResult result = await MLApi.createMeeting(_nickName, "")
        .whenComplete(() => SmartDialog.dismiss());
    MeetingRoom? meetingRoom = result.meetingRoom;
    if(result.code == 0 || result.code == 9997) {
      if(result.meetingRoom != null) {
        onSuccess.call(result.meetingRoom!);
      }
    } else if(result.code == 403103014) {
      // 会议室已经存在
      Fluttertoast.showToast(msg: "会议室已经存在");
      if(meetingRoom != null) {
        showJoinDialog(meetingRoom.roomNo, meetingRoom.sessionId, onSuccess);
      }
    }
  }

  // 弹出对话框
  Future<bool?> showJoinDialog(String roomNo, String? sessionId , CreateMeetingCallback onSuccess) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("温馨提示"),
          content: Text("你之前有创建的房间未结束\n房间号：$roomNo"),
          actions: <Widget>[
            TextButton(
              child: const Text("暂不加入"),
              onPressed: () => Navigator.of(context).pop(), // 关闭对话框
            ),
            TextButton(
              child: const Text("重新加入"),
              onPressed: () {
                joinMeetingRoom(roomNo, onSuccess);
                //关闭对话框并返回true
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }


  Future<void> joinMeetingRoom(String roomNo, CreateMeetingCallback onSuccess) async {
    SmartDialog.showLoading();

    MeetingResult result = await MLApi.joinMeeting(roomNo, _nickName, "",)
    .whenComplete(() => SmartDialog.dismiss());

    if(result.code == 0 || result.code == 9997) {
      if(result.meetingRoom != null) {
        onSuccess.call(result.meetingRoom!);
      }
    }
  }

  parseDateToYearMonthDayWeek() {
    var now = DateTime.now();
    var day = now.day;
    var month = now.month;
    var year = now.year;
    var week = now.weekday;
    var dayStr = day < 10 ? "0$day" : day.toString();
    var monthStr = month < 10 ? "0$month" : month.toString();
    var weekMap = <int, String>{
      1: "周一",
      2: "周二",
      3: "周三",
      4: "周四",
      5: "周五",
      6: "周六",
      7: "周日",
    };

    setState(() {
      _date = "$year年$monthStr月";
      _dayOfMonth = dayStr;
      _dayOfWeek = weekMap[week] ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    _nickName = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(left: 20, top: 45),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: Text(
                    _dayOfMonth,
                    style: const TextStyle(
                        fontSize: 32, fontWeight: FontWeight.w600),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _date,
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      _dayOfWeek,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                )
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              createMeeting((room) {
                Navigator.of(context).pushNamed(meetingPage, arguments: room);
              });
            },
            child: Image.asset('assets/images/home/img_create_meeting.png'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed(joinMeetingPage, arguments: _nickName);
            },
            child: Image.asset('assets/images/home/img_join_meeting.png'),
          ),

        ],
      ),
    );
  }
}
