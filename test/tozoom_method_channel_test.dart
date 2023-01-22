import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tozoom/tozoom_method_channel.dart';

void main() {
  MethodChannelTozoom platform = MethodChannelTozoom();
  const MethodChannel channel = MethodChannel('tozoom');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
