# reduced_streambuilder

Implementation of the 'reduced' API with StreamController and StreamBuilder with following features:

1. Implementation of the ```Store``` interface 
2. Register a state for management.
3. Trigger a rebuild on widgets selectively after a state change.

## Features

#### 1. Implementation of the ```Store``` interface 

```dart
class ReducedStore<S> implements Store<S> {
  ReducedStore(S initialState, [EventListener<S>? onEventDispatched])
      : this._(
          initialState,
          onEventDispatched,
          StreamController<S>.broadcast(),
        );

  ReducedStore._(
    S initialState,
    EventListener<S>? onEventDispatched,
    StreamController<S> controller,
  )   : _state = initialState,
        _onEventDispatched = onEventDispatched,
        _controller = controller..add(initialState),
        stream = controller.stream.distinct();

  S _state;
  final StreamController<S> _controller;
  final Stream<S> stream;
  final EventListener<S>? _onEventDispatched;

  @override
  process(Event<S> event) {
    _state = event(_state);
    _onEventDispatched?.call(this, event, UniqueKey());
    _controller.sink.add(_state);
  }

  @override
  get state => _state;

  void dispose() => _controller.close();
}
```

```dart
extension StoreOnBuildContext on BuildContext {
  ReducedStore<S> store<S>() =>
      InheritedValueWidget.of<ReducedStore<S>>(this);
  Stream<S> stream<S>() => store<S>().stream;
}
```

#### 2. Register a state for management.

```dart
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
```

#### 3. Trigger a rebuild on widgets selectively after a state change.


```dart
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
```

```dart
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
```

## Getting started

In the pubspec.yaml add dependencies on the package 'reduced' and on the package 'reduced_streambuilder'.

```
dependencies:
  reduced: 0.4.0
  reduced_streambuilder: 
    git:
      url: https://github.com/partmaster/reduced_streambuilder.git
      ref: v0.4.0
```

Import package 'reduced' to implement the logic.

```dart
import 'package:reduced/reduced.dart';
```

Import package 'reduced' to use the logic.

```dart
import 'package:reduced_streambuilder/reduced_streambuilder.dart';
```

## Usage

Implementation of the counter demo app logic with the 'reduced' API without further dependencies on state management packages.

```dart
// logic.dart

import 'package:flutter/material.dart';
import 'package:reduced/reduced.dart';
import 'package:reduced/callbacks.dart';

class CounterIncremented extends Event<int> {
  @override
  int call(int state) => state + 1;
}

class Props {
  const Props({required this.counterText, required this.onPressed});

  final String counterText;
  final VoidCallable onPressed;
}

class PropsMapper extends Props {
  PropsMapper(int state, EventProcessor<int> processor)
      : super(
          counterText: '$state',
          onPressed: EventCarrier(processor, CounterIncremented()),
        );
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.props});

  final Props props;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('reduced_streambuilder example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'You have pushed the button this many times:',
              ),
              Text(props.counterText),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: props.onPressed,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ),
      );
}
```

Finished counter demo app using logic.dart and 'reduced_streambuilder' package:

```dart
// main.dart

import 'package:flutter/material.dart';
import 'package:reduced_streambuilder/reduced_streambuilder.dart';

import 'logic.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => ReducedProvider(
        initialState: 0,
        child: MaterialApp(
          theme: ThemeData(primarySwatch: Colors.blue),
          home:  ReducedConsumer(
            mapper: PropsMapper.new,
            builder: MyHomePage.new,
          ),
        ),
      );
}
```

# Additional information

Implementations of the 'reduced' API are available for the following state management frameworks:

|framework|implementation package for 'reduced' API|
|---|---|
|[Binder](https://pub.dev/packages/binder)|[reduced_binder](https://github.com/partmaster/reduced_binder)|
|[Bloc](https://bloclibrary.dev/#/)|[reduced_bloc](https://github.com/partmaster/reduced_bloc)|
|[FlutterCommand](https://pub.dev/packages/flutter_command)|[reduced_fluttercommand](https://github.com/partmaster/reduced_fluttercommand)|
|[FlutterTriple](https://pub.dev/packages/flutter_triple)|[reduced_fluttertriple](https://github.com/partmaster/reduced_fluttertriple)|
|[GetIt](https://pub.dev/packages/get_it)|[reduced_getit](https://github.com/partmaster/reduced_getit)|
|[GetX](https://pub.dev/packages/get)|[reduced_getx](https://github.com/partmaster/reduced_getx)|
|[MobX](https://pub.dev/packages/mobx)|[reduced_mobx](https://github.com/partmaster/reduced_mobx)|
|[Provider](https://pub.dev/packages/provider)|[reduced_provider](https://github.com/partmaster/reduced_provider)|
|[Redux](https://pub.dev/packages/redux)|[reduced_redux](https://github.com/partmaster/reduced_redux)|
|[Riverpod](https://riverpod.dev/)|[reduced_riverpod](https://github.com/partmaster/reduced_riverpod)|
|[Solidart](https://pub.dev/packages/solidart)|[reduced_solidart](https://github.com/partmaster/reduced_solidart)|
|[StatesRebuilder](https://pub.dev/packages/states_rebuilder)|[reduced_statesrebuilder](https://github.com/partmaster/reduced_statesrebuilder)|
