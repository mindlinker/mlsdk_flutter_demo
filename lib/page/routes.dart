
import 'package:flutter/material.dart';
import 'package:mlsdk_flutter_example/page/join_meeting_page.dart';

import 'home_page.dart';
import 'login_page.dart';
import 'meeting_page.dart';

/// 登录页面
const loginPage = "/login";

/// 主页面
const homePage = "/home";

/// 加入会议页面
const joinMeetingPage = '/join_meeting';

/// 加入会议页面
const meetingPage = '/meeting';

final Map<String, WidgetBuilder> routes = {
    loginPage: (context) => const LoginPage(),
    homePage: (context) => const HomePage(),
    joinMeetingPage: (context) => const JoinMeetingPage(),
  meetingPage: (context) => const MeetingPage(),
};

Route<dynamic>? Function(RouteSettings) onGenerateRoute =
    (RouteSettings settings) {
        Object? arguments = settings.arguments;
        String? name = settings.name;
        if (routes.keys.contains(name)) {
            return MaterialPageRoute<void>(
                settings: settings,
                builder: (BuildContext context) => routes[name]!(context),
            );
        }

};