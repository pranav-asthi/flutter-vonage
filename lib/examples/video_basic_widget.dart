import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VideoBasicWidget extends StatefulWidget {
  @override
  _VideoBasicWidgetState createState() => _VideoBasicWidgetState();
}

class _VideoBasicWidgetState extends State<VideoBasicWidget> {
  static const MethodChannel methodChannel =
      MethodChannel('flutter_vonage_video');
  //static const EventChannel eventChannel =
  //    EventChannel('samples.flutter.io/charging');

  String _batteryLevel = 'Battery level: unknown.';
  //String _chargingStatus = 'Battery status: unknown.';

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final int? result = await methodChannel.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level: $result%.';
    } on PlatformException {
      batteryLevel = 'Failed to get battery level.';
    }
    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  @override
  void initState() {
    super.initState();
    //eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
  }

  //void _onEvent(Object event) {
  //  setState(() {
  //    _chargingStatus =
  //        "Battery status: ${event == 'charging' ? '' : 'dis'}charging.";
  //  });
  //}

  //void _onError(Object error) {
  //  setState(() {
  //    _chargingStatus = 'Battery status: unknown.';
  //  });
  //}

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(_batteryLevel, key: const Key('Battery level label')),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  child: const Text('Refresh'),
                  onPressed: _getBatteryLevel,
                ),
              ),
            ],
          ),
          //Text(_chargingStatus),
        ],
      ),
    );
  }
}