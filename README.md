# Datecs Fiscal device

A pure Dart implementation of the **Datecs Fiscal Device Communication Protocol**.  
This package allows Flutter and Dart applications to communicate directly with Datecs fiscal devices without relying on native platform code.

---

## Features

- 📡 Pure Dart implementation – no platform channels required  
- 🔌 Works across **mobile, desktop, and embedded Dart runtimes**  
- 🧾 Support for sending fiscal commands and parsing device responses  
- 🛠️ Extensible API for custom Datecs protocol commands  
- ⚡ Includes a **partial implementation** for one device model, but designed so you can easily extend or define your own devices and commands  

---

## 🚧 Limitations

- Not all Datecs commands are currently implemented  
- Only one device model is partially supported out of the box  
- You can **extend the package** with custom device definitions or additional commands as needed  


## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  datecs_fiscal: ^0.1.0
```

Then install:

```bash
flutter pub get
```

## Usage

```dart
import 'package:datecs_fiscal/datecs_fiscal.dart';

void main() async {
  // Create a connection
  final comm = BlueCommunication();

  // Connect to the device
  await comm.connect();

  final device = BC50FiscalDevice(comm);

  // Send a simple status request
  final status = await device.getStatus();
  print('Device status: $status');

  await comm.disconnect();
}
```


## Supported Communication

At the moment, the package do no include any communication layer implementation.
You need to provide your own communication layer that implements the `Communication` interface.

## Disclaimer

This package is not affiliated with Datecs Ltd..
It is an independent open-source implementation of the public fiscal communication protocol.
Use at your own risk and always ensure compliance with your local fiscal regulations.
