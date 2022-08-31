import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mlsdk_flutter/mlsdk_flutter.dart';
import 'package:mlsdk_flutter_example/page/routes.dart';

import '../constants/MLColor.dart';

class JoinMeetingPage extends StatefulWidget {
  const JoinMeetingPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _JoinMeetingPageWidget();
  }
}

typedef JoinMeetingCallback = void Function(MeetingRoom room);

class _JoinMeetingPageWidget extends State<JoinMeetingPage> {
  var _switchValueMicrophone = true;
  var _switchValueVideo = true;
  var _meetingNo = "";
  var _nickName = "";
  TextEditingController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  Future<void> joinMeetingRoom(JoinMeetingCallback onSuccess) async {
    if (_meetingNo.isEmpty) {
      Fluttertoast.showToast(msg: "会议号不能为空");
      return;
    }

    if (_nickName.isEmpty) {
      Fluttertoast.showToast(msg: "用户名称不能为空");
      return;
    }

    if(!(await hasPermission())) {
      requestPermission();
      return;
    }

    SmartDialog.showLoading();
    MeetingResult result = await MlsdkFlutter.joinMeeting(_meetingNo, _nickName, "")
    .whenComplete(() => SmartDialog.dismiss());

    if(result.code == 0 || result.code == 9997) {
      if(result.meetingRoom != null) {
        onSuccess.call(result.meetingRoom!);
      }
    }
  }


  Future<bool> hasPermission() async {
    bool b1 = await Permission.camera.isGranted;
    bool b2 = await Permission.microphone.isGranted;
    return b1 && b2;
  }

  requestPermission() async {
    await [
      Permission.camera,
      Permission.microphone,
    ].request();
  }

  void closeKeyboard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    /// 键盘是否是弹起状态
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    _nickName = ModalRoute.of(context)!.settings.arguments as String;
    _controller?.text = _nickName;

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark),
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "加入房间",
          style: TextStyle(
              color: MLColor.mainTextColor, fontWeight: FontWeight.normal),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: MLColor.mainTextColor),
      ),
      body: Container(
        color: MLColor.f1f3f5,
        child: Column(
          children: <Widget>[
            Container(
                height: 54,
                margin: const EdgeInsets.only(top: 12),
                color: Colors.white,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(left: 15),
                      child: const Text("房间号",
                          style: TextStyle(
                              color: MLColor.mainTextColor, fontSize: 16)),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 50, top: 3),
                      child: SizedBox(
                        width: 235,
                        height: 54,
                        child: TextField(
                          style: const TextStyle(
                              color: MLColor.mainTextColor, fontSize: 16),
                          decoration: const InputDecoration(
                              hintStyle: TextStyle(
                                  color: MLColor.cccccc, fontSize: 16),
                              hintText: "请输入会议号",
                              border: InputBorder.none),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _meetingNo = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                )),
            Container(
                height: 54,
                margin: const EdgeInsets.only(top: 0.5),
                color: Colors.white,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(left: 15),
                      child: const Text("用户名称",
                          style: TextStyle(
                              color: MLColor.mainTextColor, fontSize: 16)),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 34, top: 3),
                      child: SizedBox(
                        width: 235,
                        height: 54,
                        child: TextField(
                          controller: _controller,
                          style: const TextStyle(
                              color: MLColor.mainTextColor, fontSize: 16),
                          decoration: const InputDecoration(
                              hintStyle: TextStyle(
                                  color: MLColor.cccccc, fontSize: 16),
                              hintText: "请输入用户名称",
                              border: InputBorder.none),
                          onChanged: (value) {
                            setState(() {
                              _nickName = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                )),
            // Container(
            //     height: 54,
            //     margin: const EdgeInsets.only(top: 12),
            //     color: Colors.white,
            //     child: Row(
            //       crossAxisAlignment: CrossAxisAlignment.center,
            //       mainAxisSize: MainAxisSize.max,
            //       children: <Widget>[
            //         Container(
            //           margin: const EdgeInsets.only(left: 15),
            //           child: const Text("开启麦克风",
            //               style: TextStyle(
            //                   color: MLColor.mainTextColor, fontSize: 16)),
            //         ),
            //         Container(
            //             margin: const EdgeInsets.only(left: 190),
            //             child: Transform.scale(
            //               scale: 0.75,
            //               child: CupertinoSwitch(
            //                 activeColor: MLColor.mainColor,
            //                 value: _switchValueMicrophone,
            //                 onChanged: (value) {
            //                   setState(() {
            //                     _switchValueMicrophone = value;
            //                   });
            //                 },
            //               ),
            //             )),
            //       ],
            //     )),
            // Container(
            //     height: 54,
            //     margin: const EdgeInsets.only(top: 0.5),
            //     color: Colors.white,
            //     child: Row(
            //       crossAxisAlignment: CrossAxisAlignment.center,
            //       mainAxisSize: MainAxisSize.max,
            //       children: <Widget>[
            //         Container(
            //           margin: const EdgeInsets.only(left: 15),
            //           child: const Text("开启摄像头",
            //               style: TextStyle(
            //                   color: MLColor.mainTextColor, fontSize: 16)),
            //         ),
            //         Container(
            //             margin: const EdgeInsets.only(left: 190),
            //             child: Transform.scale(
            //               scale: 0.75,
            //               child: CupertinoSwitch(
            //                 activeColor: MLColor.mainColor,
            //                 value: _switchValueVideo,
            //                 onChanged: (value) {
            //                   setState(() {
            //                     _switchValueVideo = value;
            //                   });
            //                 },
            //               ),
            //             )),
            //       ],
            //     )),
            Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(left: 30, top: 80, right: 30),
                child: SizedBox(
                  width: 285,
                  height: 44,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(0),
                    ),
                    child: const Text("加入房间",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                    onPressed: () {
                      closeKeyboard(context);
                      joinMeetingRoom((room) {
                        Navigator.of(context).pushNamed(meetingPage, arguments: room);
                      });
                      // Navigator.of(context).pushNamed(homePage);
                      // print("name=$_textFieldName");
                    },
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
