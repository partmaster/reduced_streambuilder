// streambuilder_store.dart

import 'dart:async';

import 'package:flutter/widgets.dart' show BuildContext;
import 'package:reduced/reduced.dart';
import 'package:reduced_streambuilder/src/inherited_widgets.dart';

class Store<S> implements ReducedStore<S> {
  Store(S initialState)
      : this._(
          initialState,
          StreamController<S>.broadcast(),
        );

  Store._(
    S initialState,
    StreamController<S> controller,
  )   : _state = initialState,
        _controller = controller..add(initialState),
        stream = controller.stream.distinct();

  S _state;
  final StreamController<S> _controller;
  final Stream<S> stream;

  @override
  dispatch(Event<S> event) {
    _state = event(_state);
    _controller.sink.add(_state);
  }

  @override
  get state => _state;

  void dispose() => _controller.close();
}

extension StoreOnBuildContext on BuildContext {
  Store<S> store<S>() => InheritedValueWidget.of<Store<S>>(this);
  Stream<S> stream<S>() => store<S>().stream;
}
