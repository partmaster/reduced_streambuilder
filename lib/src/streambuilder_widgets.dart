// streambuilder_wrapper.dart

import 'package:flutter/widgets.dart';
import 'package:reduced/reduced.dart';

import 'async_snapshot_builder.dart';
import 'inherited_widgets.dart';
import 'streambuilder_store.dart';

class ReducedProvider<S> extends StatelessWidget {
  ReducedProvider({
    super.key,
    required S initialState,
    EventListener? onEventDispatched,
    required this.child,
  }) : store = Store(initialState, onEventDispatched);

  final Store<S> store;
  final Widget child;

  @override
  Widget build(BuildContext context) => StatefulInheritedValueWidget(
        value: store,
        onDispose: store.dispose,
        child: child,
      );
}

class ReducedConsumer<S, P> extends StatelessWidget {
  const ReducedConsumer({
    super.key,
    required this.builder,
    required this.transformer,
  });

  final ReducedWidgetBuilder<P> builder;
  final ReducedTransformer<S, P> transformer;

  @override
  Widget build(BuildContext context) => _build(context.store<S>());

  Widget _build(Store<S> store) => __build(store, transformer(store));

  Widget __build(Store<S> store, P initialValue) => StreamBuilder<P>(
        stream: _skipInitialValue(
          store.stream.map((e) => transformer(store)),
          initialValue,
        ).distinct(),
        builder: AsyncSnapshotBuilder.reduced(
          initialValue: initialValue,
          builder: builder,
        ),
      );
}

Stream<T> _skipInitialValue<T>(
  Stream<T> stream,
  T initialValue,
) async* {
  await for (final value in stream) {
    if (value != initialValue) {
      yield value;
      break;
    }
  }
  await for (final value in stream) {
    yield value;
  }
}
