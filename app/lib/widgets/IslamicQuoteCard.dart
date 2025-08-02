import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class IslamicQuoteCard extends StatefulWidget {
  const IslamicQuoteCard({super.key});

  @override
  State<IslamicQuoteCard> createState() => _IslamicQuoteCardState();
}

class _IslamicQuoteCardState extends State<IslamicQuoteCard>
    with SingleTickerProviderStateMixin {
  late Map<String, String> _selectedQuote;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final List<Map<String, String>> _quotes = [
    {
      'quote': 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا',
      'arti': 'Sesungguhnya bersama kesulitan ada kemudahan. (QS. Al-Insyirah: 6)'
    },
    {
      'quote': 'إِنَّ اللَّهَ مَعَ الصَّابِرِينَ',
      'arti': 'Sesungguhnya Allah bersama orang-orang yang sabar. (QS. Al-Baqarah: 153)'
    },
    {
      'quote': 'وَذَكِّرْ فَإِنَّ الذِّكْرَى تَنفَعُ الْمُؤْمِنِينَ',
      'arti': 'Berilah peringatan, karena peringatan itu bermanfaat bagi orang-orang beriman. (QS. Adz-Dzariyat: 55)'
    },
  ];

  @override
  void initState() {
    super.initState();
    final random = Random();
    _selectedQuote = _quotes[random.nextInt(_quotes.length)];

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 400;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 32),
            padding: EdgeInsets.all(isSmall ? 14 : 20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35), // background lebih gelap
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.format_quote, color: Colors.teal[700], size: isSmall ? 20 : 24),
                const SizedBox(height: 10),
                Text(
                  _selectedQuote['quote']!,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: isSmall ? 18 : 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedQuote['arti']!,
                  style: TextStyle(
                    fontFamily: 'Merriweather',
                    fontSize: isSmall ? 12 : 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
