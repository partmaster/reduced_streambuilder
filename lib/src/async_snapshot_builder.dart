// async_snapshot_builder.dart

import 'package:flutter/widgets.dart';
import 'package:reduced/reduced.dart';

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
    required this.data,
    this.error,
    this.waiting,
    this.done,
  }) : value = initialValue;

  AsyncSnapshotBuilder.reduced({
    required P initialValue,
    required ReducedWidgetBuilder<P> builder,
  }) : this(
          initialValue: initialValue,
          data: (_, data) => builder(props: data),
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
