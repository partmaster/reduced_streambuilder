// props.dart

import 'package:reduced/reduced.dart';

class MyHomePageProps {
  MyHomePageProps({
    required this.onPressed,
    required this.title,
  });

  final String title;
  final Callable<void> onPressed;

  @override
  get hashCode => Object.hash(title, onPressed);

  @override
  operator ==(other) =>
      other is MyHomePageProps &&
      title == other.title &&
      onPressed == other.onPressed;

  @override
  String toString() {
    return 'MyHomePageProps(hashCode=$hashCode)';
  }
}

class MyCounterWidgetProps {
  MyCounterWidgetProps({
    required this.counterText,
  });

  final String counterText;

  @override
  get hashCode => counterText.hashCode;

  @override
  operator ==(other) =>
      other is MyCounterWidgetProps && counterText == other.counterText;

  @override
  String toString() {
    return 'MyCounterWidgetProps(hashCode=$hashCode counterText=$counterText)';
  }
}
