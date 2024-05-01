import 'package:flutter/material.dart'; // mengimport library flutter/material untuk mengembangkan UI
import 'package:http/http.dart' as http; // mengimport library http dari package http untuk melakukan permintan HTTP
import 'dart:convert'; // Mengimport pustaka dart:convert untuk mengolah data JSON

void main() {
  runApp(const MyApp()); // memulai aplikasi dengan widget MyApp
}

// menampung data hasil pemanggilan API
class Activity {
  String aktivitas; // Variabel untuk menyimpan aktivitas dari API
  String jenis; // Variabel untuk menyimpan jenis aktivitas dari API

  Activity({required this.aktivitas, required this.jenis}); // konstruktor

  //metode factory untuk mengonversi JSON menjadi objek activity
  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      aktivitas: json['activity'], // Mengambil nilai aktivitas dari JSON
      jenis: json['type'], // Mengambil nilai jenis aktivitas dari JSON
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MyAppState(); // Membuat dan mengembalikan state MyAppState
  }
}

class MyAppState extends State<MyApp> {
  late Future<Activity> futureActivity; // Variabel untuk menampung hasil pemanggilan API

  String url = "https://www.boredapi.com/api/activity"; // URL untuk API

// Inisialisasi future activity dengan aktivitas kosong
  Future<Activity> init() async {
    return Activity(aktivitas: "", jenis: "");
  }

  //metode untuk mengambil data dari API
  Future<Activity> fetchData() async {
    final response = await http.get(Uri.parse(url)); // Melakukan permintaan HTTP ke API
    if (response.statusCode == 200) {
      // jika server mengembalikan 200 OK (berhasil),
      // parse json
      return Activity.fromJson(jsonDecode(response.body));
    } else {
      // jika gagal (bukan  200 OK),
      // lempar exception
      throw Exception('Gagal load');
    }
  }

  @override
  void initState() {
    super.initState(); // Memanggil initState milik superclass State untuk melakukan inisialisasi
    futureActivity = init(); // Memanggil metode init untuk menginisialisasi futureActivity
  }

  @override
  Widget build(Object context) {
    return MaterialApp( // membungkus aplikasi dengan widget MaterialApp untuk memungkinkan penggunaan fitur material design
        home: Scaffold( // membungkus aplikasi dengan widget scaffold untuk menyediakan struktur dasar halaman
      body: Center( // Menempatkan konten utama di tengah
        child: Column( // Mengatur konten utama dalam bentuk kolom
          mainAxisAlignment: MainAxisAlignment.center, // Menempatkan konten secara vertikal di tengah
          children: [
          Padding(
            padding: EdgeInsets.only(bottom: 20), // Memberikan padding di bagian bawah
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  futureActivity = fetchData(); //ketika tombol ditekan, ambil data baru
                });
              },
              child: Text("Saya bosan ..."),
            ),
          ),
          FutureBuilder<Activity>(
            future: futureActivity, // Menetapkan futureActivity sebagai sumber data untuk FutureBuilder
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                //jika data tersedia, tampilkan aktivitas dan jenisnya
                return Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Text(snapshot.data!.aktivitas), // Menampilkan aktivitas
                      Text("Jenis: ${snapshot.data!.jenis}") // Menampilkan jenis aktivitas
                    ]));
              } else if (snapshot.hasError) {
                //jika terjadi error, tampilkan pesan error
                return Text('${snapshot.error}');
              }
              // default: tampilkan indikator loading
              return const CircularProgressIndicator();
            },
          ),
        ]),
      ),
    ));
  }
}