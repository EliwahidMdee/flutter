import 'package:flutter/material.dart';

class PaymentListScreen extends StatelessWidget {
  const PaymentListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
      ),
      body: const Center(
        child: Text('Payment List Screen - To be implemented'),
      ),
    );
  }
}
