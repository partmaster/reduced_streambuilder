import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reduced/reduced.dart';
import 'package:reduced_streambuilder/reduced_streambuilder.dart';

class Incrementer extends Reducer<int> {
  @override
  int call(int state) => state + 1;
}

void main() {
  test('Store state 0', () {
    final objectUnderTest = Store(0);
    expect(objectUnderTest.state, 0);
  });

  test('Store state 1', () {
    final objectUnderTest = Store(1);
    expect(objectUnderTest.state, 1);
  });

  test('Store reduce', () async {
    final objectUnderTest = Store(0);
    objectUnderTest.reduce(Incrementer());
    expect(objectUnderTest.state, 1);
  });
}
