import 'package:flutter/material.dart';

class PurchaseScreen extends StatefulWidget {
  final String questionId;

  const PurchaseScreen({required this.questionId});

  @override
  _PurchaseScreenState createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  bool isLoading = false;
  bool isPurchased = false;

  void _startPurchase() {
    setState(() {
      isLoading = true;
    });

    // Simulate a network request
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
        isPurchased = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Purchase Question Paper"),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : isPurchased
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 80,
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Purchase Successful!",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, widget.questionId);
                        },
                        child: Text("Continue"),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Unlock Question Paper",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Get access to this question paper by making a purchase.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: _startPurchase,
                        child: Text("Buy Now"),
                      ),
                    ],
                  ),
      ),
    );
  }
}
