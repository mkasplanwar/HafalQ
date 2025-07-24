import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '/services/theme_service.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  double _volume = 1.0;
  double _fontSize = 16.0;
  String _username = 'Nama Pengguna';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'Nama Pengguna';
    });
  }

  Future<void> _editUsername() async {
    final controller = TextEditingController(text: _username);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Nama Pengguna'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Masukkan nama'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', result);
      setState(() {
        _username = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: const Color(0xFF1ABC9C),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFF7C873),
                child: Icon(Icons.person, color: Color(0xFF1ABC9C)),
              ),
              title: const Text('Profil Pengguna'),
              subtitle: Text(_username),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFF1ABC9C)),
                onPressed: _editUsername,
                tooltip: 'Edit Nama',
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Fitur-fitur
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ExpansionTile(
              leading: const Icon(Icons.star, color: Color(0xFF1ABC9C)),
              title: const Text('Fitur-fitur'),
              children: [
                ListTile(
                  leading: const Icon(Icons.bookmark, color: Color(0xFFF7C873)),
                  title: const Text('Bookmark'),
                  subtitle: const Text('Simpan ayat favorit'),
                ),
                ListTile(
                  leading: const Icon(Icons.audiotrack, color: Color(0xFF1ABC9C)),
                  title: const Text('Audio Quran'),
                  subtitle: const Text('Putar dan ulangi ayat/surah'),
                ),
                ListTile(
                  leading: const Icon(Icons.translate, color: Color(0xFF1ABC9C)),
                  title: const Text('Latin & Terjemahan'),
                  subtitle: const Text('Tampilkan transliterasi dan arti'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Pengaturan Volume
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.volume_up, color: Color(0xFF1ABC9C)),
              title: const Text('Volume Audio'),
              subtitle: Slider(
                value: _volume,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                label: (_volume * 100).toInt().toString(),
                onChanged: (value) {
                  setState(() {
                    _volume = value;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Pengaturan Ukuran Font
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.format_size, color: Color(0xFF1ABC9C)),
              title: const Text('Ukuran Font'),
              subtitle: Slider(
                value: _fontSize,
                min: 12.0,
                max: 28.0,
                divisions: 8,
                label: '${_fontSize.toInt()} px',
                onChanged: (value) {
                  setState(() {
                    _fontSize = value;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Dark Mode
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SwitchListTile(
            secondary: const Icon(Icons.dark_mode, color: Color(0xFF1ABC9C)),
            title: const Text('Dark Mode'),
            value: Provider.of<ThemeService>(context).isDarkMode,
            onChanged: (value) {
              Provider.of<ThemeService>(context, listen: false).setDarkMode(value);
            },
          ),
          ),
          const SizedBox(height: 18),

          // About Us
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.info, color: Color(0xFF1ABC9C)),
              title: const Text('Tentang Kami'),
              subtitle: const Text('Aplikasi HafalQ Quran\nDibuat oleh Antasari Programming Team, 2025'),
            ),
          ),
        ],
      ),
    );
  }
}
