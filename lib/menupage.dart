import 'package:flutter/material.dart';
import 'bedroom.dart';
import 'kitchen.dart';
import 'bathroom.dart';  // Make sure this file exists

class MenuItem {
  final IconData icon;
  final String name;

  MenuItem({required this.icon, required this.name});
}

// Create a map to store the pages for each menu item
final Map<String, WidgetBuilder> menuPages = {
  "Bedroom": (context) => const BedroomPage(),
  "Kitchen": (context) => const KitchenPage(),
  "Bathroom": (context) => const BathroomPage(),
};

class MyMenu extends StatelessWidget {
  MyMenu({super.key});

  final List<MenuItem> menuItems = [
    MenuItem(icon: Icons.bedroom_parent, name: "Bedroom"),
    MenuItem(icon: Icons.kitchen, name: "Kitchen"),
    MenuItem(icon: Icons.bathroom, name: "Bathroom")
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemCount: menuItems.length,
          itemBuilder: (context, index) {
            final item = menuItems[index];
            return InkWell(
              onTap: () {
                final pageBuilder = menuPages[item.name];
                if (pageBuilder != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: pageBuilder),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.icon,
                      size: 80,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}