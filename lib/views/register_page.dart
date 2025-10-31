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
    // Gunakan context.watch untuk mendengarkan state loading
    final userController = context.watch<UserController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Akun"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
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
                          // Gunakan context.read untuk memanggil fungsi (action)
                          final userControllerRead = context.read<UserController>(); 
                          
                          final result = await userControllerRead.register(
                            _nameController.text.trim(),
                            _emailController.text.trim(),
                            _passwordController.text.trim(),
                          );
                          
                          if (result == null) {
                            // Pendaftaran Berhasil
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Registrasi berhasil! Silakan login.')),
                            );
                            
                            // Navigasi yang benar: Kembali ke LoginPage
                            if (mounted) {
                              Navigator.pop(context); 
                            }
                          } else {
                            // Pendaftaran Gagal
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(result)),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Theme.of(context).colorScheme.secondary, 
                  foregroundColor: Colors.black,
                ),
                child: userController.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Daftar"),
              ),
              
              // Link ke Login
              const SizedBox(height: 16),
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
    );
  }
}