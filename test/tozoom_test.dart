import 'package:flutter_test/flutter_test.dart';
import 'package:tozoom/tozoom.dart';
import 'package:tozoom/tozoom_platform_interface.dart';
import 'package:tozoom/tozoom_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockTozoomPlatform
    with MockPlatformInterfaceMixin
    implements TozoomPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final TozoomPlatform initialPlatform = TozoomPlatform.instance;

  test('$MethodChannelTozoom is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelTozoom>());
  });

  test('getPlatformVersion', () async {
    Tozoom tozoomPlugin = Tozoom();
    MockTozoomPlatform fakePlatform = MockTozoomPlatform();
    TozoomPlatform.instance = fakePlatform;

    expect(await tozoomPlugin.getPlatformVersion(), '42');
  });
}
