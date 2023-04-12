import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


abstract class WebsocketClient {
  Stream<int> getCounterStream([int initial]);
}

class FakeWebsocketClient implements WebsocketClient {
  @override
  Stream<int> getCounterStream([int initial = 0]) async* {
    int i = initial;
    while (true) {
      await Future.delayed(const Duration(milliseconds: 500));
      yield i++;
    }
  }
}

final websocketClientLProvider = Provider<WebsocketClient>((ref) {
  return FakeWebsocketClient();
});

// final counterProvider = StateProvider.autoDispose((ref) => 0);
final counterProvider = StreamProvider.family<int, int>((ref, initial) {
  final wsClient = ref.watch(websocketClientLProvider);
  return wsClient.getCounterStream(initial);
});

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CounterPage(),
              ),
            );
          },
          child: const Text('Go to second page'),
        ),
      ),
    );
  }
}

class CounterPage extends ConsumerWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<int> counter = ref.watch(counterProvider(5));

    // ref.listen<int>(
    //   counterProvider,
    //   (previous, next) {
    //     if (next >= 5) {
    //       showDialog(
    //         context: context,
    //         builder: (context) {
    //           return AlertDialog(
    //             title: const Text('Warning'),
    //             content: const Text('Counter dangerously high. Consider resetting it.'),
    //             actions: [
    //               TextButton(
    //                 onPressed: () {
    //                   Navigator.of(context).pop();
    //                 },
    //                 child: const Text('OK'),
    //               ),
    //             ],
    //           );
    //         },
    //       );
    //     }
    //   },
    // );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(counterProvider);
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          // '$counter',
          counter.when(
            data: (value) => '$value',
            loading: () => 'Loading...',
            error: (error, stack) => 'Error: $error',
          ), 
          style: Theme.of(context).textTheme.displayMedium,
        )
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     ref.read(counterProvider.notifier).state++;
      //   },
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
