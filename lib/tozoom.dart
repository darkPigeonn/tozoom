
import 'tozoom_platform_interface.dart';

class Tozoom {
  Future<String?> getPlatformVersion() {
    print('hallo');
    return TozoomPlatform.instance.getPlatformVersion();
  }
}
