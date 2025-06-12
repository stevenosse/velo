import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';

abstract class Velo<S> extends ValueNotifier<S> {
  Velo(super.state);

  S get state => super.value;

  void emit(S state) {
    // Check equality before emitting to prevent unnecessary rebuilds
    if (state is Equatable) {
      if ((state as Equatable) != (value as Equatable)) {
        value = state;
      }
    } else if (state != value) {
      value = state;
    }
  }

  Future<void> emitAsync(Future<S> futureState) async {
    try {
      final newState = await futureState;
      emit(newState);
    } catch (error) {
      // Let the concrete implementation handle errors
      rethrow;
    }
  }
}
