import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reduced/reduced.dart';
import 'package:reduced_streambuilder/reduced_streambuilder.dart';

class Incrementer extends Reducer<int> {
  @override
  int call(int state) => state + 1;
}

void main() {
  test('ReducibleBloc state 0', () {
    final objectUnderTest = Store(0);
    expect(objectUnderTest.state, 0);
  });

  test('ReducibleBloc state 1', () {
    final objectUnderTest = Store(1);
    expect(objectUnderTest.state, 1);
  });

  test('ReducibleBloc reduce', () async {
    final objectUnderTest = Store(0);
    objectUnderTest.reduce(Incrementer());
    expect(objectUnderTest.state, 1);
  });

  test('wrapWithProvider', () {
    const child = SizedBox();
    final objectUnderTest = wrapWithProvider(
      initialState: 0,
      child: child,
    );
    expect(objectUnderTest, isA<StatefulInheritedValueWidget<Store<int>>>());
    final provider =
        objectUnderTest as StatefulInheritedValueWidget<Store<int>>;
    expect(provider.child, child);
    final store = provider.value;
    expect(store.state, 0);
  });

  test('wrapWithConsumer', () {
    const child = SizedBox();
    final objectUnderTest = wrapWithConsumer<int, int>(
      builder: ({Key? key, required int props}) => child,
      transformer: (reducible) => 1,
    );
    expect(objectUnderTest, isA<Builder>());
  });
}
