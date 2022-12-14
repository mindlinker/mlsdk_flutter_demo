import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mlsdk_flutter/mlsdk_flutter.dart';
import 'package:mlsdk_flutter/mlsdk_flutter_method_channel.dart';

import '../constants/MLColor.dart';
import 'home_page.dart';

class MeetingPage extends StatefulWidget {
  const MeetingPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MeetingPageWidget();
  }
}

class _MeetingPageWidget extends State<MeetingPage> {
  late MeetingRoom _meetingRoom;
  MLSurfaceviewController? _localController;
  MLSurfaceviewController? _remoteController;
  String uuid = "";
  String _otherUuid = "";
  late List<Member> members;

  @override
  void initState() {
    super.initState();
    _initData();


    MLApi.onMeetingStateListener(userJoinCallback: (member) {
      print(
          "PlatformSurfaceView onUserJoin _otherUuid=${member.uid} name=${member.name}");
      if (!member.isSelf) {
        setState(() {
          _otherUuid = member.uid;
        });
        Fluttertoast.showToast(msg: "${member.name} 加入会议");
      }
    }, userLeaveCallback: (uuid) {
      if(uuid == _otherUuid) {
        setState(() {
          _otherUuid = "";
        });
        Fluttertoast.showToast(msg: "$uuid 离开会议");
      }
    }, meetingEndCallback: ((meetingNo) {
      Fluttertoast.showToast(msg: "$meetingNo 会议已结束");
      Navigator.of(context).pop();
    }), disconnectedCallback: () {
      debugPrint("disconnectedCallback");
      Navigator.of(context).pop();
    });
  }

  showDisconnect() {
    // 检测到您已掉线，是否立即重新加入房间?
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("温馨提示"),
          content: const Text("检测到您已掉线，是否立即重新加入房间?"),
          actions: <Widget>[
            TextButton(
              child: const Text("暂不加入"),
              onPressed: () => Navigator.of(context).pop(), // 关闭对话框
            ),
            TextButton(
              child: const Text("重新加入"),
              onPressed: () {
                joinMeetingRoom(_meetingRoom!.roomNo, (room) {

                });
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

    MeetingResult result = await MLApi.joinMeeting(roomNo)
        .whenComplete(() => SmartDialog.dismiss());

    if(result.code == 0 || result.code == 9997) {
      if(result.meetingRoom != null) {
        onSuccess.call(result.meetingRoom!);
      }
    }
  }


  _initData() async {
    members = await MLApi.getMeetingMembers();
    print("PlatformSurfaceView initdata members=$members");
    var list1 = members.where((element) => element.isSelf);
    if (list1.isNotEmpty) {
      setState(() {
        uuid = list1.first.uid;
      });
    }
    var list2 = members.where((element) => !element.isSelf);
    if (list2.isNotEmpty) {
      setState(() {
        _otherUuid = list2.first.uid;
      });
    }
  }

  Widget getLocalWidget() {
    return MLSurfaceview(
      "",
      true,
      onTap: () {
        print("getLocalWidget onTap");
      },
      createdCallback: (MLSurfaceviewController controller) {
        _localController?.unsubscribeVideo();
        controller.subscribeVideo();
        setState(() {
          _localController = controller;
        });
      },
    );
  }

  Widget getRemoteWidget() {
    // print("getRemoteWidget localMode=$localMode");
    if (_otherUuid.isEmpty ) {
      return Container(color: Colors.blue,);
    }

    return MLSurfaceview(
      _otherUuid,
      false,
      onTap: () {
        print("getRemoteWidget onTap");
      },
      createdCallback: (MLSurfaceviewController controller) {
        _remoteController?.unsubscribeVideo();
        controller.subscribeVideo();
        setState(() {
          _remoteController = controller;
        });
      },
    );
  }

  Widget showPlatformView() {
    return Container(
      color: Colors.black,
      child: _otherUuid.isEmpty
          ? getLocalWidget()
          : Stack(
        alignment: AlignmentDirectional.topEnd,
        children: <Widget>[
          getRemoteWidget(),
          Container(
            margin: const EdgeInsets.only(right: 20, top: 20),
            child: SizedBox(
              width: 130,
              height: 190,
              child: Container(
                child: getLocalWidget(),
              ),
            ),
          )

        ],
      ),
    );
  }

  // 弹出对话框
  Future<bool?> showQuitDialog() async {
    return showDialog(
      context: context,
      builder: (context) {
        return WillPopScope(
            child: Material(
              type: MaterialType.transparency,
              child: Center(
                child: AlertDialog(
                  title: const Text("温馨提示"),
                  content: const Text("离开房间"),
                  actions: <Widget>[
                    TextButton(
                      child: const Text("否"),
                      onPressed: () =>
                          Navigator.of(context).pop(false), // 关闭对话框
                    ),
                    TextButton(
                      child: const Text("是"),
                      onPressed: () {
                        MLApi.quitMeeting();
                        _localController?.unsubscribeVideo();
                        //关闭对话框并返回true
                        Navigator.of(context).pop(true);
                      },
                    ),
                  ],
                ),
              ),
            ),
            onWillPop: () async => false);
      },
    );
  }

  @override
  void dispose() {
    _localController?.unsubscribeVideo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _meetingRoom = ModalRoute.of(context)!.settings.arguments as MeetingRoom;

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark),
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "会议房间 ${_meetingRoom.roomNo}",
          style: const TextStyle(
              color: MLColor.mainTextColor, fontWeight: FontWeight.normal),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: MLColor.mainTextColor),
      ),
      body: WillPopScope(
        child: showPlatformView(),
        onWillPop: () async {
          return await showQuitDialog() ?? true;
        },
      ),
    );
  }
}
