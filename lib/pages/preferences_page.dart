import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int currentValue = 30; // Valor por defecto

  @override
  void initState() {
    super.initState();
    _loadCurrentPreference();
  }

  Future<void> _loadCurrentPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentValue = prefs.getInt('heroCount') ?? 30;
      _controller.text = currentValue.toString();
    });
  }

  Future<void> _savePreference(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('heroCount', value);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preferencia guardada')),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final int newValue = int.parse(_controller.text);
      _savePreference(newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preferencias')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cantidad de héroes a mostrar (1-50)',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Ej: 30',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingresa un número';
                  final int? number = int.tryParse(value);
                  if (number == null) return 'Debe ser un número válido';
                  if (number < 1 || number > 50) return 'Debe estar entre 1 y 50';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
