package com.example.vonagevideo.flutter_vonage_video;

import android.content.Context;
import android.view.View;
// import android.view.ViewGroup;
import android.widget.FrameLayout;
import androidx.annotation.Nullable;
import androidx.annotation.NonNull;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;
import java.util.Map;

// import android.widget.TextView;

class NativeViewFactory extends PlatformViewFactory {
    NativeView platformView;
  // @NonNull private final BinaryMessenger messenger;
  // @NonNull private final View containerView;

  // NativeViewFactory(@NonNull BinaryMessenger messenger, @NonNull View containerView) {
  //   super(StandardMessageCodec.INSTANCE);
  //   this.messenger = messenger;
  //   this.containerView = containerView;
  // }
  NativeViewFactory() {
    super(StandardMessageCodec.INSTANCE);
  }

  @NonNull
  @Override
  public NativeView create(@NonNull Context context, int id, @Nullable Object args) {
    final Map<String, Object> creationParams = (Map<String, Object>) args;
    platformView = new NativeView(context, id, creationParams);
    return platformView;
  }

  public FrameLayout getView() {
    return platformView.getView();
  }
}
