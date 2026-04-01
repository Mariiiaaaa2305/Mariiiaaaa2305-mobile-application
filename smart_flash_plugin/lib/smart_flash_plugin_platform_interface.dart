import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'smart_flash_plugin_method_channel.dart';

abstract class SmartFlashPluginPlatform extends PlatformInterface {
  SmartFlashPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static SmartFlashPluginPlatform _instance = MethodChannelSmartFlashPlugin();

  static SmartFlashPluginPlatform get instance => _instance;

  static set instance(SmartFlashPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> toggleFlash();

  Future<bool> isFlashSupported();
}