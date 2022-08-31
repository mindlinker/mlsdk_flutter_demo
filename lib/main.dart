import 'package:flutter/material.dart';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:mlsdk_flutter/mlsdk_flutter.dart';
import 'package:mlsdk_flutter_example/constants/Constants.dart';
import 'package:mlsdk_flutter_example/constants/MLColor.dart';
import 'package:mlsdk_flutter_example/page/routes.dart';

void main() async{
  runApp(const MyApp());

  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark, // 状态栏字体颜色
        statusBarBrightness: Brightness.dark // 状态栏背景色
        ));
  }

  await initMLSdk();
}

Future<MLResult> initMLSdk() async{
  MLOption option = MLOption(Constants.serverUrl, Constants.logPath,
      enableConsoleLog: true, enableLog: true);
  return MLApi.init(option);
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  ///主题配置
  ThemeData get theme {
    const Color _primaryColor = MLColor.mainColor;

    return ThemeData(
      buttonColor: MLColor.mainTextColor,
      brightness: Brightness.light,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,

      //次颜色（灰色）、影响TabBar选中颜色，文字颜色
      primaryColor: _primaryColor,
      // 主题色
      primaryColorLight: MLColor.mainColor,
      //禁用波纹效果
      accentColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,


      // 设置路由切换的过渡动画（页面切换动画）
      pageTransitionsTheme: PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
        },
      ),
      //主色调，高亮色（紫色）
      tabBarTheme: const TabBarTheme(
        //tabbar主题
        labelColor: MLColor.mainTextColor,
        labelStyle: TextStyle(fontSize: 16),
        unselectedLabelStyle: TextStyle(fontSize: 16),
        indicator: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.green, width: 2))),
      ),
      buttonTheme: const ButtonThemeData(
          splashColor: Colors.transparent, highlightColor: Colors.transparent),

      appBarTheme: const AppBarTheme(brightness: Brightness.light),
      // StatusBar
      textTheme: const TextTheme(headline6: TextStyle(color: _primaryColor)),
      scaffoldBackgroundColor: Colors.white,
      colorScheme:
          ColorScheme.fromSwatch().copyWith(secondary: const Color(0xff706f70)),
    );
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

// 路由转场动画啊
class MyPageTransitionsBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    var begin = const Offset(1.0, 0.0);
    var end = const Offset(0.0, 0.0);

    var tween = Tween(begin: begin, end: end);
    var offsetAnimation = animation.drive(tween);
    return SlideTransition(
      position: offsetAnimation,
      child: child,
    );
  }
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var body = getBody();

    return ScreenUtilInit(
        designSize: const Size(375, 667), builder: (context, child) => body);
  }

  getBody() {
    return MaterialApp(
      theme: widget.theme,
      initialRoute: loginPage,
      routes: routes,
      navigatorObservers: [FlutterSmartDialog.observer],
      builder: FlutterSmartDialog.init(),
    );
  }
}
