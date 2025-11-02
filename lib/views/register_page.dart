import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/user_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final userController = context.watch<UserController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Daftar Akun", style: TextStyle(color: theme.colorScheme.onPrimary)),
        backgroundColor: theme.primaryColor,
        centerTitle: true,
      ),
      body: Center( // Center content on screen
        child: SingleChildScrollView( // Allow scrolling if keyboard/content overflows
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0), // Padding di dalam Card
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Biarkan Column sekecil mungkin
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Input Nama
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: "Nama"),
                      validator: (value) =>
                          value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    // 2. Input Email
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: "Email"),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                          value!.isEmpty ? 'Email tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    // 3. Input Password
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: "Password"),
                      obscureText: true,
                      validator: (value) =>
                          value!.isEmpty ? 'Password tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 24),
                    
                    // Tombol Daftar
                    ElevatedButton(
                      onPressed: userController.isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                final userControllerRead = context.read<UserController>(); 
                                
                                final result = await userControllerRead.register(
                                  _nameController.text.trim(),
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                );
                                
                                if (result == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Registrasi berhasil! Silakan login.')),
                                  );
                                  
                                  if (mounted) {
                                    // Navigasi yang benar: Kembali ke LoginPage
                                    Navigator.pop(context); 
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(result)),
                                  );
                                }
                              }
                            },
                      // Menggunakan warna tema Anda
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: theme.colorScheme.secondary, 
                        foregroundColor: theme.colorScheme.onPrimary,
                      ),
                      child: userController.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Daftar", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Link ke Login
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Kembali ke LoginPage
                      },
                      child: const Text("Sudah punya akun? Masuk di sini"),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}