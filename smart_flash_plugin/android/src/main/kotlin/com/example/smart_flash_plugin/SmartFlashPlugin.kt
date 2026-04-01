package com.example.smart_flash_plugin

import android.content.Context
import android.content.pm.PackageManager
import android.hardware.camera2.CameraAccessException
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraManager
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class SmartFlashPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    private var cameraManager: CameraManager? = null
    private var cameraId: String? = null
    private var isTorchOn = false

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "smart_flash_plugin")
        channel.setMethodCallHandler(this)

        cameraManager = context.getSystemService(Context.CAMERA_SERVICE) as CameraManager
        cameraId = findCameraWithFlash()
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "toggleFlash" -> toggleFlash(result)
            "isFlashSupported" -> result.success(isFlashSupported())
            else -> result.notImplemented()
        }
    }

    private fun isFlashSupported(): Boolean {
        return context.packageManager.hasSystemFeature(PackageManager.FEATURE_CAMERA_FLASH) &&
            cameraId != null
    }

    private fun findCameraWithFlash(): String? {
        return try {
            val manager = cameraManager ?: return null

            for (id in manager.cameraIdList) {
                val characteristics = manager.getCameraCharacteristics(id)
                val hasFlash = characteristics.get(
                    CameraCharacteristics.FLASH_INFO_AVAILABLE
                ) == true

                if (hasFlash) {
                    return id
                }
            }

            null
        } catch (e: Exception) {
            null
        }
    }

    private fun toggleFlash(result: Result) {
        try {
            if (!isFlashSupported()) {
                result.error(
                    "NOT_SUPPORTED",
                    "Ліхтарик недоступний на цьому пристрої",
                    null
                )
                return
            }

            val manager = cameraManager ?: run {
                result.error("NO_MANAGER", "CameraManager недоступний", null)
                return
            }

            val id = cameraId ?: run {
                result.error("NO_CAMERA_ID", "Камеру з ліхтариком не знайдено", null)
                return
            }

            isTorchOn = !isTorchOn
            manager.setTorchMode(id, isTorchOn)
            result.success(null)
        } catch (e: CameraAccessException) {
            result.error("CAMERA_ACCESS_ERROR", e.message, null)
        } catch (e: Exception) {
            result.error("UNKNOWN_ERROR", e.message, null)
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}