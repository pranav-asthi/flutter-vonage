package com.example.vonagevideo.flutter_vonage_video;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.platform.PlatformView;

import io.flutter.plugin.common.BinaryMessenger;

import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
// import android.os.BatteryManager;
// import android.os.Build.VERSION;
// import android.os.Build.VERSION_CODES;
import android.os.Bundle;

import com.opentok.android.Session;
import com.opentok.android.Stream;
import com.opentok.android.Publisher;
import com.opentok.android.PublisherKit;
import com.opentok.android.Subscriber;
import com.opentok.android.BaseVideoRenderer;
import com.opentok.android.OpentokError;
import com.opentok.android.SubscriberKit;
// import com.tokbox.android.tutorials.basicvideochat.R;
import android.util.Log;
import android.Manifest;

import java.util.List;

// import pub.devrel.easypermissions.AfterPermissionGranted;
// import pub.devrel.easypermissions.AppSettingsDialog;
// import pub.devrel.easypermissions.EasyPermissions;

import android.content.Context;

/** FlutterVonageVideoPlugin */
public class FlutterVonageVideoPlugin implements FlutterPlugin, MethodCallHandler,
  Session.SessionListener, PublisherKit.PublisherListener {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private NativeViewFactory nativeView;

  private Context mContext;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_vonage_video");
    channel.setMethodCallHandler(this);

    mContext = flutterPluginBinding.getApplicationContext();

    nativeView = new NativeViewFactory();
    flutterPluginBinding.getPlatformViewRegistry()
      .registerViewFactory("flutter-vonage-video-publisher", nativeView);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    // if (call.method.equals("getPlatformVersion")) {
    //   result.success("Android " + android.os.Build.VERSION.RELEASE);
    // } else if (call.method.equals("getBatteryLevel")) {
    //   int batteryLevel = getBatteryLevel();
    //   if (batteryLevel != -1) {
    //     result.success(batteryLevel);
    //   } else {
    //     result.error("UNAVAILABLE", "Battery level not available.", null);
    //   }
    if (call.method.equals("initSession")) {
      result.success(initSession(call.argument("sessionId"), call.argument("token"), call.argument("apiKey")));
    } else if (call.method.equals("endSession")) {
      result.success(endSession());
    } else if (call.method.equals("publishStream")) {
      result.success(publishStream(call.argument("name")));
    } else if (call.method.equals("unpublishStream")) {
      result.success(unpublishStream());
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

//   private int getBatteryLevel() {
//     int batteryLevel = -1;
//     if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
// //      BatteryManager batteryManager = (BatteryManager) getSystemService(BATTERY_SERVICE);
// //      batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY);
//       batteryLevel = BatteryManager.BATTERY_PROPERTY_CAPACITY;
// //    } else {
// //      Intent intent = new ContextWrapper(getApplicationContext()).
// //              registerReceiver(null, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
// //      batteryLevel = (intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100) /
// //              intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1);
//     }

//     return batteryLevel;
//   }


  private static final String LOG_TAG = "flutter-vonage-video-log-tag";
  private static final int RC_SETTINGS_SCREEN_PERM = 123;
  private static final int RC_VIDEO_APP_PERM = 124;

  private Session mSession;
  private Publisher mPublisher;

  private String _sessionId;
  private String _token;
  private String _apiKey;

  private String initSession(String sessionId, String token, String apiKey) {
    _sessionId = sessionId;
    _token = token;
    _apiKey = apiKey;
    initializeSession();
    // requestPermissions();
    return "";
  }

  private String publishStream(String name) {
    mPublisher = new Publisher.Builder(mContext).name(name).build();
    mPublisher.setPublisherListener(this);

    // nativeView.getView().setText("publish stream");
    nativeView.getView().addView(mPublisher.getView());

    mSession.publish(mPublisher);
    return "";
  }

  private String unpublishStream() {
    mSession.unpublish(mPublisher);
    nativeView.getView().removeAllViews();
    return "";
  }

  private String endSession() {
    mSession.disconnect();
    return "";
  }

  // @Override
  // public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
  //   super.onRequestPermissionsResult(requestCode, permissions, grantResults);
  //   EasyPermissions.onRequestPermissionsResult(requestCode, permissions, grantResults, mContext);
  // }

  // @AfterPermissionGranted(RC_VIDEO_APP_PERM)
  // private void requestPermissions() {
  //   String[] perms = { Manifest.permission.INTERNET, Manifest.permission.CAMERA, Manifest.permission.RECORD_AUDIO };
  //   if (EasyPermissions.hasPermissions(mContext, perms)) {
  //     // initialize view objects from your layout


  //     // initialize and connect to the session
  //     initializeSession();
  //   } else {
  //       EasyPermissions.requestPermissions(mContext, "This app needs access to your camera and mic to make video calls", RC_VIDEO_APP_PERM, perms);
  //   }
  // }

  // @Override
  // public void onPermissionsGranted(int requestCode, List<String> perms) {
  //   Log.d(LOG_TAG, "onPermissionsGranted:" + requestCode + ":" + perms.size());
  // }

  // @Override
  // public void onPermissionsDenied(int requestCode, List<String> perms) {
  //   Log.d(LOG_TAG, "onPermissionsDenied:" + requestCode + ":" + perms.size());
  //   if (EasyPermissions.somePermissionPermanentlyDenied(mContext, perms)) {
  //     new AppSettingsDialog.Builder(mContext)
  //       .setTitle(getString(R.string.title_settings_dialog))
  //       .setRationale(getString(R.string.rationale_ask_again))
  //       .setPositiveButton(getString(R.string.setting))
  //       .setNegativeButton(getString(R.string.cancel))
  //       .setRequestCode(RC_SETTINGS_SCREEN_PERM)
  //       .build()
  //       .show();
  //   }
  // }

  private void initializeSession() {
    mSession = new Session.Builder(mContext, _apiKey, _sessionId).build();
    mSession.setSessionListener(this);
    mSession.connect(_token);
  }

  // SessionListener methods
  @Override
  public void onConnected(Session session) {
    Log.i(LOG_TAG, "Session Connected");
  }

  @Override
  public void onDisconnected(Session session) {
    Log.i(LOG_TAG, "Session Disconnected");
  }

  @Override
  public void onStreamReceived(Session session, Stream stream) {
    Log.i(LOG_TAG, "Stream Received");
  }

  @Override
  public void onStreamDropped(Session session, Stream stream) {
    Log.i(LOG_TAG, "Stream Dropped");
  }

  @Override
  public void onError(Session session, OpentokError opentokError) {
    Log.e(LOG_TAG, "Session error: " + opentokError.getMessage());
  }

  // PublisherListener methods
  @Override
  public void onStreamCreated(PublisherKit publisherKit, Stream stream) {
    Log.i(LOG_TAG, "Publisher onStreamCreated");
  }

  @Override
  public void onStreamDestroyed(PublisherKit publisherKit, Stream stream) {
    Log.i(LOG_TAG, "Publisher onStreamDestroyed");
  }

  @Override
  public void onError(PublisherKit publisherKit, OpentokError opentokError) {
    Log.e(LOG_TAG, "Publisher error: " + opentokError.getMessage());
  }

}
