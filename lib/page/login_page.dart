
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mlsdk_flutter/mlsdk_flutter.dart';
import 'package:mlsdk_flutter_example/page/routes.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '../constants/Constants.dart';
import '../constants/MLColor.dart';
import '../utils/AuthCode.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  var _textFieldName = "chenjianrun";
  var _identifier = "";
  TextEditingController? _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: _textFieldName);
  }


  // 弹出对话框
  Future<bool?> showTipDialog() async {
    return showDialog(
      context: context,
      builder: (context) {
        return WillPopScope(
            child: Material(
              type: MaterialType.transparency,
              child: Center(
                child: AlertDialog(
                  title: const Text("温馨提示"),
                  content: const Text("appKey 和 appSecret 为空，请联系迈聆客服获取"),
                  actions: <Widget>[
                    TextButton(
                      child: const Text("知道了"),
                      onPressed: () => Navigator.of(context).pop(false), // 关闭对话框
                    ),
                  ],
                ),
              ),
            ),
            onWillPop: () async => false);
      },
    );
  }


  Future<void> authience() async {
    if(Constants.appKey.isEmpty || Constants.appSecret.isEmpty) {
      showTipDialog();
      return;
    }

    SmartDialog.showLoading();
    _deviceDetails()
        .then((value) => AuthCode.getAuthCode(_textFieldName, "", _identifier))
        .then((authCode) => MLApi.authenticate(authCode, _textFieldName, ""))
        .then((result) => {
      if(result.code == 0) {
        Navigator.of(context).pushNamed(homePage, arguments: _textFieldName),
        Fluttertoast.showToast(msg: "authience success")
      } else {
        Fluttertoast.showToast(msg: "code=${result.code} msg=${result.message}")
      }
    }).whenComplete(() => {
      SmartDialog.dismiss()
    });

  }

  Future<void> _deviceDetails() async{
    String deviceName = "";
    String deviceVersion = "";
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        setState(() {
          deviceName = build.model;
          deviceVersion = build.version.toString();
          _identifier = build.androidId;
        });
        //UUID for Android
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        setState(() {
          deviceName = data.name;
          deviceVersion = data.systemVersion;
          _identifier = data.identifierForVendor;
        });//UUID for iOS
      }
    } on PlatformException {
      print('Failed to get platform version');
    }

    print("_deviceDetails() deviceName=$deviceName deviceVersion=$deviceVersion _identifier=$_identifier ");
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
                margin: const EdgeInsets.only(left: 30, top: 108),
                child: const Text(
                  "欢迎登录",
                  style: TextStyle(
                      color: MLColor.mainTextColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w600),
                )),
            Container(
              margin: const EdgeInsets.only(left: 30, top: 50, right: 30),
              child: TextField(
                style: const TextStyle(color: MLColor.mainTextColor, fontSize: 18),
                decoration: const InputDecoration(
                    hintStyle: TextStyle(color: MLColor.cccccc, fontSize: 17),
                    hintText: "请输入用户昵称",
                    border: InputBorder.none
                ),
                controller: _controller,
                onChanged: (value) {
                  setState(() {
                    _textFieldName = value;
                  });
                },
              ),
            ),
            // grey line
            Container(
              margin: const EdgeInsets.only(left: 30, top: 1, right: 30),
              color: MLColor.d6d6d6,
              height: 0.5,
            ),
            Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(left: 30, top: 70, right: 30),
                child: SizedBox(
                  width: 315,
                  height: 44,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(0),
                    ),
                    child: const Text("登录",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                    onPressed: () {
                      if(_textFieldName.isNotEmpty) {
                        print("name=$_textFieldName");
                        authience();
                      } else {
                        Fluttertoast.showToast(msg: "请输入用户昵称");
                      }

                    },
                  ),
                )
            )
          ],
        ),
      ),
    );
  }
}