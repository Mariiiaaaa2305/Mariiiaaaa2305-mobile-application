import Flutter
import UIKit
import AVFoundation

public class SmartFlashPlugin: NSObject, FlutterPlugin {
  private var isTorchOn = false

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "smart_flash_plugin",
      binaryMessenger: registrar.messenger()
    )
    let instance = SmartFlashPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "toggleFlash":
      toggleFlash(result: result)
    case "isFlashSupported":
      result(isFlashSupported())
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func isFlashSupported() -> Bool {
    guard let device = AVCaptureDevice.default(for: .video) else {
      return false
    }
    return device.hasTorch
  }

  private func toggleFlash(result: @escaping FlutterResult) {
    guard let device = AVCaptureDevice.default(for: .video) else {
      result(
        FlutterError(
          code: "NO_DEVICE",
          message: "Камеру не знайдено",
          details: nil
        )
      )
      return
    }

    guard device.hasTorch else {
      result(
        FlutterError(
          code: "NOT_SUPPORTED",
          message: "Ліхтарик недоступний",
          details: nil
        )
      )
      return
    }

    do {
      try device.lockForConfiguration()

      if isTorchOn {
        device.torchMode = .off
        isTorchOn = false
      } else {
        try device.setTorchModeOn(level: 1.0)
        isTorchOn = true
      }

      device.unlockForConfiguration()
      result(nil)
    } catch {
      result(
        FlutterError(
          code: "TORCH_ERROR",
          message: error.localizedDescription,
          details: nil
        )
      )
    }
  }
}