import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'chat_message.dart';

class FlutterVonageVideo {
  static const MethodChannel _channel =
      const MethodChannel('flutter_vonage_video');
  static FlutterVonageVideo _instance=FlutterVonageVideo._internal();
  final StreamController<Message> _streamController = StreamController<Message>();
  final StreamController<String> _actionstreamController = StreamController<String>();


  Stream<Message> get messageStream => _streamController.stream;
  Stream<String> get actionStream => _actionstreamController.stream;

  Sink get _addMessagetoStream => _streamController.sink;
  Sink get _actionStreamSink => _actionstreamController.sink;

  factory FlutterVonageVideo()=>_instance;
  FlutterVonageVideo._internal();

  dispose() {
    _streamController.close();
    _actionstreamController.close();
  }

  initialize() {
    _channel.setMethodCallHandler(handleMethodCall);
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'addMessage':
        print("Fluttervonage: Message recieved");
        _addMessagetoStream.add(Message.fromJson(json.decode(call.arguments)));
        return '';
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: 'flutter_vonage_video doesn\'t implement \'${call.method}\'',
        );
    }
  }
  /*
  {
  "to":"to",
  "from":"from",
  "message":"message",
  "dttm":"date",
  "messageType":1
  }
  */

  static Future<String?> initSession(
      String sessionId, String token, String apiKey) async {
    print('initSession');
    bool havePermissions = await checkPermissions();
    if (havePermissions) {
      try {
        return await _channel.invokeMethod('initSession',
            {"sessionId": sessionId, "token": token, "apiKey": apiKey});
      } on PlatformException {
        return "error";
      }
    }
    return "permissions not granted";
  }

  static Future<String?> endSession() async {
    print('endSession');
    try {
      return await _channel.invokeMethod('endSession', {});
    } on PlatformException {
      return "error";
    }
  }
  static action(String _action){
          _instance._actionStreamSink.add(_action);
  }

  static Future<String?> publishStream(String name, int viewId) async {
    try {
      return await _channel
          .invokeMethod('publishStream', {"name": name, "viewId": viewId});
    } on PlatformException {
      return "error";
    }
  }

  static Future<String?> unpublishStream() async {
    try {
      return await _channel.invokeMethod('unpublishStream', {});
    } on PlatformException {
      return "error";
    }
  }

  static Future<bool> muteAudio() async {
    try {
      return await _channel.invokeMethod('muteAudio', {});
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> cameraOff() async {
    try {
      return await _channel.invokeMethod('cameraOff', {});
    } on PlatformException {
      return false;
    }
  }
  static Future<bool> sendMessage(String msgInfo) async {
    try {
      return await _channel.invokeMethod('sendMessage', msgInfo);
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> cycleCamera() async {
    try {
      return await _channel.invokeMethod('cycleCamera', {});
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> checkPermissions() async {
    bool cameraGranted = await Permission.camera.request().isGranted;
    bool cameraDenied = false;
    if (!cameraGranted) {
      cameraDenied = await Permission.camera.isPermanentlyDenied;
    }
    bool microphoneGranted = await Permission.microphone.request().isGranted;
    bool microphoneDenied = false;
    if (!microphoneGranted) {
      microphoneDenied = await Permission.microphone.isPermanentlyDenied;
    }

    if (cameraDenied || microphoneDenied) {
      openAppSettings();
    }
    if (cameraGranted && microphoneGranted) {
      return true;
    }
    return false;
  }

  static Future<String?> subscribingStream(String name, int viewId) async {
    try {
      return await _channel
          .invokeMethod('subscribingStream', {"name": name, "viewId": viewId});
    } on PlatformException {
      return "error";
    }
  }
}
