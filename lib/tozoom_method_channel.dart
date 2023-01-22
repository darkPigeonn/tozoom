import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'tozoom_platform_interface.dart';

/// An implementation of [TozoomPlatform] that uses method channels.
class MethodChannelTozoom extends TozoomPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('tozoom');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
