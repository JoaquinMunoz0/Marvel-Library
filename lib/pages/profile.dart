import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
      appBar: AppBar(title: const Text('Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Ícono de usuario
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 12),
            // Nombre de usuario
            const Text(
              'Nombre de Usuario',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Card de héroes favoritos
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Héroes favoritos',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('Aquí aparecerán los personajes que te han gustado.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Card de preferencias
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Preferencias de inicio',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Cantidad de héroes a mostrar (1-50)',
                        style: TextStyle(fontSize: 16),
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
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: _submit,
                          child: const Text('Guardar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
