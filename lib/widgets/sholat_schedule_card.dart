import 'package:flutter/material.dart';

class SholatScheduleCard extends StatelessWidget {
  const SholatScheduleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1ABC9C),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Jadwal Sholat Hari Ini", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("Subuh: 04:30 | Dzuhur: 12:00 | Ashar: 15:30 | Maghrib: 18:00 | Isya: 19:10", style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
