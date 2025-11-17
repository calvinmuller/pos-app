import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EasyPay POS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = MethodChannel('com.easypay.pos/pegasus');
  String _response = 'No transaction yet';
  bool _isLoading = false;

  Future<void> _launchPegasusTransaction() async {
    setState(() {
      _isLoading = true;
      _response = 'Launching Pegasus...';
    });

    try {
      final result = await platform.invokeMethod(
        'launchPegasus',
        {
          'TransactionType': 'Purchase',
          'Amount': '2500',
          'CashBackAmount': '0',
          'UniqueId': 'TXN123456789',
          'RefNo': 'REF987654321',
          'IsLocalRequest': 'true',
        },
      );

      final Map<String, dynamic> resultMap = Map<String, dynamic>.from(result as Map);

      setState(() {
        _isLoading = false;
        _response = 'Response:\n${resultMap.entries.map((e) => '${e.key}: ${e.value}').join('\n')}';
      });
    } on PlatformException catch (e) {
      setState(() {
        _isLoading = false;
        _response = 'Error: ${e.message}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('EasyPay POS'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _launchPegasusTransaction,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(20),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text(
                      'Start Transaction',
                      style: TextStyle(fontSize: 18),
                    ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _response,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
