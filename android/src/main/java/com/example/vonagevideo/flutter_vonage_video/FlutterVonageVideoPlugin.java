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

// import android.os.BatteryManager;
// import android.os.Build.VERSION;
// import android.os.Build.VERSION_CODES;

import com.opentok.android.Session;
import com.opentok.android.Stream;
import com.opentok.android.Publisher;
import com.opentok.android.PublisherKit;
import com.opentok.android.Subscriber;
import com.opentok.android.OpentokError;
// import com.tokbox.android.tutorials.basicvideochat.R;
import android.util.Log;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

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
  private NativeViewFactory native2View;

  private Context mContext;
  private ExecutorService executor
          = Executors.newSingleThreadExecutor();

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_vonage_video");
    channel.setMethodCallHandler(this);

    mContext = flutterPluginBinding.getApplicationContext();

    nativeView = new NativeViewFactory();
    native2View = new NativeViewFactory();
    flutterPluginBinding.getPlatformViewRegistry()
      .registerViewFactory("flutter-vonage-video-publisher", nativeView);
    flutterPluginBinding.getPlatformViewRegistry()
            .registerViewFactory("flutter-vonage-video-subscriber", native2View);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("initSession")) {
      result.success(initSession(call.argument("sessionId"), call.argument("token"), call.argument("apiKey")));
    } else if (call.method.equals("endSession")) {
      result.success(endSession());
    } else if (call.method.equals("publishStream")) {
      result.success(publishStream(call.argument("name")));
    } else if (call.method.equals("unpublishStream")) {
      result.success(unpublishStream());
    } else if (call.method.equals("subscribingStream")) {
      result.success(subscribingStream());
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }



  private static final String LOG_TAG = "flutter-vonage-video-log-tag";
  private static final int RC_SETTINGS_SCREEN_PERM = 123;
  private static final int RC_VIDEO_APP_PERM = 124;

  private Session mSession;
  private Publisher mPublisher;
  private Subscriber mSubscriber;


  private String _sessionId;
  private String _token;
  private String _apiKey;

  private String initSession(String sessionId, String token, String apiKey){
    _sessionId = sessionId;
    _token = token;
    _apiKey = apiKey;
    System.out.println("Esperando");
    Future x = initializeSession();
    while(x.isDone()){};
    System.out.println("Session realizada");
    // requestPermissions();
    return "top";
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


  private Future initializeSession() {
    mSession = new Session.Builder(mContext, _apiKey, _sessionId).build();
    mSession.setSessionListener(this);

    return executor.submit(()-> {
      mSession.connect(_token);
    });
  }

  private String subscribingStream(){
    native2View.getView().addView(mSubscriber.getView());
    mSession.subscribe(mSubscriber);
    return "";
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
    Log.d(LOG_TAG, "onStreamReceived: New Stream Received " + stream.getStreamId() + " in session: " + session.getSessionId());

    if (mSubscriber == null) {
      mSubscriber = new Subscriber.Builder(mContext, stream).build();
      //mSubscriber.getRenderer().setStyle(BaseVideoRenderer.STYLE_VIDEO_SCALE, BaseVideoRenderer.STYLE_VIDEO_FILL);
    }
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
