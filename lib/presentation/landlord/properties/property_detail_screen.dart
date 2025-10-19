import 'package:flutter/material.dart';

class PropertyDetailScreen extends StatelessWidget {
  final int propertyId;

  const PropertyDetailScreen({
    Key? key,
    required this.propertyId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Details'),
      ),
      body: Center(
        child: Text('Property Details Screen for ID: $propertyId - To be implemented'),
      ),
    );
  }
}
