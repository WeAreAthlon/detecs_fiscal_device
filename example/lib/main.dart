import 'package:datecs_fiscal_device/datecs_fiscal_device.dart';
import 'package:example/custom_communication.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late BC50FiscalDevice device;

  @override
  void initState() {
    super.initState();

    final comm = CustomCommunication();
    comm.connect();

    device = BC50FiscalDevice(comm);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Datecs Pay Flutter',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        appBar: AppBar(title: const Text('Flutter Example')),
        body: Column(
          children: [
            FilledButton(
              onPressed: () async {
                final status = await device.getStatus();
                debugPrint(status.toString());
              },
              child: Text("Connect"),
            ),
          ],
        ),
      ),
    );
  }
}
