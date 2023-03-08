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
    required this.child,
  }) : store = Store(initialState);

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

  Widget _build(Store<S> store) => StreamBuilder<P>(
        stream: store.stream.map((e) => transformer(store)).distinct(),
        builder: AsyncSnapshotBuilder(
          initialValue: transformer(store),
          data: (_, data) => builder(props: data),
        ),
      );
}
