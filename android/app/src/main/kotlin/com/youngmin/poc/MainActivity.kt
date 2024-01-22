package com.youngmin.poc

import androidx.annotation.NonNull
import com.youngmin.poc.channels.NearbyConnectionsChannel
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

class MainActivity : FlutterActivity() {
    private lateinit var channels: List<MethodCallHandler>

    override fun configureFlutterEngine(
        @NonNull flutterEngine: FlutterEngine,
    ) {
        super.configureFlutterEngine(flutterEngine)
        channels =
            listOf(
                NearbyConnectionsChannel(this, flutterEngine),
            )
    }
}
