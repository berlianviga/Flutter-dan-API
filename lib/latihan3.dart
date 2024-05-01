import 'package:flutter/material.dart'; // mengimport library flutter/material untuk mengembangkan UI
import 'package:http/http.dart' as http; // mengimport paket http untuk melakukan permintaan HTTP
import 'dart:convert'; // mengimport paket json untuk mengonversi respons HTTP menjadi objek dart
import 'package:url_launcher/url_launcher.dart'; // mengimport paket url_launcher untuk membuka URL eksternal

//class untuk menyimpan nama universitas dan situs resminya
class SitusUniv {
  String nama; // variabel untuk menyimpan nama universitas
  String situs; // variabel untuk menyimpan situs universitas
  SitusUniv({required this.nama, required this.situs}); // konstruktor
}

//class untuk menyimpan daftar universitas dan situs resminya
class Situs {
  List<SitusUniv> ListPop = []; // list untuk menyimpan objek SitusUniv

//konstruktor untuk mengonversi JSON menjadi objek situs
  Situs.fromJson(List<dynamic> json) {
    for (var val in json) {
      var namaUniv = val["name"]; // ambil nama universitas dari JSON
      var situsUniv = val["web_pages"][0]; // ambil situs universitas dari JSON 
      ListPop.add(SitusUniv(nama: namaUniv, situs: situsUniv)); // Tambahkan objek SitusUniv ke List
    }
  }

}

void main() {
  runApp(MyApp()); // untuk menjalankan aplikasi flutter
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState(); // Membuat dan mengembalikan state MyAppState
  }
}

//class state
class MyAppState extends State<MyApp> {
  late Future<Situs> futureSitus; // future untuk menyimpan data universitas dari API

  //URL untuk mengambil data universitas dari API
  String url =
      "http://universities.hipolabs.com/search?country=Indonesia";

  //metode untuk mengambil data dari API
  Future<Situs> fetchData() async {
  final response = await http.get(Uri.parse(url)); // Permintaan HTTP GET

  if (response.statusCode == 200) {
    // jika server mengembalikan 200 OK (berhasil),
    // parse json
    return Situs.fromJson(jsonDecode(response.body)); // Menggunakan konstruktor Situs
  } else {
    // jika gagal (bukan  200 OK),
    // lempar exception
    throw Exception('Gagal load');
  }
}

  @override
  void initState() {
    super.initState(); // Memanggil initState milik superclass State untuk melakukan inisialisasi
    futureSitus = fetchData(); //memanggil fetchData saat initState
  }

 @override
  Widget build(BuildContext context) {
    return MaterialApp( // membungkus aplikasi dengan widget MaterialApp untuk memungkinkan penggunaan fitur material design
      title: 'Universitas dan Situs Resminya', //judul aplikasi
      home: Scaffold( // membungkus aplikasi dengan widget scaffold untuk menyediakan struktur dasar halaman
        appBar: AppBar(
          title: const Text('Universitas dan Situs Resminya'), // judul app bar 
        ),
        body: Center(
          child: FutureBuilder<Situs>(
            future: futureSitus,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                //jika data tersedia, tampilkan ListView dengan daftar universitas
                return ListView.builder(
                  itemCount: snapshot.data!.ListPop.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        _launchURL(snapshot.data!.ListPop[index].situs);
                      },
                      child: Container(
                        decoration: BoxDecoration(border: Border.all()), // dekorasi container
                        padding: const EdgeInsets.all(14), // padding container
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(snapshot.data!.ListPop[index].nama), //tampilkan nama universitas
                            Text(
                              snapshot.data!.ListPop[index].situs, // tampilkan situs resmi universitas
                              style: TextStyle(
                                color: Colors.blue, // warna biru untuk tautan
                                decoration: TextDecoration.underline, // garis bawah untuk tautan
                              ),
                            ), //tampilkan situs resmi universitas
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                //jika terjadi error, tampilkan pesan error
                return Text('${snapshot.error}');
              }
              // default: tampilkan indikator loading
              return CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }

  // method untuk membuka URL
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url); // buka URL menggunakan paket url_launcher
    } else {
      throw 'Could not launch $url'; // menampilkan exception jika gagal membuka URL
    }
  }
}