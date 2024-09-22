// lib/pages/payment_handler.dart

import 'package:flutter/material.dart';

class PaymentHandler extends StatelessWidget {
  final Map<String, dynamic> hotel;

  PaymentHandler({required this.hotel});

  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cardHolderController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payment for ${hotel['item']}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Enter your payment details"),
            SizedBox(height: 20),
            TextField(
              controller: cardNumberController,
              decoration: InputDecoration(labelText: "Card Number"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: cardHolderController,
              decoration: InputDecoration(labelText: "Card Holder Name"),
            ),
            TextField(
              controller: expiryDateController,
              decoration: InputDecoration(labelText: "Expiry Date (MM/YY)"),
              keyboardType: TextInputType.datetime,
            ),
            TextField(
              controller: cvvController,
              decoration: InputDecoration(labelText: "CVV"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Simulate payment processing
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Payment Successful"),
                    content: Text("Thank you for booking ${hotel['item']}!"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("OK"),
                      ),
                    ],
                  ),
                );
              },
              child: Text("Pay Now"),
            ),
          ],
        ),
      ),
    );
  }
}
