# flutter_vonage_video

## Install

### Android

Nothing to do!

### iOS

- Update `Info.plist`

```
<key>NSMicrophoneUsageDescription</key>
<string>Mirophone used for video</string>
<key>NSCameraUsageDescription</key>
<string>Camera used for video</string>
```

- Update all iOS deployment targets (including for ALL pods) to `10.0`
	- can do this in xCode manually or find and replace `DEPLOYMENT_TARGET = 9.0;` with `DEPLOYMENT_TARGET = 10.0;` in `ios/Pods/Pods.xcodeproj/project.pbxproj`
