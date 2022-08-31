> [toc]

# mlsdk_flutter
Mindlinker meeting Flutter 插件项目

## 开发准备
1. Android minSdkVersion：21
2. 需要准备服务器地址，即在迈聆开放平台申请的房间服务器地址
3. 需要准备好 appKey 和 APPSecret

## pubspec.yaml
```groovy
dependencies:
mlsdk_flutter: ^1.0.0-beta.2  # 迈聆会议
```

## 初始化SDK
### 功能介绍
SDK 初始化调用 MLApi.init(option) 就可以进行 sdk 的初始化。

### 示例代码
```dart
Future<MLResult> initMLSdk() async{
    MLOption option = MLOption(Constrant.serverUrl, Constrant.logPath,
    enableConsoleLog: true, enableLog: true);
    return MLApi.init(option);
}
```

### 参数说明
| 参数名称 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | --- | --- |
| serverUrl | String | 否 | 服务器地址，即在迈聆开放平台申请的房间服务器地址 |
| enableConsoleLog | Boolean | 否 | 是否在控制台输出日志打印 |
| enableLog | Boolean | 否 | 是否开启日志 |
| logPath | String | 是 | 本地日志保存路径，只有enableLog为true的情况下，才会进行日志的写入 |

### 返回值
MLResult 创建会议结果回调

| 参数名称 | 参数类型  | 参数描述 |
| --- | --- | --- |
| code | int | 返回码 0-成功；-1：未知错误码； |
| message | String |  错误信息 |


## 获取AuthCode
### 功能介绍
AuthCode 根据 JWT 协议生成的，后续 [登录授权](#登录授权) 需要传给 MLApi.authenticate，目的是为了校验 APP 的身份，[了解 AuthCode](https://www.mindlinker.com/doc/rest-api/apis/auth/auth-code.html)

### 示例代码
::: warning
以下获取的 Jwt Token 是为了方便客户端在测试阶段方便调试使用，正式使用时建议从后台生成后获取
:::

```
dependencies:
    dart_jsonwebtoken: ^2.4.2 // 快速生成 jwt token 依赖库
```

```dart
    // todo: 正式版的话，为了安全起见，appkey 和 appSecret 是保存在后台服务器的，这个 AuthCode 是由后台返回给到客户端的，
//  客户端这边拿到 authCode 之后传给 MLApi.authenticate，进行账号登录和验证
class AuthCode {

    static String getAuthCode(String nickname, String avatar, String openId) {
        return hs256(nickname, avatar, openId);
    }

    static String hs256(String nickname, String avatar, String openId) {
        String token;

        final jwt = JWT({
            'appKey': Constrant.appKey,
            'userInfo': {
            'nickname': nickname,
            'avatar': avatar,
            'openId': openId,
        }
        });

        // Sign it
        token = jwt.sign(SecretKey(Constrant.appSecret));
        print('AuthCode Signed token: $token\n');
        return token;
    }
}

```


## 登录授权

### 功能介绍
在完成 [初始化 SDK](#初始化sdk) 调用和 [获取 AuthCode](#获取authcode) 后需要进行 sdk 登录授权，授权成功后就可以创建会议和加入会议了，具体调用如下 Api MLApi.authenticate 进行

```dart
Future<AuthenticateResult> authenticate(String authCode, String nickName, String avatar) async
```

### 示例代码
```dart
  Future<void> authience() async {
    SmartDialog.showLoading();
    _deviceDetails()
        .then((value) => AuthCode.getAuthCode(_textFieldName, "", _identifier))     // 获取 AuthCode
    .then((authCode) => MLApi.authenticate(authCode, _textFieldName, ""))    // 授权登录
    .then((result) => {
    if(result.code == 0) {  // 授权成功
        Navigator.of(context).pushNamed(homePage, arguments: _textFieldName),
        Fluttertoast.showToast(msg: "authience success")
    } else {              // 授权失败
        Fluttertoast.showToast(msg: "code=${result.code} msg=${result.message}")
    }
  }).whenComplete(() => {
    SmartDialog.dismiss()
  });

}
```

### 参数说明
| 参数名称 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | --- | --- |
| authCode | String | 是 | AuthCode，根据 jwt 协议生成 |
| nickName | String | 是 | 用户名称 |
| avatar | String | 是 | 用户头像 |

### 返回值
AuthenticateResult

| 参数名称 | 参数类型  | 参数描述 |
| --- | --- | --- |
| code | int | 返回码 0-成功 -1：未知错误码 |
| message | String |  错误信息 |
| accessToken | String |  AccessToken 授权码|


## 创建会议
### 功能介绍
创建会议，使用 Api 是：MLApi.createMeeting()，结果回调：MeetingResult
```dart
Future<MeetingResult> createMeeting(
    String nickName, 
    String avatar,
    {String topic = ""}) async
```

### 示例代码
```dart
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

```


### 参数说明
MLApi.createMeeting

| 参数名称 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | --- | --- |
| nickName | String | 是 | 入会用户名称 |
| avatar | String | 是 | 用户头像 |
| topic | String | 否 | 房间名称 |



### 返回值
MeetingResult 创建会议结果回调

| 参数名称 | 参数类型  | 参数描述 |
| --- | --- | --- |
| code | int | 返回码 0-成功；9997-已经在房间中；403103014-会议室已经存在；-1：未知错误码； |
| message | String |  错误信息 |
| meetingRoom | MeetingRoom |  会议房间信息|


会议房间信息：MeetingRoom

| 参数名称 | 参数类型  | 参数描述 |
| --- | --- | --- |
| sessionId | String | sessionId，房间的唯一标识 |
| roomNo | String | 房间号 |
| password | String | 房间密码 |
| isRejoin | Boolean | 成员是否重新加入房间,默认为 false |


## 加入会议
### 功能介绍
创建会议，使用 Api 是：MLApi.joinMeeting()，结果回调：MeetingResult
```dart
Future<MeetingResult> joinMeeting(
    String meetingNo,
    String nickName, 
    String avatar,
    {String password = ""}) async
```

### 示例代码
```dart
    Future<void> joinMeetingRoom(JoinMeetingCallback onSuccess) async {
      if (_meetingNo.isEmpty) {
        Fluttertoast.showToast(msg: "会议号不能为空");
        return;
      }
    
      if (_nickName.isEmpty) {
        Fluttertoast.showToast(msg: "用户名称不能为空");
        return;
      }
    
      SmartDialog.showLoading();
      MeetingResult result = await MLApi.joinMeeting(
          _meetingNo, _nickName, "",)
          .whenComplete(() => SmartDialog.dismiss());
    
      if(result.code == 0 || result.code == 9997) {
        if(result.meetingRoom != null) {
          onSuccess.call(result.meetingRoom!);
        }
      }
    }


```


### 参数说明
MLApi.joinMeeting

| 参数名称 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | --- | --- |
| meetingNo | String | 是 | 房间号 |
| nickName | String | 是 | 入会用户名称 |
| avatar | String | 是 | 用户头像 |
| password | String | 是 | 入会密码 |



### 返回值
MeetingResult 加入会议结果回调

| 参数名称 | 参数类型  | 参数描述 |
| --- | --- | --- |
| code | int | 返回码 0-成功；9997-已经在房间中；403103014-会议室已经存在；-1：未知错误码； |
| message | String |  错误信息 |
| meetingRoom | MeetingRoom |  会议房间信息|


会议房间信息：MeetingRoom

| 参数名称 | 参数类型  | 参数描述 |
| --- | --- | --- |
| sessionId | String | sessionId，房间的唯一标识 |
| roomNo | String | 房间号 |
| password | String | 房间密码 |
| isRejoin | Boolean | 成员是否重新加入房间,默认为 false |

## MLSurfaceview
### 功能介绍
作为 PlatformView 的 Widget，MLSurfaceView 接收三个参数，分别为：uuid、isLocal、createdCallback，负责渲染本地预览视频和远程视频，其中 createdCallback 作为 MLSurfaceView 创建成功的回调，会返回一个 MLSurfaceviewController 可以用户订阅视频和取消订阅


### 示例代码
```dart
  // 本地预览视频（自己）
  Widget getLocalWidget() {
    return MLSurfaceview(
      "",
      true,
      createdCallback: (MLSurfaceviewController controller) {
        _localController?.unsubscribeVideo();
        controller.subscribeVideo();
        setState(() {
          _localController = controller;
        });
      },
    );
  }
  
  // 远程预览视频（他人）
  Widget getRemoteWidget() {
    if (_otherUuid.isEmpty) {
      return Container();
    }

    return MLSurfaceview(
      _otherUuid,
      false,
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
              width: 150,
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

```

### 参数说明
| 参数名称 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | --- | --- |
| uuid | String | 是 | 用户 uuid |
| isLocal | bool | 是 | 是否为本地视频；true：本地视频（自己）；false：远程视频（他人） |
| createdCallback | MLSurfaceViewCreatedCallback | 否 | MLSurfaceView 创建成功回调，会返回一个 MLSurfaceviewController |

- MLSurfaceviewController
  - subscribeVideo：订阅视频
  - unsubscribeVideo：取消订阅

## 退出会议
### 功能介绍
离开会议，可以调用 MLApi.quitMeeting(),  sessionId 为房间的唯一标识符，创建房间或者加入房间成功后会返回该参数。

```dart
Future<MLResult> quitMeeting(String sessionId) async
```

### 示例代码
```dart
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
                          MLApi.quitMeeting(_meetingRoom.sessionId!);
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
```

### 参数说明
| 参数名称 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | --- | --- |
| sessionId | String | 是 | sessionId，房间的唯一标识 |

### 返回值
MLResult 退出会议结果回调

| 参数名称 | 参数类型  | 参数描述 |
| --- | --- | --- |
| code | int | 返回码 0-成功；-1：未知错误码； |
| message | String |  错误信息 |


## 获取参会人列表
### 功能介绍
获取参会人列表，可以调用 MLApi.getMeetingMembers(),  需要在创建会议/进入会议成功之后调用，否则返回空列表

```dart
Future<List<Member>> getMeetingMembers() async
```

### 示例代码
```dart
    _initData() async {
      members = await MLApi.getMeetingMembers();
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

```

### 参数说明
无

### 返回值
Member 参会人信息

| 参数名称 | 参数类型  | 参数描述 |
| --- | --- | --- |
| uid | String |  参会人 uid |
| name | String |  昵称 |
| avatar | String |  头像 |
| userId | String |  参会人用户 id |
| isSelf | bool |  是否为用户本人 |



## 会议状态监听
### 功能介绍
创建会议/加入会议成功之后，可以调用 MLApi.onMeetingStateListener() 监听用户入会、用户例会已经会议结束的状态

```dart
static onMeetingStateListener(
      {required UserJoinCallback userJoinCallback,
        required UserLeaveCallback? userLeaveCallback,
        required MeetingEndCallback? meetingEndCallback});

typedef UserJoinCallback = void Function(Member room);        // 用户入会
typedef UserLeaveCallback = void Function(Member room);       // 用户离会
typedef MeetingEndCallback = void Function(String meetingNo); // 会议结束
```

### 示例代码
```dart
    MLApi.onMeetingStateListener(
        userJoinCallback: (member) {
          if (!member.isSelf) {
            setState(() {
              _otherUuid = member.uid;
            });
            Fluttertoast.showToast(msg: "${member.name} 加入会议");
          }
        }, userLeaveCallback: (member) {
          if (!member.isSelf) {
            setState(() {
              _otherUuid = "";
            });
          }
          Fluttertoast.showToast(msg: "${member.name} 离开会议");
        }, meetingEndCallback: ((meetingNo) {
          Fluttertoast.showToast(msg: "$meetingNo 会议已结束");
          Navigator.of(context).pop();
        })
    );
```


## 错误码对照表

| 错误码 | 描述 |
| --- | --- | 
| 0 | 成功 | 
| -1 | 未知错误 | 
| 1004 | 会议已经解散 |
| 9992 | 本地录制失败 |
| 9993 | 无效的本地录制路径 |
| 9994 | 无效的方法调用
| 9995 | 加入会议过程中被取消 |
| 9997 | 用户已在房间中 | 
| 9998 | SDK 未初始化 | 
| 9999 | 无效参数 | 
| 11000 | 无效的设备 |
| 11001 | 无法创建渲染器 |
| 11002 | 无法启动照相机 |
| 11003 | 无效的 sdp |
| 11004 | 无效的 sdp answer |
| 11005 | 无法启动麦克风 |
| 11006 | 无法启动扬声器 |
| 11007 | 无法关闭照相机 |
| 12000 | 不能识别的滤镜 GUID |
| 12001 | 滤镜已经存在 |
| 13001 | 未授权 |
| 13002 | 未加入任务房间 |
| 99997 | 当前网络不可用 | 
| 4001002 | 该参数的值进行唯一性校验时，已存在 |
| 4011000 | Token 失效或者账号在其他设备上登录了 |
| 4003100 | 访问不存在的资源 |
| 4003101 | 端点不存在，端点 ID 错误 |
| 4003102 | 会议不存在 |
| 4003105 | 用户不存在 |
| 4003106 | 设备不存在 |
| 4003107 | 企业不存在 |
| 4031000 | 资源被禁止访问。 |
| 4031001 | 资源被禁止删除。 |
| 4031002 | 用户角色验证失败 |
| 4031003 | 用户权限验证失败 |
| 4031004 | API 权限验证失败 |
| 4031005 | 匿名入会时会议不存在 |
| 4003124 | 房间已存在 |
| 4041000 | URL 参数错误 |
| 4041001 | 找不到对应的 namespace |
| 4041002 | API未注册 |
| 4041003 | 对应的API版本不支持当前的 Method |
| 4041004 | 对应版本找不到指定的 host |
| 5000001 | 获取不到 ClientToken |
| 5000002 | 无法向认证服务器认证 Accesstoken |
| 5001002 | 服务器更新数据失败 |
| 5001005 | 没有可用的 DS |
| 5001006 | 节点未级联 |
| 5002002 | 账号系统异常 |
| 5002001 | SFU 服务器异常  |
| 400111001 | 请求参数校验不正确 | 
| 404111003 | 房间号错误或加入房间已结束 | 
| 403111031 | 成员禁止加入房间 | 
| 403111044 | 输入房间密码错误，如果房间是需要密码的，而成员没传密码加入房间也会报这个错误码 | 
| 403111044 | 输入房间密码次数 5 分钟内达到上限 |
| 403111051 | 无法被指定为主持人，当前用户可能是小程序入会 |
| 403111052 | 无法被指定为焦点视频，当前用户可能是小程序入会 |
| 403111066 | 正在应用自定义布局，暂不支持设置焦点视频
| 403111023 | 房间已锁定 |
| 403111046 | 密码输入错误次数过多 |
| 403111006 | 当前用户无权限 |
| 403111030 | 不能将角色转给硬件终端 |
| 400111001 | 某参数值校验不正确,在于值的类型错误 |
| 400111002 | 缺少 Accesstoken |
| 404111003 | 房间不存在 |
| 404111007 | 未加入任何房间，端点有效，但不存在请求的房间中 |
| 403119005 | 免费视频会议并发数量已到上限 |
| 403119009 | 购买的视频会议数量已到上限 |
| 403119010 | 在其他平台发起了会议 |
| 403119011 | 免费方数已到上限 |
| 403119012 | 支付方数已到上限 |
| 403119013 | 专属会议方数已到上限 |
| 403103017 | 企业开启的会议总数已达上限 |
| 403111018 | 单个会议的人数超过限制 |
| 403111023 | 会议已被锁定 |
| 403111031 | 您已被禁止入会 |
| 403111044 | 入会密码错误 |
| 403111045 | 入会凭证已失效 |
| 403111040 | 企业未开通录制功能 |
| 400111041 | 存储空间不足 |
| 500111004 | 当前资源被锁定 |
| 500111011 | 信令服务器不可用 |
| 500111012 | 没有可用的SFU |
| 500111013 | 远程服务异常 |
