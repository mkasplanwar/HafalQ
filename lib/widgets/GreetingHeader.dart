import 'package:flutter/material.dart';

class GreetingHeader extends StatelessWidget {
  final String username;
  final String city;
  final bool isSmall;

  const GreetingHeader({
    super.key,
    required this.username,
    required this.city,
    required this.isSmall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmall ? 12 : 20),
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(171, 18, 130, 108),
            Color.fromARGB(153, 175, 194, 235),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: isSmall ? 20 : 28,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              color: const Color(0xFF1ABC9C),
              size: isSmall ? 22 : 30,
            ),
          ),
          SizedBox(width: isSmall ? 10 : 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Assalamu'alaikum",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isSmall ? 4 : 6),
                Text(
                  username.isNotEmpty
                      ? 'Selamat datang $username!'
                      : 'Selamat datang Pengguna!',
                  style: TextStyle(
                    fontFamily: 'Merriweather',
                    fontSize: isSmall ? 11 : 13,
                    fontWeight: FontWeight.w500,
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (city.isNotEmpty)
                  Text(
                    '🌏: $city',
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'Poppins',
                      color: Colors.white70,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.notifications_none,
              color: Colors.white,
              size: isSmall ? 22 : 28,
            ),
            onPressed: () {},
            tooltip: 'Notifikasi',
          ),
        ],
      ),
    );
  }
}
