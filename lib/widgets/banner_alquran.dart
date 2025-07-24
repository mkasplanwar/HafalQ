import 'package:flutter/material.dart';

class BannerAlquran extends StatelessWidget {
  const BannerAlquran({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage('assets/quran.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
