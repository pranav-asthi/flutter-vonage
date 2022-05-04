import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vonage_video/chat_message.dart';
import 'package:flutter_vonage_video/flutter_vonage_video.dart';

import 'message.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _tokboxSessionId =
      '1_MX40NzQ2ODM4MX5-MTY1MTY0OTcwMTcwNX5kcnd6cWFBT0grTXVJS2crczErZDBHZUR-fg';
  String _tokboxToken =
  'T1==cGFydG5lcl9pZD00NzQ2ODM4MSZzaWc9N2NiNDc0YWRlZTBiMDhlZWUyN2UwN2QwMWZlYzM0MTBmNGFlZjFjMTpzZXNzaW9uX2lkPTFfTVg0ME56UTJPRE00TVg1LU1UWTFNVFkwT1Rjd01UY3dOWDVrY25kNmNXRkJUMGdyVFhWSlMyY3JjekVyWkRCSFpVUi1mZyZjcmVhdGVfdGltZT0xNjUxNjQ5NzM5Jm5vbmNlPTAuNzEyOTQwMjMwODQwNzg3MSZyb2xlPXB1Ymxpc2hlciZleHBpcmVfdGltZT0xNjUxNjUzMzQwJmluaXRpYWxfbGF5b3V0X2NsYXNzX2xpc3Q9';
  String _tokboxApiKey = '47468381';
  String _publishId = 'PUBLISH_ID';

  bool _sessionInited = false;
  bool _isPublishing = false;
  bool _isAudio = true;
  bool _isChatOpen = false;
  bool _isVideo = true;
  bool _isCallTimerOn = false;
  final ScrollController _scrollController=ScrollController();
  final TextEditingController _controller=TextEditingController();

  int _pluginViewId = -1;

  @override
  void initState() {
    super.initState();
    _startAll();
    FlutterVonageVideo().initialize();
    FlutterVonageVideo().messageStream.listen((event) {
      final message=event;
      print("Message:${message.toJson()}");
    });
  }

  Future<void> _startAll() async {
    await _initSession();
    //await Future.delayed(Duration(seconds: 2));
    //await _subscriberStream();
    // await Future.delayed(Duration(seconds: 2));
    // await _publishStream();
  }

  Future<void> _initSession() async {
    String? ret = await FlutterVonageVideo.initSession(
        _tokboxSessionId, _tokboxToken, _tokboxApiKey);
    setState(() {
      _sessionInited = true;
      _isPublishing = false;
    });
    print(ret);
  }

  Future<void> _publishStream() async {
    String? ret =
        await FlutterVonageVideo.publishStream(_publishId, _pluginViewId);
    setState(() {
      _isPublishing = true;
    });
  }

  // Future<void> _unpublishStream() async {
  //   String ret = await FlutterVonageVideo.unpublishStream();
  //   setState(() {
  //     _isPublishing = false;
  //   });
  // }

  Future<void> _subscriberStream() async {
    String? ret = await FlutterVonageVideo.subscribingStream("a", 1);
  }

  Future<bool> _muteAudio() async {
    return await FlutterVonageVideo.muteAudio();
  }

  Future<bool> _cameraOff() async {
    return await FlutterVonageVideo.cameraOff();
  }

  Future<bool> _cycleCamera() async {
    return await FlutterVonageVideo.cycleCamera();
  }

  Widget? _buildPublisher(var context) {
    String viewType = 'flutter-vonage-video-publisher';
    Map<String, dynamic> creationParams = <String, dynamic>{};
    if (defaultTargetPlatform == TargetPlatform.android) {
      return PlatformViewLink(
        viewType: viewType,
        surfaceFactory:
            (BuildContext context, PlatformViewController controller) {
          return AndroidViewSurface(
            controller: controller as AndroidViewController,
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          );
        },
        onCreatePlatformView: (PlatformViewCreationParams params) {
          return PlatformViewsService.initSurfaceAndroidView(
            id: params.id,
            viewType: viewType,
            layoutDirection: TextDirection.ltr,
            creationParams: creationParams,
            creationParamsCodec: StandardMessageCodec(),
          )
            ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
            ..create();
        },
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: viewType,
        layoutDirection: TextDirection.ltr,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: (int id) {
          _pluginViewId = id;
        },
      );
    }
  }

  Widget? _buildSubscriber(var context) {
    String viewType = 'flutter-vonage-video-subscriber';
    Map<String, dynamic> creationParams = <String, dynamic>{};
    if (defaultTargetPlatform == TargetPlatform.android) {
      return PlatformViewLink(
        viewType: viewType,
        surfaceFactory:
            (BuildContext context, PlatformViewController controller) {
          return AndroidViewSurface(
            controller: controller as AndroidViewController,
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          );
        },
        onCreatePlatformView: (PlatformViewCreationParams params) {
          return PlatformViewsService.initSurfaceAndroidView(
            id: params.id,
            viewType: viewType,
            layoutDirection: TextDirection.ltr,
            creationParams: creationParams,
            creationParamsCodec: StandardMessageCodec(),
          )
            ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
            ..create();
        },
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: viewType,
        layoutDirection: TextDirection.ltr,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: (int id) {
          _pluginViewId = id;
        },
      );
    }
  }

  @override
  void dispose() {
    // if (_isPublishing) {
    //   _unpublishStream();
    // }
    if (_sessionInited) {
      FlutterVonageVideo.endSession();
      FlutterVonageVideo().dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Widget _buttonPublish = SizedBox.shrink();
    // if (_sessionInited && !_isPublishing) {
    //   _buttonPublish = ElevatedButton(
    //     child: Text('Publish Stream'),
    //     onPressed: _publishStream,
    //   );
    // }

    // Widget _buttonUnpublish = SizedBox.shrink();
    // if (_sessionInited && _isPublishing) {
    //   _buttonUnpublish = ElevatedButton(
    //     child: Text('Unpublish Stream'),
    //     onPressed: _unpublishStream,
    //   );
    // }
    // Widget _subscribingButton = SizedBox.shrink();
    // if (true) {
    //   _subscribingButton = ElevatedButton(
    //     child: Text('Subscriber Stream'),
    //     onPressed: _subscriberStream,
    //   );
    // }
    return MaterialApp(
      builder: (context, _) {
        var size = MediaQuery.of(context).size;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Vonage Video example app'),
          ),
          body: Container(
            color: Colors.black45,
            width: size.width,
            height: size.height,
            child: Stack(
              children: [
                Align(
                    alignment: Alignment.center,
                    child: Center(
                      child: Container(child: _buildSubscriber(context)),
                    )),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(0.0, 10.0, 10.0,0.0),
                    height: 150,
                    width: 100,
                    child: _buildPublisher(context),
                  ),
                ),
                Positioned(
                  bottom: 20.0,
                  left: 0.0,
                  right: 0.0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: MaterialButton(
                            padding: EdgeInsets.zero,
                            shape: CircleBorder(
                                side: BorderSide(
                                    color: _isAudio ? Colors.white : Colors.red,
                                    width: 2.0)),
                            child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child:
                                    Icon(_isAudio ? Icons.mic : Icons.mic_off)),
                            color: Colors.black45,
                            textColor: _isAudio ? Colors.white : Colors.red,
                            onPressed: () async{
                              await _muteAudio();
                              setState(() {
                                _isAudio = !_isAudio;
                              });
                            }),
                      ),
                      Flexible(
                        child: MaterialButton(
                            padding: EdgeInsets.zero,
                            shape: CircleBorder(
                                side: BorderSide(
                                    color: _isVideo ? Colors.white : Colors.red,
                                    width: 2.0)),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Icon(_isVideo
                                  ? Icons.videocam
                                  : Icons.videocam_off),
                            ),
                            color: Colors.black45,
                            textColor: _isVideo ? Colors.white : Colors.red,
                            onPressed: () async{
                              await _cameraOff();
                              setState(() {
                                _isVideo = !_isVideo;
                              });
                            }),
                      ),
                      Flexible(
                        child: MaterialButton(
                            padding: EdgeInsets.zero,
                            shape: CircleBorder(
                                side: BorderSide(
                                    color: Colors.white, width: 2.0)),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Icon(Icons.chat_bubble),
                            ),
                            color: Colors.black45,
                            textColor: Colors.white,
                            onPressed: () {
                              setState(() {
                                _isChatOpen = !_isChatOpen;
                              });
                            }),
                      )
                    ],
                  ),
                ),
                    Visibility(
                      visible:_isChatOpen,
                      child: Positioned(
                          bottom: 100.0,
                          left: 0.0,
                          right: 0.0,
                          top: 0.0,
                          child: Column(
                            children: [
                              Expanded(child: chatWidget()),
                              input()
                            ],
                          )
                ),
                    )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget input() {
    return Container(
      padding: EdgeInsets.only(left: 10, bottom: 2, top: 2),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(20.0))
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                  hintText: "Write message...",
                  hintStyle: TextStyle(color: Colors.black54),
                  border: InputBorder.none),
            ),
          ),
          SizedBox(
            width: 15,
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                color: Colors.lightBlue,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          SizedBox(
            width: 15,
          ),
          FloatingActionButton(mini: true,
            onPressed: () async{
            var msg=Message(message: _controller.text,from: "client 2",to: "doctor",date: "date",type: 1,isRemote: false);
            // await sendMessage(msg.toJson());
            FocusScope.of(context).unfocus();
            _controller.clear();
            },
            child: Icon(
              Icons.send,
              color: Colors.white,
              size: 18,
            ),
            backgroundColor: Colors.blue,
            elevation: 0,
          ),
        ],
      ),
    );
  }
  scrollTo(){
  _scrollController.animateTo( _scrollController.position.maxScrollExtent,
  duration: Duration(seconds: 2),
  curve: Curves.fastOutSlowIn,);
}
  addMessage(){
    messages.add(ChatMessage(messageContent: _controller.text,messageType: "sender"));
    setState(() {
    });
    // scrollTo();
  }
  Future<bool> sendMessage(Map<String,dynamic> msgInfo)async
  {
      return await FlutterVonageVideo.sendMessage(json.encode(msgInfo));
  }
  Widget chatWidget() {
    return Container(
      child: ListView.builder(
        itemCount: messages.length,
        addAutomaticKeepAlives: true,
        shrinkWrap: true,
        controller: _scrollController,
        padding: EdgeInsets.only(top: 10, bottom: 10),
        itemBuilder: (context, index) => Container(
          padding: EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
          child: Align(
            alignment: (messages[index].messageType == "receiver"
                ? Alignment.topLeft
                : Alignment.topRight),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: (messages[index].messageType == "receiver"
                    ? Colors.grey.shade200
                    : Colors.blue[200]),
              ),
              padding: EdgeInsets.all(16),
              child: Text(
                messages[index].messageContent,
                style: TextStyle(fontSize: 15),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<ChatMessage> messages = [
    ChatMessage(messageContent: "Hello, Will", messageType: "receiver"),
    ChatMessage(messageContent: "How have you been?", messageType: "receiver"),
    ChatMessage(
        messageContent:
            "Hey Kriss, I am doing fine dude. wbu? hgdg yfu fu 8  78 7ti    7",
        messageType: "sender"),
    ChatMessage(messageContent: "ehhhh, doing OK.", messageType: "receiver"),
    ChatMessage(
        messageContent: "Is there any thing wrong?", messageType: "sender"),

  ];
}
