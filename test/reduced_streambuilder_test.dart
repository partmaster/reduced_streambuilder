import 'package:flutter_test/flutter_test.dart';
import 'package:reduced/reduced.dart';
import 'package:reduced_streambuilder/reduced_streambuilder.dart';

class CounterIncremented extends Event<int> {
  @override
  int call(int state) => state + 1;
}

void main() {
  test('ReducedStore state 0', () {
    final objectUnderTest = ReducedStore(0);
    expect(objectUnderTest.state, 0);
  });

  test('ReducedStore state 1', () {
    final objectUnderTest = ReducedStore(1);
    expect(objectUnderTest.state, 1);
  });

  test('ReducedStore process', () async {
    final objectUnderTest = ReducedStore(0);
    objectUnderTest.process(CounterIncremented());
    expect(objectUnderTest.state, 1);
  });
}
