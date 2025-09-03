package com.marsad.updater

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.os.Build


/** UpdaterPlugin */
class UpdaterPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel for communication between Flutter and native Android
  private lateinit var channel : MethodChannel
  private lateinit var flutterPluginBinding: FlutterPlugin.FlutterPluginBinding

  override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    flutterPluginBinding = binding
    channel = MethodChannel(binding.binaryMessenger, "updater")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "getAppVersion" -> {
        try {
          val context = flutterPluginBinding.applicationContext
          val packageManager: PackageManager = context.packageManager
          val packageName: String = context.packageName

          val info: PackageInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            packageManager.getPackageInfo(packageName, PackageManager.PackageInfoFlags.of(0))
          } else {
            @Suppress("DEPRECATION")
            packageManager.getPackageInfo(packageName, 0)
          }

          val versionName: String = info.versionName ?: "0.0.0"
          val versionCode: Int = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            info.longVersionCode.toInt()
          } else {
            @Suppress("DEPRECATION")
            info.versionCode
          }

          val resultMap: Map<String, Any> = mapOf(
            "versionName" to versionName,
            "versionCode" to versionCode
          )

          result.success(resultMap)
        } catch (e: Exception) {
          result.error("VERSION_ERROR", e.localizedMessage, null)
        }
      }

      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
