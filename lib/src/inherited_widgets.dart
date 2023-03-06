// inherited_widgets.dart

import 'package:flutter/widgets.dart';

class InheritedValueWidget<V> extends InheritedWidget {
  const InheritedValueWidget({
    super.key,
    required super.child,
    required this.value,
  });

  final V value;

  static U of<U>(BuildContext context) =>
      _widgetOf<InheritedValueWidget<U>>(context).value;

  static W _widgetOf<W extends InheritedValueWidget>(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<W>();
    if (result == null) {
      throw AssertionError('InheritedValueWidget._widgetOf<$W> return null');
    }
    return result;
  }

  @override
  bool updateShouldNotify(InheritedValueWidget oldWidget) =>
      value != oldWidget.value;
}

class StatefulInheritedValueWidget<V> extends StatefulWidget {
  const StatefulInheritedValueWidget(
      {super.key, required this.value, required this.child, this.onDispose});

  final V value;
  final Widget child;
  final VoidCallback? onDispose;

  @override
  State<StatefulInheritedValueWidget> createState() =>
      _StatefulInheritedValueWidgetState<V>();
}

class _StatefulInheritedValueWidgetState<V>
    extends State<StatefulInheritedValueWidget<V>> {
  @override
  Widget build(BuildContext context) => InheritedValueWidget(
        value: widget.value,
        child: widget.child,
      );
  @override
  void dispose() {
    widget.onDispose?.call();
    super.dispose();
  }
}
