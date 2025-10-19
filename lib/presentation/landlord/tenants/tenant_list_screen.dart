import 'package:flutter/material.dart';

class TenantListScreen extends StatelessWidget {
  const TenantListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tenants'),
      ),
      body: const Center(
        child: Text('Tenant List Screen - To be implemented'),
      ),
    );
  }
}
