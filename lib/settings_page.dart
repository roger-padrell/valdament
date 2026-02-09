import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const _keyCopy = 'copy_to_app_dir';
  bool _copyToApp = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    setState(() {
      _copyToApp = sp.getBool(_keyCopy) ?? false;
      _loading = false;
    });
  }

  Future<void> _setCopy(bool v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_keyCopy, v);
    setState(() => _copyToApp = v);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                SwitchListTile(
                  title: const Text('Copy imported quizzes to app folder'),
                  subtitle: const Text('When enabled, imported TOML files are copied into the app documents directory'),
                  value: _copyToApp,
                  onChanged: _setCopy,
                ),
              ],
            ),
    );
  }
}
