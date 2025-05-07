import 'package:flutter/material.dart';


class MySwitch extends StatelessWidget {
  final String itemName;
  const MySwitch({super.key, required this.itemName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Switch Page'),
      ),
      body: Center(
        child: Text('This is the $itemName page!'),
      ),
    );
  }
}