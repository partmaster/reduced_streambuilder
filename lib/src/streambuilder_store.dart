// streambuilder_store.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show BuildContext;
import 'package:reduced/reduced.dart';
import 'package:reduced_streambuilder/src/inherited_widgets.dart';

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

extension StoreOnBuildContext on BuildContext {
  ReducedStore<S> store<S>() =>
      InheritedValueWidget.of<ReducedStore<S>>(this);
  Stream<S> stream<S>() => store<S>().stream;
}
