// streambuilder_wrapper.dart

import 'package:flutter/widgets.dart';
import 'package:reduced/reduced.dart';

import 'inherited_widgets.dart';
import 'streambuilder_reducible.dart';

typedef ErrorWidgetBuilder = Widget Function(
  BuildContext context,
  Object error,
);

typedef DataWidgetBuilder<P> = Widget Function(
  BuildContext context,
  P data,
);

typedef WaitingWidgetBuilder<P> = Widget Function(
  BuildContext context,
);

typedef DoneWidgetBuilder<P> = Widget Function(
  BuildContext context,
  P? data,
);

class AsyncSnapshotBuilder<P> {
  AsyncSnapshotBuilder({
    required P initialValue,
    required this.error,
    required this.data,
    required this.waiting,
    required this.done,
  }) : value = initialValue;

  AsyncSnapshotBuilder.reduced(
      P initialValue, ReducedWidgetBuilder builder)
      : this(
          initialValue: initialValue,
          data: (_, data) => builder(props: data),
          error: null,
          waiting: null,
          done: null,
        );

  final ErrorWidgetBuilder? error;
  final DataWidgetBuilder<P> data;
  final WaitingWidgetBuilder? waiting;
  final DoneWidgetBuilder? done;
  P value;

  Widget fallback(BuildContext context) => data(context, value);

  Widget call(BuildContext context, AsyncSnapshot<P> snapshot) {
    final state = snapshot.connectionState;
    final errorValue = snapshot.error;
    if (errorValue != null) {
      final errorBuilder = error;
      return errorBuilder != null
          ? errorBuilder(context, errorValue)
          : fallback(context);
    }
    final dataValue = snapshot.data;
    if (dataValue != null) {
      value = dataValue;
      return data(context, dataValue);
    }
    final errorBuilder = error;
    final doneBuilder = done;
    final waitingBuilder = waiting;
    switch (state) {
      case ConnectionState.active:
      case ConnectionState.none:
        return errorBuilder != null
            ? errorBuilder(context, state)
            : fallback(context);
      case ConnectionState.done:
        return doneBuilder != null
            ? doneBuilder(context, value)
            : fallback(context);
      case ConnectionState.waiting:
        return waitingBuilder != null
            ? waitingBuilder(context)
            : fallback(context);
    }
  }
}

Widget wrapWithProvider<S>({
  required S initialState,
  required Widget child,
}) =>
    _wrapWithProvider(
      store: Store(initialState),
      child: child,
    );

Widget _wrapWithProvider<S>({
  required Store<S> store,
  required Widget child,
}) =>
    StatefulInheritedValueWidget(
      value: store,
      onDispose: store.dispose,
      child: child,
    );

Widget wrapWithConsumer<S, P extends Object>({
  required AsyncSnapshotBuilder<P> builder,
  required ReducedTransformer<S, P> transformer,
}) =>
    Builder(
      builder: (context) => _wrapWithConsumer(
        builder: builder,
        transformer: transformer,
        store: context.store<S>(),
      ),
    );

Widget _wrapWithConsumer<S, P extends Object>({
  required AsyncSnapshotBuilder<P> builder,
  required ReducedTransformer<S, P> transformer,
  required Store<S> store,
}) =>
    StreamBuilder<P>(
      stream: store.stream.map((e) => transformer(store)).distinct(),
      builder: builder,
    );
