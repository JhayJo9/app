import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';

class KitchenPage extends StatefulWidget {
  const KitchenPage({super.key});

  @override
  State<KitchenPage> createState() => _KitchenPageState();
}

class _KitchenPageState extends State<KitchenPage> {
  bool isLightOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kitchen Controls"),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isLightOn ? Colors.amber.shade100 : Colors.blueGrey.shade900,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 30),

            // Kitchen Icon with light effect
            Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                color: isLightOn ? Colors.amber.shade200 : Colors.blueGrey.shade800,
                shape: BoxShape.circle,
                boxShadow: isLightOn
                    ? [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.6),
                    spreadRadius: 10,
                    blurRadius: 15,
                  )
                ]
                    : [],
              ),
              child: Icon(
                Icons.kitchen,
                size: 100,
                color: isLightOn ? Colors.amber : Colors.grey,
              ),
            ),

            const SizedBox(height: 40),

            // Status Text
            Text(
              isLightOn ? "Kitchen Light: ON" : "Kitchen Light: OFF",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isLightOn ? Colors.amber.shade800 : Colors.white70,
              ),
            ),

            const SizedBox(height: 40),

            // Custom Switch using flutter_switch
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "OFF",
                  style: TextStyle(
                    fontSize: 18,
                    color: !isLightOn ? Colors.white : Colors.white54,
                    fontWeight: !isLightOn ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(width: 20),
                FlutterSwitch(
                  width: 100,
                  height: 55,
                  valueFontSize: 18,
                  toggleSize: 45,
                  value: isLightOn,
                  borderRadius: 30,
                  padding: 8,
                  activeToggleColor: Colors.amber.shade600,
                  inactiveToggleColor: Colors.blueGrey.shade700,
                  activeSwitchBorder: Border.all(color: Colors.amber.shade800, width: 2),
                  inactiveSwitchBorder: Border.all(color: Colors.blueGrey.shade400, width: 2),
                  activeColor: Colors.amber.shade300,
                  inactiveColor: Colors.blueGrey.shade400,
                  activeIcon: const Icon(Icons.lightbulb, color: Colors.amber),
                  inactiveIcon: const Icon(Icons.lightbulb_outline, color: Colors.grey),
                  onToggle: (val) {
                    setState(() {
                      isLightOn = val;
                    });
                  },
                ),
                const SizedBox(width: 20),
                Text(
                  "ON",
                  style: TextStyle(
                    fontSize: 18,
                    color: isLightOn ? Colors.amber : Colors.white54,
                    fontWeight: isLightOn ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),



          ],
        ),
      ),
    );
  }
}