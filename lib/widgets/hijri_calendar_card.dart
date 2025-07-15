import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';

class HijriCalendarCard extends StatelessWidget {
  const HijriCalendarCard({super.key});

  @override
  Widget build(BuildContext context) {
    final hijri = HijriCalendar.now();
    final isSmall = MediaQuery.of(context).size.width < 400;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmall ? 12 : 20),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today,
            color: const Color.fromARGB(255, 24, 91, 83),
            size: isSmall ? 18 : 24,
          ),
          SizedBox(width: isSmall ? 8 : 11),
          Flexible(
            child: Text(
              'Tanggal Hari ini : ',
              style: TextStyle(
                fontFamily: 'Merriweather',
                fontSize: isSmall ? 12 : 14,
                fontWeight: FontWeight.w500,
                color: const Color.fromARGB(255, 60, 61, 61),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} H',
              style: TextStyle(
                fontFamily: 'Cinzel',
                fontSize: isSmall ? 12 : 14,
                fontWeight: FontWeight.w600,
                color: const Color.fromARGB(255, 8, 144, 128),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
