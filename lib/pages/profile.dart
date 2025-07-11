import 'package:flutter/material.dart';
import 'package:marvel_lib/entities/activity.dart'; // ajusta el import según tu estructura

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int currentValue = 30;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final value = await ActivityPreferences.loadHeroCount();
    final name = await ActivityPreferences.loadUsername();
    setState(() {
      currentValue = value;
      _controller.text = value.toString();
      _nameController.text = name;
    });
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final int newValue = int.parse(_controller.text);
      await ActivityPreferences.saveHeroCount(newValue);
      await ActivityPreferences.saveUsername(_nameController.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preferencias guardadas')),
      );
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
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Ingresa tu nombre',
              ),
            ),
            const SizedBox(height: 24),

            // Card: héroes favoritos (espacio reservado)
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

            // preferencias
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
                        'Cantidad de héroes a mostrar (1–50)',
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

