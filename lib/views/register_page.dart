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
    title: Text(
     "Daftar Akun", 
     style: TextStyle(color: theme.colorScheme.onPrimary)
    ),
    backgroundColor: theme.primaryColor,
    foregroundColor: Colors.white, 
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
         crossAxisAlignment: CrossAxisAlignment.stretch,
         children: [
          TextFormField(
           controller: _nameController,
           decoration: const InputDecoration(
            labelText: "Nama",
            prefixIcon: Icon(Icons.person_outline), 
            border: OutlineInputBorder(), 
           ),
           validator: (value) =>
             value!.isEmpty ? 'Nama tidak boleh kosong' : null,
          ),
          const SizedBox(height: 16),
          
          TextFormField(
           controller: _emailController,
           decoration: const InputDecoration(
            labelText: "Email",
            prefixIcon: Icon(Icons.email_outlined), 
            border: OutlineInputBorder(), 
           ),
           keyboardType: TextInputType.emailAddress,
           validator: (value) =>
             value!.isEmpty ? 'Email tidak boleh kosong' : null,
          ),
          const SizedBox(height: 16),
          
          TextFormField(
           controller: _passwordController,
           decoration: const InputDecoration(
            labelText: "Password",
            prefixIcon: Icon(Icons.lock_outline), 
            border: OutlineInputBorder(), 
           ),
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
                final userControllerRead = context.read<UserController>(); 
                
                final result = await userControllerRead.register(
                 _nameController.text.trim(),
                 _emailController.text.trim(),
                 _passwordController.text.trim(),
                );
                
                if (result == null) {
                 if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(
                    content: Text('Registrasi berhasil! Silakan login.'),
                    backgroundColor: Colors.green, 
                   ),
                  );
                  
                  Navigator.pop(context); 
                 }
                } else {
                 if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                    content: Text(result),
                    backgroundColor: Colors.redAccent, 
                   ),
                  );
                 }
                }
               }
              },
           style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              vertical: 15, horizontal: 30),
            backgroundColor: theme.colorScheme.secondary, 
            foregroundColor: theme.colorScheme.onPrimary,
            textStyle: const TextStyle(
             fontWeight: FontWeight.bold,
             fontSize: 16,
            ),
            shape: RoundedRectangleBorder( 
             borderRadius: BorderRadius.circular(12),
            ),
           ),
           child: userController.isLoading
             ? const SizedBox( 
               width: 24,
               height: 24,
               child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
               ),
              )
             : const Text("Daftar"),
          ),
          
          const SizedBox(height: 16),
          
          TextButton(
           onPressed: () {
            Navigator.pop(context); 
           },
           child: const Text(
            "Sudah punya akun? Masuk di sini",
            style: TextStyle(
             decoration: TextDecoration.underline, 
            ),
           ),
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