package com.example.vonagevideo.flutter_vonage_video;

import android.content.Context;
import android.opengl.GLSurfaceView;
import android.util.Log;
import android.view.View;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.constraintlayout.widget.ConstraintLayout;

import com.opentok.android.BaseVideoRenderer;
import com.opentok.android.Connection;
import com.opentok.android.OpentokError;
import com.opentok.android.Publisher;
import com.opentok.android.PublisherKit;
import com.opentok.android.Session;
import com.opentok.android.Stream;
import com.opentok.android.Subscriber;
import com.opentok.android.SubscriberKit;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * FlutterVonageVideoPlugin
 */
public class FlutterVonageVideoPlugin implements FlutterPlugin, MethodCallHandler,
        Session.SessionListener, PublisherKit.PublisherListener, SubscriberKit.SubscriberListener, Session.SignalListener {
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

    private FrameLayout publisherViewContainer;
    private FrameLayout subscriberViewContainer;

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
        //final View v = View.inflate(mContext,R.layout.progress,null);
        //native2View.getView().addView(v);
        ConstraintLayout a = (ConstraintLayout) View.inflate(mContext, R.layout.vonage_view, null);
        publisherViewContainer = a.findViewById(R.id.publisher_container);
        subscriberViewContainer = a.findViewById(R.id.subscriber_container);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "initSession":
                result.success(initSession(call.argument("sessionId"), call.argument("token"), call.argument("apiKey")));
                break;
            case "endSession":
                result.success(endSession());
                break;
            case "publishStream":
                result.success(publishStream(call.argument("name")));
                break;
            case "unpublishStream":
                result.success(unpublishStream());
                break;
            case "subscribingStream":
                result.success(subscribingStream());
                break;
            case "cameraOff":
                result.success(cameraOff());
                break;
            case "muteAudio":
                result.success(muteAudio());
                break;
            case "cycleCamera":
                result.success(cycleCamera());
                break;
            case "sendMessage":
                try {
                    result.success(sendMessage(new JSONObject((String) call.arguments)));
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }


    private static final String LOG_TAG = "Fluttervonage";
    private static final int RC_SETTINGS_SCREEN_PERM = 123;
    private static final int RC_VIDEO_APP_PERM = 124;

    private Session mSession;
    private Publisher mPublisher;
    private Subscriber mSubscriber;


    private String _sessionId;
    private String _token;
    private String _apiKey;

    private String initSession(String sessionId, String token, String apiKey) {
        _sessionId = sessionId;
        _token = token;
        _apiKey = apiKey;
        System.out.println("Esperando");
        Future x = initializeSession();
        while (!x.isDone()) {
        }
        ;
        System.out.println("Session realizada");
        return "top";
    }

    private String publishStream(String name) {
        mPublisher = new Publisher.Builder(mContext).build();
        mPublisher.setPublisherListener(this);
        mPublisher.getRenderer().setStyle(BaseVideoRenderer.STYLE_VIDEO_SCALE, BaseVideoRenderer.STYLE_VIDEO_FILL);

        nativeView.getView().addView(mPublisher.getView());
        if (mPublisher.getView() instanceof GLSurfaceView) {
            ((GLSurfaceView) mPublisher.getView()).setZOrderOnTop(true);
        }
        mSession.publish(mPublisher);
        return "";
    }

    private String unpublishStream() {
        mSession.unpublish(mPublisher);
        nativeView.getView().removeAllViews();
        return "";
    }

    private boolean muteAudio() {
        mPublisher.setPublishAudio(!mPublisher.getPublishAudio());
        return mPublisher.getPublishAudio();
    }

    private boolean cameraOff() {
        mPublisher.setPublishVideo(!mPublisher.getPublishVideo());
        return mPublisher.getPublishVideo();
    }

    private boolean cycleCamera() {
        mPublisher.cycleCamera();
        return true;
    }

    private boolean endSession() {
        mSession.disconnect();
        return true;
    }


    private Future initializeSession() {
        mSession = new Session.Builder(mContext, _apiKey, _sessionId).build();
        mSession.setSessionListener(this);
        mSession.setSignalListener(this);

        return executor.submit(() -> {
            mSession.connect(_token);
        });
    }

    private String subscribingStream() {
        //native2View.getView().removeAllViews();
        View v = View.inflate(mContext, R.layout.progress, null);
        native2View.getView().addView(v);
        if (mSubscriber != null && mSubscriber.getView() != null) {
            native2View.getView().addView(mSubscriber.getView());
            mSession.subscribe(mSubscriber);
        }
        return "";
    }

    // SessionListener methods
    @Override
    public void onConnected(Session session) {
        publishStream("");
        Log.d(LOG_TAG, "Session Connected");
    }

    @Override
    public void onDisconnected(Session session) {
        Log.d(LOG_TAG, "Session Disconnected");
    }

    @Override
    public void onStreamReceived(Session session, Stream stream) {
        Log.d(LOG_TAG, "onStreamReceived: New Stream Received " + stream.getStreamId() + " in session: " + session.getSessionId());
        //native2View.getView().removeAllViews();
        //if (stream != null) {
//    View v = View.inflate(mContext,R.layout.progress,null);
//    native2View.getView().addView(v);
        if (mSubscriber == null) {
            mSubscriber = new Subscriber.Builder(mContext, stream).build();
            mSubscriber.getRenderer().setStyle(BaseVideoRenderer.STYLE_VIDEO_SCALE, BaseVideoRenderer.STYLE_VIDEO_FILL);
            mSubscriber.setSubscriberListener(this);
            session.subscribe(mSubscriber);
            native2View.getView().addView(mSubscriber.getView());
        }
        //} else {
        //  native2View.getView().addView(View.inflate(mContext,R.layout.progress,null));
        //}
    }

    @Override
    public void onStreamDropped(Session session, Stream stream) {
        Log.i(LOG_TAG, "Stream Dropped");
        if (mSubscriber != null) {
            mSubscriber = null;
            native2View.getView().removeAllViews();
//    native2View.getView().addView(View.inflate(mContext,R.layout.progress,null));
        }
    }

    @Override
    public void onError(Session session, OpentokError opentokError) {
        Log.e(LOG_TAG, "Session error: " + opentokError.getMessage());
    }

    // PublisherListener methods
    @Override
    public void onStreamCreated(PublisherKit publisherKit, Stream stream) {
        Log.d(LOG_TAG, "Publisher onStreamCreated");
    }

    @Override
    public void onStreamDestroyed(PublisherKit publisherKit, Stream stream) {
        Log.e(LOG_TAG, "Publisher onStreamDestroyed");
    }

    @Override
    public void onError(PublisherKit publisherKit, OpentokError opentokError) {
        Log.e(LOG_TAG, "Publisher error: " + opentokError.getMessage());
    }

    @Override
    public void onConnected(SubscriberKit subscriberKit) {
        Log.d(LOG_TAG, "Subscriber connected");
    }

    @Override
    public void onDisconnected(SubscriberKit subscriberKit) {
        Log.e(LOG_TAG, "Subscriber disconnected");
    }

    @Override
    public void onError(SubscriberKit subscriberKit, OpentokError opentokError) {
        Log.e(LOG_TAG, "Subscriber error");
    }

    @Override
    public void onSignalReceived(Session session, String s, String s1, Connection connection) {
        Log.d(LOG_TAG,s1);
        onMessageReceived(session, s1, connection);
    }

    private void onMessageReceived(Session session, String s1, Connection connection) {
        try {
            Log.d(LOG_TAG,s1);
            String myConnectionId = session.getConnection().getConnectionId();
            JSONObject msg = new JSONObject(s1);
            if (connection != null && !connection.getConnectionId().equals(myConnectionId)) {
                addMessage(msg);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void addMessage(JSONObject msgObject) {
        try {
            Log.d(LOG_TAG,msgObject.toString());
            channel.invokeMethod("addMessage", msgObject.toString());
        } catch (Exception e) {
            Log.e(LOG_TAG,e.getMessage());
            e.printStackTrace();
        }
    }

    private boolean sendMessage(JSONObject msgObject) {
        try {
            Log.d(LOG_TAG,msgObject.toString());
            mSession.sendSignal("msg", msgObject.toString());
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
