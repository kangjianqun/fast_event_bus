import 'package:fast_event_bus/fast_event_bus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("description", () {
    EventBus.getDefault().post("key", "event");
  });
}
