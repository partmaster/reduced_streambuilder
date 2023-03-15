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
  }) : store = ReducedStore(initialState, onEventDispatched);

  final ReducedStore<S> store;
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
    required this.mapper,
  });

  final WidgetFromPropsBuilder<P> builder;
  final StateToPropsMapper<S, P> mapper;

  @override
  Widget build(BuildContext context) => _build(context.store<S>());

  Widget _build(ReducedStore<S> store) => __build(
        store,
        mapper(store.state, store),
      );

  Widget __build(ReducedStore<S> store, P initialValue) =>
      StreamBuilder<P>(
        stream: _skipInitialValue(
          store.stream.map((e) => mapper(store.state, store)),
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
