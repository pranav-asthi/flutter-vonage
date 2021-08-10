import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_vonage_video/flutter_vonage_video.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _tokboxSessionId = 'YOUR_SESSION_ID';
  String _tokboxToken = 'YOUR_TOKEN';
  String _tokboxApiKey = 'YOUR_API_KEY';
  String _publishId = 'PUBLISH_ID';

  bool _sessionInited = false;
  bool _isPublishing = false;

  int _pluginViewId = -1;

  @override
  void initState() {
    super.initState();
    _startAll();
  }

  Future<void> _startAll() async{
    await _initSession();
    // await Future.delayed(Duration(seconds: 2));
    // await _publishStream();
    // await Future.delayed(Duration(seconds: 2));
    // await _subscriberStream();
  }

  Future<void> _initSession() async {
    String ret = await FlutterVonageVideo.initSession(_tokboxSessionId, _tokboxToken, _tokboxApiKey);
    setState(() {
      _sessionInited = true;
      _isPublishing = false;
    });
    print(ret);
  }

  Future<void> _publishStream() async {
    String ret = await FlutterVonageVideo.publishStream(_publishId, _pluginViewId);
    setState(() {
      _isPublishing = true;
    });
  }

  Future<void> _unpublishStream() async {
    String ret = await FlutterVonageVideo.unpublishStream();
    setState(() {
      _isPublishing = false;
    });
  }

  Future<void> _subscriberStream() async {
    String ret = await FlutterVonageVideo.subscribingStream("a", 1);
  }

  Widget _buildPublisher(var context) {
    String viewType = 'flutter-vonage-video-publisher';
    Map<String, dynamic> creationParams = <String, dynamic> {};
    if (defaultTargetPlatform == TargetPlatform.android) {
      return PlatformViewLink(
        viewType: viewType,
        surfaceFactory: (BuildContext context, PlatformViewController controller) {
          return AndroidViewSurface(
            controller: controller,
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
    } else if(defaultTargetPlatform == TargetPlatform.iOS) {
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

   Widget _buildSubscriber(var context) {
    String viewType = 'flutter-vonage-video-subscriber';
    Map<String, dynamic> creationParams = <String, dynamic> {};
    if (defaultTargetPlatform == TargetPlatform.android) {
      return PlatformViewLink(
        viewType: viewType,
        surfaceFactory: (BuildContext context, PlatformViewController controller) {
          return AndroidViewSurface(
            controller: controller,
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
    } else if(defaultTargetPlatform == TargetPlatform.iOS) {
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
    if (_isPublishing) {
      _unpublishStream();
    }
    if (_sessionInited) {
      FlutterVonageVideo.endSession();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget _buttonPublish = SizedBox.shrink();
    if (_sessionInited && !_isPublishing) {
      _buttonPublish = ElevatedButton(
        child: Text('Publish Stream'),
        onPressed: _publishStream,
      );
    }

    Widget _buttonUnpublish = SizedBox.shrink();
    if (_sessionInited && _isPublishing) {
      _buttonUnpublish = ElevatedButton(
        child: Text('Unpublish Stream'),
        onPressed: _unpublishStream,
      );
    }
    Widget _subscribingButton = SizedBox.shrink();
    if (true) {
      _subscribingButton = ElevatedButton(
        child: Text('Subscriber Stream'),
        onPressed: _subscriberStream,
      );
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Vonage Video example app'),
        ),
        body: ListView(
          children: <Widget> [
            _buttonPublish,
            _buttonUnpublish,
            _subscribingButton,
            Container(
              width: 600,
              height: 600,
              child: Stack(
                children: [
                  Container(
                    width: 600,
                    height: 600,
                    child: _buildSubscriber(context),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      height: 100,
                      width: 100,
                      child: _buildPublisher(context),
                    ),
                  ),
                ],
              ),
            ),
          ]
        ),
      ),
    );
  }
}