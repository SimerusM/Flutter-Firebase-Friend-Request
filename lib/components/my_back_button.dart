import 'package:flutter/material.dart';

class MyBackButton extends StatelessWidget {
  const MyBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 219, 218, 216),
          shape: BoxShape.circle 
        ),
        padding: const EdgeInsets.all(10),
        child: const Icon(Icons.arrow_back),
      )
    );
  }
}