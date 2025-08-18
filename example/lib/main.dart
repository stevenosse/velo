import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velo/velo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
      title: 'Velo Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Provider<CounterVelo>(
        create: (_) => CounterVelo(),
        dispose: (_, velo) => velo.dispose(),
        child: const CounterPage(),
      ),
    );
}

// State class using Equatable for efficient comparisons
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
  }) => CounterState(
      count: count ?? this.count,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
}

// Velo class for state management
class CounterVelo extends Velo<CounterState> {
  CounterVelo() : super(const CounterState());

  void increment() {
    emit(state.copyWith(count: state.count + 1));
  }

  void decrement() {
    emit(state.copyWith(count: state.count - 1));
  }

  void reset() {
    emit(const CounterState());
  }

  Future<void> incrementAsync() async {
    emit(state.copyWith(isLoading: true));
    
    try {
      // Simulate async operation
      await Future<void>.delayed(const Duration(seconds: 1));
      
      emit(state.copyWith(
        count: state.count + 1,
        isLoading: false,
      ));
    } on Exception catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to increment: $e',
      ));
    }
  }

  Future<void> decrementAsync() async {
    emit(state.copyWith(isLoading: true));
    
    try {
      // Simulate async operation
      await Future<void>.delayed(const Duration(seconds: 1));
      
      if (state.count == 0) {
        throw Exception('Cannot go below zero');
      }
      
      emit(state.copyWith(
        count: state.count - 1,
        isLoading: false,
      ));
    } on Exception catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }
}

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Velo Counter Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Counter Value:',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16),
            
            // VeloConsumer: Combines builder and listener
            VeloConsumer<CounterVelo, CounterState>(
              listener: (context, state) {
                // Show snackbar for specific state changes
                if (state.count == 10) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🎉 You reached 10!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
                
                if (state.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${state.error}'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state.isLoading) {
                  return const CircularProgressIndicator();
                }
                
                return Text(
                  '${state.count}',
                  style: Theme.of(context).textTheme.displayLarge,
                );
              },
            ),
            
            const SizedBox(height: 48),
            
            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Decrement button with VeloBuilder
                VeloBuilder<CounterVelo, CounterState>(
                  builder: (context, state) => ElevatedButton.icon(
                      onPressed: state.isLoading 
                        ? null 
                        : () => context.read<CounterVelo>().decrement(),
                      icon: const Icon(Icons.remove),
                      label: const Text('Decrement'),
                    ),
                ),
                
                const SizedBox(width: 16),
                
                // Increment button
                Builder(
                  builder: (context) => ElevatedButton.icon(
                      onPressed: () => context.read<CounterVelo>().increment(),
                      icon: const Icon(Icons.add),
                      label: const Text('Increment'),
                    ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Async operations
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Async decrement with VeloListener for side effects
                VeloListener<CounterVelo, CounterState>(
                  listener: (context, state) {
                    // Could perform side effects here
                  },
                  child: Builder(
                    builder: (context) => ElevatedButton.icon(
                        onPressed: () => context.read<CounterVelo>().decrementAsync(),
                        icon: const Icon(Icons.timer),
                        label: const Text('Async -1'),
                      ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Async increment
                Builder(
                  builder: (context) => ElevatedButton.icon(
                      onPressed: () => context.read<CounterVelo>().incrementAsync(),
                      icon: const Icon(Icons.timer),
                      label: const Text('Async +1'),
                    ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Reset button
            Builder(
              builder: (context) => TextButton.icon(
                  onPressed: () => context.read<CounterVelo>().reset(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                ),
            ),
            
            const SizedBox(height: 48),
            
            // Additional information
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'This example demonstrates:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• VeloBuilder for rebuilding UI\n'
                      '• VeloConsumer for combined building & listening\n'
                      '• VeloListener for side effects\n'
                      '• Async state management\n'
                      '• Error handling\n'
                      '• Loading states',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
}
