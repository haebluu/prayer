import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/user_controller.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final userController = context.watch<UserController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        // Hapus const pada Text
        title: Text("Login", style: TextStyle(color: theme.colorScheme.onPrimary)), // FIX DI SINI
        backgroundColor: theme.primaryColor,
        centerTitle: true,
      ),
      body: Center( 
        child: SingleChildScrollView( 
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: "Email"),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                          value!.isEmpty ? 'Email tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: "Password"),
                      obscureText: true,
                      validator: (value) =>
                          value!.isEmpty ? 'Password tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: userController.isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                final userController = context.read<UserController>();
                                final result = await userController.login(
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                );
                                if (result == null) {
                                  // Navigasi sukses diurus oleh RootPage
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
                          : const Text("Login", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RegisterPage()),
                        );
                      },
                      child: const Text("Belum punya akun? Daftar di sini"),
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