import 'package:flutter/material.dart';

class WaitingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main Content
          Container(
            color: Colors.blue, // Set your desired background color
            child: Center(
              child: Text(
                'Finding a Driver...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),

          // Loading Indicator
          Center(
            child: CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: WaitingScreen(),
  ));
}
