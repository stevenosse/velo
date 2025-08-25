import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velo/velo.dart';
import 'sample-velo.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<CounterVelo>(
      create: (_) => CounterVelo(),
      dispose: (_, velo) => velo.dispose(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Counter')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              VeloBuilder<CounterVelo, CounterState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const CircularProgressIndicator();
                  }
                  return Text(
                    '${state.count}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  );
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => context.read<CounterVelo>().decrement(),
                    child: const Text('-'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () => context.read<CounterVelo>().increment(),
                    child: const Text('+'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}