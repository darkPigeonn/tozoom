import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'tozoom_method_channel.dart';

abstract class TozoomPlatform extends PlatformInterface {
  /// Constructs a TozoomPlatform.
  TozoomPlatform() : super(token: _token);

  static final Object _token = Object();

  static TozoomPlatform _instance = MethodChannelTozoom();

  /// The default instance of [TozoomPlatform] to use.
  ///
  /// Defaults to [MethodChannelTozoom].
  static TozoomPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [TozoomPlatform] when
  /// they register themselves.
  static set instance(TozoomPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
