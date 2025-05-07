import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:app/menupage.dart';

class ConnectPage extends StatefulWidget {
  const ConnectPage({super.key});

  @override
  State<ConnectPage> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  // No longer need instance property
  BluetoothAdapterState _bluetoothState = BluetoothAdapterState.unknown;
  final List<ScanResult> _devicesList = [];
  BluetoothDevice? _selectedDevice;
  bool _isConnected = false;
  bool _isScanning = false;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _adapterStateSubscription?.cancel();
    _connectionStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initBluetooth() async {
    // Get current state
    _bluetoothState = await FlutterBluePlus.adapterState.first;

    // Listen for adapter state changes
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      setState(() {
        _bluetoothState = state;
      });
    });
  }

  Future<void> _startScan() async {
    if (_isScanning) {
      await _stopScan();
    }

    setState(() {
      _devicesList.clear();
      _isScanning = true;
    });

    try {
      // Request permission (this is simplified)
      bool permissionGranted = await _requestPermissions();
      if (!permissionGranted) {
        setState(() {
          _isScanning = false;
        });
        return;
      }

      // Start scanning
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));

      // Listen for scan results
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        setState(() {
          for (ScanResult result in results) {
            // Only add devices with names (optional filter)
            if (result.device.advName.isNotEmpty) {
              // Update existing or add new
              final existingIndex = _devicesList.indexWhere(
                      (element) => element.device.remoteId == result.device.remoteId
              );

              if (existingIndex >= 0) {
                _devicesList[existingIndex] = result;
              } else {
                _devicesList.add(result);
              }
            }
          }
        });
      });

      // When scan completes
      FlutterBluePlus.isScanning.listen((isScanning) {
        if (!isScanning) {
          setState(() {
            _isScanning = false;
          });
        }
      });
    } catch (ex) {
      print('Error starting scan: $ex');
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _stopScan() async {
    await FlutterBluePlus.stopScan();
    _scanSubscription?.cancel();
    setState(() {
      _isScanning = false;
    });
  }

  Future<bool> _requestPermissions() async {
    // In a real app, you would handle permissions properly using
    // packages like permission_handler
    return true;
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      setState(() {
        _selectedDevice = device;
      });

      // Connect to device
      await device.connect(timeout: const Duration(seconds: 10));

      // Listen to connection state changes
      _connectionStateSubscription = device.connectionState.listen((state) {
        setState(() {
          _isConnected = state == BluetoothConnectionState.connected;
        });

        if (state == BluetoothConnectionState.disconnected) {
          setState(() {
            _selectedDevice = null;
          });
        }
      });

      // Store the device for later use
      BluetoothManager().device = device;
      BluetoothManager().isConnected = true;

      // Navigate to the menu page
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyMenu())
      ).then((_) {
        // When returning from the menu page, check if we need to disconnect
        if (BluetoothManager().device != null && BluetoothManager().isConnected) {
          BluetoothManager().device!.disconnect();
          BluetoothManager().device = null;
          BluetoothManager().isConnected = false;
          setState(() {
            _isConnected = false;
            _selectedDevice = null;
          });
        }
      });
    } catch (ex) {
      print('Error connecting to device: $ex');
      setState(() {
        _isConnected = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect to Arduino'),
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('Enable Bluetooth'),
            value: _bluetoothState == BluetoothAdapterState.on,
            onChanged: (bool value) {
              if (value) {
                FlutterBluePlus.turnOn();
              } else {
                // Flutter Blue Plus doesn't directly support turning off Bluetooth
                // Users would need to do this from system settings
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Available Devices',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: Icon(
                    _isScanning ? Icons.cancel : Icons.refresh,
                    color: Colors.blue,
                  ),
                  onPressed: _isScanning ? _stopScan : _startScan,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _devicesList.length,
              itemBuilder: (context, index) {
                final result = _devicesList[index];
                final device = result.device;
                return ListTile(
                  leading: const Icon(Icons.bluetooth),
                  title: Text(device.advName.isNotEmpty
                      ? device.advName
                      : 'Unknown device'),
                  subtitle: Text(device.remoteId.str),
                  trailing: ElevatedButton(
                    child: const Text('Connect'),
                    onPressed: () => _connectToDevice(device),
                  ),
                );
              },
            ),
          ),
          if (_isScanning)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (_devicesList.isEmpty && !_isScanning)
            const Center(
              child: Text('No devices found. Try scanning again.'),
            ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bluetooth,
                  size: 80,
                  color: _isConnected ? Colors.green : Colors.blue,
                ),
                const SizedBox(height: 10),
                Text(
                  _isConnected
                      ? 'Connected to ${_selectedDevice?.advName}'
                      : 'Not Connected',
                  style: TextStyle(
                    fontSize: 18,
                    color: _isConnected ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Singleton to manage Bluetooth connection across the app
class BluetoothManager {
  static final BluetoothManager _instance = BluetoothManager._internal();

  factory BluetoothManager() => _instance;

  BluetoothManager._internal();

  BluetoothDevice? device;
  bool isConnected = false;
  BluetoothCharacteristic? writeCharacteristic;

  Future<void> discoverServicesAndSetup() async {
    if (device == null || !isConnected) return;

    // Discover services
    List<BluetoothService> services = await device!.discoverServices();

    // Find a writable characteristic (you'll need to know your service and characteristic UUIDs)
    // This is just an example - replace with your actual UUIDs
    const String SERVICE_UUID = "0000ffe0-0000-1000-8000-00805f9b34fb"; // Example UUID
    const String CHARACTERISTIC_UUID = "0000ffe1-0000-1000-8000-00805f9b34fb"; // Example UUID

    for (BluetoothService service in services) {
      if (service.uuid.str == SERVICE_UUID) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          if (characteristic.uuid.str == CHARACTERISTIC_UUID &&
              characteristic.properties.write) {
            writeCharacteristic = characteristic;
            print('Found writable characteristic');
            break;
          }
        }
      }
    }
  }

  Future<void> sendMessage(String message) async {
    if (device != null && isConnected && writeCharacteristic != null) {
      try {
        await writeCharacteristic!.write(message.codeUnits);
        print('Message sent: $message');
      } catch (e) {
        print('Error sending message: $e');
      }
    } else {
      print('Cannot send message: device not connected or characteristic not found');

      // Attempt to discover services if we're connected but don't have a characteristic
      if (device != null && isConnected && writeCharacteristic == null) {
        await discoverServicesAndSetup();
      }
    }
  }
}