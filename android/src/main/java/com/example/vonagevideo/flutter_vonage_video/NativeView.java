package com.example.vonagevideo.flutter_vonage_video;

import android.content.Context;
import android.graphics.Color;
import android.view.View;
// import android.view.ViewGroup;
import android.widget.FrameLayout;
// import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.plugin.platform.PlatformView;
import java.util.Map;

class NativeView implements PlatformView {
   // @NonNull private final TextView textView;
    @NonNull private final FrameLayout view;

    NativeView(@NonNull Context context, int id, @Nullable Map<String, Object> creationParams) {
        // textView = new TextView(context);
        // textView.setText("Rendered on a native Android view (id: " + id + ")");
        view = new FrameLayout(context);
    }

    @NonNull
    @Override
    public FrameLayout getView() {
    // public TextView getView() {
        return view;
    }

    @Override
    public void dispose() {}
}
