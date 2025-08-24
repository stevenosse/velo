# Velo Example

This example demonstrates how to use the Velo state management package in a Flutter application.

## Features Demonstrated

- **VeloBuilder**: Rebuilds UI when state changes
- **VeloConsumer**: Combines building UI and handling side effects
- **VeloListener**: Performs side effects without rebuilding
- **Async Operations**: Handling loading states and errors
- **State Management**: Using Equatable for efficient state comparisons

## Running the Example

1. Navigate to the example directory:
   ```bash
   cd example
   ```

2. Get dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Code Structure

The example app includes:

- **CounterState**: An immutable state class using Equatable
- **CounterVelo**: A Velo class managing the counter state
- **CounterPage**: The main UI demonstrating all Velo widgets

## Key Concepts

### State Definition
```dart
class CounterState extends Equatable {
  final int count;
  final bool isLoading;
  
  const CounterState({
    this.count = 0,
    this.isLoading = false,
  });
  
  @override
  List<Object?> get props => [count, isLoading];
}
```

### Velo Class
```dart
class CounterVelo extends Velo<CounterState> {
  CounterVelo() : super(const CounterState());
  
  void increment() {
    emit(state.copyWith(count: state.count + 1));
  }
}
```

### Using VeloBuilder
```dart
VeloBuilder<CounterVelo, CounterState>(
  builder: (context, state) {
    return Text('Count: ${state.count}');
  },
)
```

### Using VeloConsumer
```dart
VeloConsumer<CounterVelo, CounterState>(
  listener: (context, state) {
    // Side effects like navigation or showing snackbars
  },
  builder: (context, state) {
    // Build UI based on state
    return Text('Count: ${state.count}');
  },
)
```

## Learn More

For more information about the Velo package, visit the [package documentation](https://pub.dev/packages/velo).
