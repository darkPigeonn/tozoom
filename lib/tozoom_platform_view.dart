import 'dart:async';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:tozoom/tozoom_options.dart';
import 'package:tozoom/tozoom_view.dart';
export 'tozoom_options.dart';

abstract class ZoomPlatform extends PlatformInterface {
  ZoomPlatform() : super(token: _token);

  static final Object _token = Object();
  static ZoomPlatform _instance = ZoomView();
  static ZoomPlatform get instance => _instance;
  static set instance(ZoomPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<List> initZoom(ZoomOptions options) async {
    throw UnimplementedError('initZoom() has not');
  }
}