import 'package:equatable/equatable.dart';
import 'package:velo/velo.dart';

class CounterState extends Equatable {
  const CounterState({
    this.count = 0,
    this.isLoading = false,
    this.error,
  });

  final int count;
  final bool isLoading;
  final String? error;

  @override
  List<Object?> get props => [count, isLoading, error];

  CounterState copyWith({
    int? count,
    bool? isLoading,
    String? error,
  }) {
    return CounterState(
      count: count ?? this.count,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class CounterVelo extends Velo<CounterState> {
  CounterVelo() : super(const CounterState());

  void increment() {
    emit(state.copyWith(count: state.count + 1));
  }

  void decrement() {
    emit(state.copyWith(count: state.count - 1));
  }

  Future<void> incrementAsync() async {
    emit(state.copyWith(isLoading: true));
    
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      emit(state.copyWith(
        count: state.count + 1,
        isLoading: false,
      ));
    } catch (error) {
      emit(state.copyWith(
        error: error.toString(),
        isLoading: false,
      ));
    }
  }
}