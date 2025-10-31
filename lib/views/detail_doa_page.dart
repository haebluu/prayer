import 'package:flutter/material.dart';
import '../models/doa_model.dart';

class DetailDoaPage extends StatelessWidget {
  final DoaModel doa; 
  const DetailDoaPage({super.key, required this.doa});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(doa.nama),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[

            Text(
              // Menampilkan NAMA (Judul Doa) di bagian paling atas
              doa.nama, 
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22, // Ukuran lebih besar karena ini judul utama
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const Divider(height: 20),

            // Teks Arab (key: ar)
            const Text('Teks Arab:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5),
                ],
              ),
              child: Text(
                doa.ar,
                textAlign: TextAlign.right,
                // Gunakan Font yang mendukung Arab (misalnya Noto Sans Arabic jika Anda menambahkannya)
                style: const TextStyle(fontSize: 32, height: 1.8, fontFamily: 'Arial'), 
              ),
            ),
            const SizedBox(height: 30),
            
            // Teks Latin (key: tr)
            const Text('Bacaan Latin:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
            const SizedBox(height: 8),
            Text(
              doa.tr,
              style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // Terjemahan (key: idn)
            const Text('Terjemahan:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
            const SizedBox(height: 8),
            Text(
              doa.idn,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
            const Divider(height: 40),

            // Sumber/Keterangan (key: tentang)
            const Text('Keterangan & Sumber:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 8),
            Text(
              doa.tentang,
              style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}