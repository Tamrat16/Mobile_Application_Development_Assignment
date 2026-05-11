import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/preferences_service.dart';
import '../services/pin_service.dart';
import '../services/expenses_db.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  final _prefs = PreferencesService();
  String _currency = 'ETB';
  bool _darkMode = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _load();
  }

  Future<void> _load() async {
    final curr = await _prefs.getCurrency();
    final dark = await _prefs.isDarkMode();
    setState(() {
      _currency = curr;
      _darkMode = dark;
    });
    _animationController.forward();
  }

  Future<void> _resetAll() async {
    HapticFeedback.heavyImpact();
    await PinService().deletePin();
    await ExpensesDb.instance.deleteAll();
    await _prefs.setCurrency('ETB');
    await _prefs.setDarkMode(false);
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/pinSetup', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: FadeTransition(
        opacity: _animationController,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(_animationController),
          child: ListView(
            children: [
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('PREFERENCES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 8),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: const Icon(Icons.currency_exchange, color: Color(0xFFFFB300)),
                  title: const Text('Currency'),
                  trailing: DropdownButton<String>(
                    value: _currency,
                    items: const [
                      DropdownMenuItem(value: 'ETB', child: Text('ETB 🇪🇹')),
                      DropdownMenuItem(value: 'USD', child: Text('USD 🇺🇸')),
                      DropdownMenuItem(value: 'EUR', child: Text('EUR 🇪🇺')),
                    ],
                    onChanged: (value) async {
                      if (value != null) {
                        HapticFeedback.lightImpact();
                        await _prefs.setCurrency(value);
                        setState(() => _currency = value);
                      }
                    },
                  ),
                ),
              ),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: SwitchListTile(
                  secondary: const Icon(Icons.dark_mode, color: Color(0xFFFFB300)),
                  title: const Text('Dark Mode'),
                  value: _darkMode,
                  onChanged: (value) async {
                    HapticFeedback.mediumImpact();
                    await _prefs.setDarkMode(value);
                    setState(() => _darkMode = value);
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                ),
              ),
              const Divider(height: 40),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('DANGER ZONE', style: TextStyle(fontSize: 12, color: Colors.red)),
              ),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                color: Colors.red.shade50,
                child: ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('Reset All Data', style: TextStyle(color: Colors.red)),
                  subtitle: const Text('Delete PIN and all expenses'),
                  onTap: () {
                    HapticFeedback.warningImpact();
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Reset everything?'),
                        content: const Text('This action cannot be undone. All your expenses and saved PIN will be erased.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _resetAll();
                            },
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}