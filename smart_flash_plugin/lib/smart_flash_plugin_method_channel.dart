import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'smart_flash_plugin_platform_interface.dart';

class MethodChannelSmartFlashPlugin extends SmartFlashPluginPlatform {
  @visibleForTesting
  final MethodChannel methodChannel = const MethodChannel('smart_flash_plugin');

  bool get _isSupportedPlatform {
    return !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
  }

  @override
  Future<void> toggleFlash() async {
    if (!_isSupportedPlatform) {
      throw PlatformException(
        code: 'unsupported_platform',
        message: 'Ліхтарик підтримується лише на Android та iOS',
      );
    }

    await methodChannel.invokeMethod('toggleFlash');
  }

  @override
  Future<bool> isFlashSupported() async {
    if (!_isSupportedPlatform) {
      return false;
    }

    final bool? result =
        await methodChannel.invokeMethod<bool>('isFlashSupported');
    return result ?? false;
  }
}