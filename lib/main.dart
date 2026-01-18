// import library yang dibutuhkan
// dart:convert digunakan untuk mengubah data JSON
import 'dart:convert';

// package flutter utama
import 'package:flutter/material.dart';

// package http untuk mengambil data dari internet (REST API)
import 'package:http/http.dart' as http;

// fungsi utama aplikasi
void main() {
  runApp(const MyApp());
}

// widget utama aplikasi (Stateless karena tidak ada perubahan state)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie App',

      // pengaturan tema aplikasi (warna dan material design)
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),

      // halaman utama aplikasi
      home: const MyHomePage(title: 'Movie List'),
    );
  }
}

// halaman utama menggunakan StatefulWidget
// karena data film akan berubah setelah fetch dari API
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// state dari halaman utama
class _MyHomePageState extends State<MyHomePage> {
  // list untuk menyimpan data film
  List<dynamic> movies = [];

  // penanda apakah data masih dimuat
  bool isLoading = true;

  // fungsi untuk mengambil data film dari REST API
  Future<void> fetchMovies() async {
    try {
      // URL API Studio Ghibli
      const url = 'https://ghibliapi.vercel.app/films';
      final uri = Uri.parse(url);

      // request GET ke API
      final response = await http.get(uri);

      // jika request berhasil
      if (response.statusCode == 200) {
        // decode JSON menjadi List
        final jsonData = jsonDecode(response.body);

        // update state
        setState(() {
          movies = jsonData;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load movies');
      }
    } catch (e) {
      // menangani error jika gagal fetch data
      debugPrint('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // fungsi yang dipanggil pertama kali saat widget dibuat
  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  // tampilan UI halaman utama
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // app bar aplikasi
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.movie),
            SizedBox(width: 8),
            Text('Movie List'),
          ],
        ),
      ),

      // jika data masih loading tampilkan loading indicator
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
      // jika data sudah ada tampilkan list film
          : ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];

          return Card(
            color: Colors.blue.shade50,
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),

            // ListTile untuk menampilkan data film
            child: ListTile(
              contentPadding: const EdgeInsets.all(10),

              // gambar film
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  movie['image'],
                  width: 50,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),

              // judul film
              title: Text(
                movie['title'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              // sutradara film
              subtitle: Text('Director: ${movie['director']}'),

              // tahun rilis
              trailing: Text(
                movie['release_date'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              // event klik untuk pindah ke halaman detail
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MovieDetailPage(movie),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// halaman detail film (Stateless karena data tidak berubah)
class MovieDetailPage extends StatelessWidget {
  const MovieDetailPage(this.movie, {super.key});
  final dynamic movie;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // app bar halaman detail
      appBar: AppBar(
        title: Text(movie['title']),
      ),

      // body dapat discroll
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // banner film
            Image.network(
              movie['movie_banner'],
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
            ),

            // konten detail film
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // judul film
                  Text(
                    movie['title'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // informasi film dengan icon
                  Row(
                    children: [
                      const Icon(Icons.person, size: 18),
                      const SizedBox(width: 6),
                      Text('Director: ${movie['director']}'),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.business, size: 18),
                      const SizedBox(width: 6),
                      Text('Producer: ${movie['producer']}'),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18),
                      const SizedBox(width: 6),
                      Text('Release Year: ${movie['release_date']}'),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 18, color: Colors.amber),
                      const SizedBox(width: 6),
                      Text('Rating: ${movie['rt_score']}'),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // deskripsi film
                  Text(
                    movie['description'],
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}