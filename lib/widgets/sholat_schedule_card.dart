import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/sholat_schedule_service.dart';

class SholatScheduleCard extends StatefulWidget {
  const SholatScheduleCard({super.key});

  @override
  State<SholatScheduleCard> createState() => _SholatScheduleCardState();
}

class _SholatScheduleCardState extends State<SholatScheduleCard> {
  bool _loading = true;
  String? _error;
  SholatSchedule? _schedule;

  @override
  void initState() {
    super.initState();
    _fetchSchedule();
  }

  Future<void> _fetchSchedule() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final result = await SholatScheduleService.fetchFromLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (result != null) {
        setState(() {
          _schedule = result;
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Gagal memuat data.';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Gagal ambil lokasi: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1ABC9C),
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : _error != null
                ? Text(_error!, style: const TextStyle(color: Colors.white))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Jadwal Sholat Hari Ini",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Subuh: ${_schedule!.subuh} | Dzuhur: ${_schedule!.dzuhur} | Ashar: ${_schedule!.ashar} | Maghrib: ${_schedule!.maghrib} | Isya: ${_schedule!.isya}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
      ),
    );
  }
}
